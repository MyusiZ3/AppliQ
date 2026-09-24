import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleDriveService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: AppConfig.googleWebClientId.isNotEmpty
        ? AppConfig.googleWebClientId
        : null,
    scopes: [
      'email',
      drive.DriveApi.driveFileScope,
    ],
  );

  /// Picks a document from local storage and uploads it to user's personal Google Drive
  /// in the path: `AppliQ / [companyName]_[positionTitle]`
  static Future<Map<String, String>?> pickAndUploadDocument({
    required String companyName,
    required String positionTitle,
  }) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      withData: kIsWeb,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final pickedFile = result.files.first;

    // Batasi ukuran file maksimal 25 MB untuk mencegah OOM / pemborosan kuota
    const maxFileSizeBytes = 25 * 1024 * 1024;
    if (pickedFile.size > maxFileSizeBytes) {
      throw Exception('Ukuran berkas melebihi batas maksimal 25 MB.');
    }

    // Authenticate with Google Drive Scope
    GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
    googleUser ??= await _googleSignIn.signInSilently();
    googleUser ??= await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Autentikasi Google Drive dibatalkan.');
    }

    final authHeaders = await googleUser.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    // 1. Locate or create root 'AppliQ' folder
    final folderQuery = await driveApi.files.list(
      q: "mimeType = 'application/vnd.google-apps.folder' and name = 'AppliQ' and trashed = false",
      $fields: 'files(id, name)',
      spaces: 'drive',
    );

    String appliQFolderId;
    if (folderQuery.files != null && folderQuery.files!.isNotEmpty) {
      appliQFolderId = folderQuery.files!.first.id!;
    } else {
      final rootFolder = await driveApi.files.create(
        drive.File()
          ..name = 'AppliQ'
          ..parents = ['root']
          ..mimeType = 'application/vnd.google-apps.folder',
        $fields: 'id, name, parents',
      );
      appliQFolderId = rootFolder.id!;
    }

    // 2. Locate or create subfolder '[Company]_[Job]' inside 'AppliQ'
    final cleanCompany = companyName.trim().isEmpty ? 'Company' : companyName.trim();
    final cleanPosition = positionTitle.trim().isEmpty ? 'Job' : positionTitle.trim();
    final subFolderName = '${cleanCompany}_$cleanPosition'
        .replaceAll(RegExp(r"['""/\\?%*:|<> ]"), '_');
    final safeQueryName = subFolderName.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

    final subFolderQuery = await driveApi.files.list(
      q: "mimeType = 'application/vnd.google-apps.folder' and name = '$safeQueryName' and '$appliQFolderId' in parents and trashed = false",
      $fields: 'files(id, name)',
      spaces: 'drive',
    );

    String subFolderId;
    if (subFolderQuery.files != null && subFolderQuery.files!.isNotEmpty) {
      subFolderId = subFolderQuery.files!.first.id!;
    } else {
      final subFolder = await driveApi.files.create(
        drive.File()
          ..name = subFolderName
          ..parents = [appliQFolderId]
          ..mimeType = 'application/vnd.google-apps.folder',
        $fields: 'id, name',
      );
      subFolderId = subFolder.id!;
    }

    // 3. Prepare media stream and upload file
    drive.Media media;
    if (kIsWeb || pickedFile.bytes != null) {
      media = drive.Media(
        Stream.value(pickedFile.bytes!),
        pickedFile.size,
      );
    } else {
      final file = File(pickedFile.path!);
      media = drive.Media(file.openRead(), await file.length());
    }

    final fileToUpload = drive.File()
      ..name = pickedFile.name
      ..parents = [subFolderId];

    final uploadedFile = await driveApi.files.create(
      fileToUpload,
      uploadMedia: media,
      $fields: 'id, name, webViewLink, webContentLink',
    );

    final viewLink = uploadedFile.webViewLink ??
        'https://drive.google.com/file/d/${uploadedFile.id}/view';

    return {
      'fileName': pickedFile.name,
      'fileUrl': viewLink,
      'folderPath': 'AppliQ/$subFolderName',
      'fileId': uploadedFile.id ?? '',
    };
  }

  /// Extracts the Google Drive file ID from a URL or raw ID string
  static String? extractFileId(String urlOrId) {
    final trimmed = urlOrId.trim();
    if (trimmed.isEmpty) return null;
    if (!trimmed.contains('/') && !trimmed.contains('.')) {
      return trimmed;
    }
    final match = RegExp(r'\/d\/([a-zA-Z0-9_-]+)').firstMatch(trimmed);
    if (match != null) return match.group(1);
    final idParamMatch = RegExp(r'[?&]id=([a-zA-Z0-9_-]+)').firstMatch(trimmed);
    if (idParamMatch != null) return idParamMatch.group(1);
    return null;
  }

  /// Deletes a file from Google Drive permanently
  static Future<bool> deleteDocument(String urlOrId) async {
    final fileId = extractFileId(urlOrId);
    if (fileId == null || fileId.isEmpty) {
      return false;
    }

    GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
    googleUser ??= await _googleSignIn.signInSilently();
    googleUser ??= await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Autentikasi Google Drive dibatalkan.');
    }

    final authHeaders = await googleUser.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    try {
      await driveApi.files.delete(fileId);
      return true;
    } catch (e) {
      // If the file is already deleted or not found (404), consider operation successful
      if (e.toString().contains('404') || e.toString().contains('notFound')) {
        return true;
      }
      rethrow;
    }
  }
}
