import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/localization/app_strings.dart';
import '../../../data/models/job_application.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/language_manager.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/application_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/notched_pill_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/appliq_loading.dart';
import 'application_detail_screen.dart';
import 'application_form_screen.dart';

class ApplicationsListScreen extends StatefulWidget {
  final JobRepository repository;

  const ApplicationsListScreen({super.key, required this.repository});

  @override
  State<ApplicationsListScreen> createState() => _ApplicationsListScreenState();
}

class _ApplicationsListScreenState extends State<ApplicationsListScreen> {
  List<JobApplication> _applications = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchOpen = false;
  ApplicationStatus? _selectedStatusFilter;
  bool _onlyFavorites = false;
  bool _isKanbanView = false;
  String _sortBy = 'newest';
  StreamSubscription? _dataSub;

  @override
  void initState() {
    super.initState();
    _loadApplications();
    _dataSub = widget.repository.dataChanges.listen((_) {
      if (mounted) _loadApplications(isSilent: true);
    });
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApplications(
      {bool isSilent = false, bool forceRefresh = false}) async {
    if (!isSilent) setState(() => _isLoading = true);
    try {
      final data =
          await widget.repository.getApplications(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _applications = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (!isSilent) UIHelper.handleError(context, e);
      }
    }
  }

  Future<void> _toggleFavorite(JobApplication app) async {
    try {
      await widget.repository.toggleFavorite(app.id);
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    }
  }

  String _lastFilterQuery = '';
  ApplicationStatus? _lastFilterStatus;
  bool _lastFilterOnlyFav = false;
  String _lastFilterSortBy = '';
  int _lastFilterAppHash = 0;
  List<JobApplication> _cachedFilteredApps = [];

  List<JobApplication> get _filteredApplications {
    final currentHash = Object.hash(_applications.length, _applications.isNotEmpty ? _applications.first.id : 0);
    if (_cachedFilteredApps.isNotEmpty &&
        _lastFilterQuery == _searchQuery &&
        _lastFilterStatus == _selectedStatusFilter &&
        _lastFilterOnlyFav == _onlyFavorites &&
        _lastFilterSortBy == _sortBy &&
        _lastFilterAppHash == currentHash) {
      return _cachedFilteredApps;
    }

    final query = _searchQuery.trim().toLowerCase();
    var list = _applications.where((app) {
      final matchesSearch = query.isEmpty ||
          app.companyName.toLowerCase().contains(query) ||
          app.positionTitle.toLowerCase().contains(query) ||
          (app.location?.toLowerCase().contains(query) ?? false);

      final matchesFavorite = !_onlyFavorites || app.isFavorite;

      final matchesStatus =
          _selectedStatusFilter == null || app.status == _selectedStatusFilter;

      return matchesSearch && matchesFavorite && matchesStatus;
    }).toList();

    if (_sortBy == 'newest') {
      list.sort((a, b) => b.appliedDate.compareTo(a.appliedDate));
    } else if (_sortBy == 'oldest') {
      list.sort((a, b) => a.appliedDate.compareTo(b.appliedDate));
    } else if (_sortBy == 'favorite') {
      list.sort((a, b) {
        if (a.isFavorite == b.isFavorite) {
          return b.appliedDate.compareTo(a.appliedDate);
        }
        return a.isFavorite ? -1 : 1;
      });
    } else if (_sortBy == 'name') {
      list.sort((a, b) =>
          a.companyName.toLowerCase().compareTo(b.companyName.toLowerCase()));
    }

    _lastFilterQuery = _searchQuery;
    _lastFilterStatus = _selectedStatusFilter;
    _lastFilterOnlyFav = _onlyFavorites;
    _lastFilterSortBy = _sortBy;
    _lastFilterAppHash = currentHash;
    _cachedFilteredApps = list;

    return list;
  }

  void closeSearch() {
    if (_isSearchOpen && mounted) {
      setState(() {
        _isSearchOpen = false;
        _searchQuery = '';
        _searchController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredApplications;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Standardized Top Header Row
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.applicationsTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        letterSpacing: -0.7,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCircleActionButton(
                        icon: _isSearchOpen
                            ? CupertinoIcons.xmark
                            : CupertinoIcons.search,
                        isDark: isDark,
                        isActive: _isSearchOpen,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isSearchOpen = !_isSearchOpen;
                            if (!_isSearchOpen) {
                              _searchQuery = '';
                              _searchController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildCircleActionButton(
                        icon: CupertinoIcons.plus,
                        isDark: isDark,
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          closeSearch();
                          final added = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ApplicationFormScreen(
                                  repository: widget.repository),
                            ),
                          );
                          if (added == true) _loadApplications();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Collapsible Search Bar (Only appears when search icon is clicked)
            if (_isSearchOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.8,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: AppStrings.searchApplicationPlaceholder,
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint,
                        fontSize: 13.5,
                      ),
                      prefixIcon: Icon(
                        CupertinoIcons.search,
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint,
                        size: 17,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                  CupertinoIcons.clear_circled_solid,
                                  size: 16),
                              color: isDark
                                  ? AppColors.textHintDark
                                  : AppColors.textHint,
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),

            // Notched Pill View Switcher (Daftar vs Kanban)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: NotchedPillCard<bool>(
                items: [
                  NotchedPillItem(
                    value: false,
                    label: AppStrings.listView,
                    icon: CupertinoIcons.list_bullet,
                  ),
                  NotchedPillItem(
                    value: true,
                    label: AppStrings.kanbanBoard,
                    icon: CupertinoIcons.square_grid_2x2,
                  ),
                ],
                selectedValue: _isKanbanView,
                onValueChanged: (val) => setState(() => _isKanbanView = val),
              ),
            ),

            // Horizontal Status Filter Pills with Soft Edge Gradient Fade
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.04, 0.96, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    _buildPill(
                      label: AppStrings.allStatusTab,
                      isSelected: !_onlyFavorites && _selectedStatusFilter == null,
                      onTap: () {
                        setState(() {
                          _onlyFavorites = false;
                          _selectedStatusFilter = null;
                        });
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildPill(
                      label: AppStrings.starred,
                      isSelected: _onlyFavorites,
                      onTap: () {
                        setState(() {
                          _onlyFavorites = true;
                          _selectedStatusFilter = null;
                        });
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    ...ApplicationStatus.values.map(
                      (status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildPill(
                          label: status.label,
                          isSelected: !_onlyFavorites && _selectedStatusFilter == status,
                          onTap: () {
                            setState(() {
                              _onlyFavorites = false;
                              _selectedStatusFilter = status;
                            });
                          },
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sub-header Toolbar: Application Count & Moved Sort Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LanguageManager.isEnglish
                        ? '${filtered.length} Application${filtered.length == 1 ? '' : 's'}'
                        : '${filtered.length} Lamaran',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  _buildSortButton(isDark),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Content List / Kanban View
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: AppliqLoading(),
                      ),
                    )
                  : filtered.isEmpty
                      ? _buildEmptyState(isDark)
                      : _isKanbanView
                          ? _buildKanbanView(isDark)
                          : RefreshIndicator(
                              onRefresh: () =>
                                  _loadApplications(forceRefresh: true),
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 4, 16, 150),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final app = filtered[index];
                                  return ApplicationCard(
                                    application: app,
                                    onTap: () async {
                                      closeSearch();
                                      final updated =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ApplicationDetailScreen(
                                            applicationId: app.id,
                                            repository: widget.repository,
                                          ),
                                        ),
                                      );
                                      if (updated == true) _loadApplications();
                                    },
                                    onToggleFavorite: () =>
                                        _toggleFavorite(app),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(bool isDark) {
    final isEn = LanguageManager.isEnglish;
    String sortLabel = isEn ? 'Newest' : 'Terbaru';
    if (_sortBy == 'oldest') sortLabel = isEn ? 'Oldest' : 'Terlama';
    if (_sortBy == 'favorite') sortLabel = isEn ? 'Starred' : 'Ditandai';
    if (_sortBy == 'name') sortLabel = isEn ? 'Name A-Z' : 'Nama A-Z';

    return PopupMenuButton<String>(
      tooltip: AppStrings.sort,
      initialValue: _sortBy,
      onSelected: (val) {
        HapticFeedback.selectionClick();
        setState(() => _sortBy = val);
      },
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF27272A) : Colors.white,
      itemBuilder: (context) => [
        PopupMenuItem(value: 'newest', child: Text(AppStrings.sortNewest)),
        PopupMenuItem(value: 'oldest', child: Text(AppStrings.sortOldest)),
        PopupMenuItem(
          value: 'favorite',
          child: Text(isEn ? 'Starred First' : 'Ditandai Dahulu'),
        ),
        PopupMenuItem(
          value: 'name',
          child: Text(AppStrings.sortCompanyAZ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.arrow_up_arrow_down,
              size: 12,
              color: isDark ? Colors.white70 : const Color(0xFF52525B),
            ),
            const SizedBox(width: 5),
            Text(
              sortLabel,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              CupertinoIcons.chevron_down,
              size: 10,
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required bool isDark,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? Colors.white : const Color(0xFF18181B))
              : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5)),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? (isDark ? Colors.white : const Color(0xFF18181B))
                : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7)),
            width: 0.8,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: isActive
                ? (isDark ? const Color(0xFF18181B) : Colors.white)
                : (isDark ? Colors.white : const Color(0xFF18181B)),
          ),
        ),
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : const Color(0xFF18181B))
              : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5)),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF18181B))
                : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7)),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: -0.2,
            color: isSelected
                ? (isDark ? const Color(0xFF18181B) : Colors.white)
                : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A)),
          ),
        ),
      ),
    );
  }

  Widget _buildKanbanView(bool isDark) {
    final statuses = ApplicationStatus.values;
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: statuses.length,
      itemBuilder: (context, colIndex) {
        final status = statuses[colIndex];
        final appsInStatus = _applications.where((a) {
          final matchesFavorite = !_onlyFavorites || a.isFavorite;
          final matchesSearch = _searchQuery.isEmpty ||
              a.companyName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              a.positionTitle
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (a.location
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false);
          return a.status == status && matchesFavorite && matchesSearch;
        }).toList();
        return RepaintBoundary(
          child: Container(
            width: 280,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withValues(alpha: 0.5)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(status: status, isCompact: true),
                      Text(
                        '${appsInStatus.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                    height: 1,
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight),
                Expanded(
                  child: appsInStatus.isEmpty
                      ? Center(
                          child: Text(
                            LanguageManager.isEnglish ? 'Empty' : 'Kosong',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textHintDark
                                  : AppColors.textHint,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: appsInStatus.length,
                          itemBuilder: (context, idx) {
                            final app = appsInStatus[idx];
                            return ApplicationCard(
                              application: app,
                              onTap: () async {
                                closeSearch();
                                final updated =
                                    await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ApplicationDetailScreen(
                                      applicationId: app.id,
                                      repository: widget.repository,
                                    ),
                                  ),
                                );
                                if (updated == true) _loadApplications();
                              },
                              onToggleFavorite: () => _toggleFavorite(app),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final isEn = LanguageManager.isEnglish;
    return EmptyStateView(
      icon: CupertinoIcons.tray,
      title: isEn ? 'No Applications Yet' : 'Belum Ada Lamaran',
      message: isEn
          ? 'Start tracking your job applications and interview stages neatly.'
          : 'Mulai catat lowongan dan tahapan lamaran kerjamu dengan rapi.',
      action: ElevatedButton.icon(
        onPressed: () async {
          final added = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ApplicationFormScreen(repository: widget.repository),
            ),
          );
          if (added == true) _loadApplications();
        },
        icon: Icon(
          CupertinoIcons.plus,
          size: 16,
          color: isDark ? const Color(0xFF18181B) : Colors.white,
        ),
        label: Text(
          isEn ? 'New Application' : 'Catat Lamaran Baru',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: isDark ? const Color(0xFF18181B) : Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
          foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        ),
      ),
    );
  }
}
