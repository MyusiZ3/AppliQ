import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../data/models/job_application.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/application_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/notched_pill_card.dart';
import '../../widgets/status_badge.dart';
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
  ApplicationStatus? _selectedStatusFilter;
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
    super.dispose();
  }

  Future<void> _loadApplications({bool isSilent = false, bool forceRefresh = false}) async {
    if (!isSilent) setState(() => _isLoading = true);
    try {
      final data = await widget.repository.getApplications(forceRefresh: forceRefresh);
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

  List<JobApplication> get _filteredApplications {
    var list = _applications.where((app) {
      final matchesSearch = app.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app.positionTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (app.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesStatus = _selectedStatusFilter == null || app.status == _selectedStatusFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    if (_sortBy == 'newest') {
      list.sort((a, b) => b.appliedDate.compareTo(a.appliedDate));
    } else if (_sortBy == 'oldest') {
      list.sort((a, b) => a.appliedDate.compareTo(b.appliedDate));
    } else if (_sortBy == 'name') {
      list.sort((a, b) => a.companyName.toLowerCase().compareTo(b.companyName.toLowerCase()));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredApplications;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Pelacak Lamaran',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.plus,
              color: isDark ? Colors.white : const Color(0xFF18181B),
              size: 22,
            ),
            tooltip: 'Catat Lamaran',
            onPressed: () async {
              final added = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ApplicationFormScreen(repository: widget.repository),
                ),
              );
              if (added == true) _loadApplications();
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(
              CupertinoIcons.sort_down,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              size: 20,
            ),
            tooltip: 'Urutkan',
            initialValue: _sortBy,
            onSelected: (val) => setState(() => _sortBy = val),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'newest', child: Text('Tanggal Terbaru')),
              const PopupMenuItem(value: 'oldest', child: Text('Tanggal Terlama')),
              const PopupMenuItem(value: 'name', child: Text('Nama Perusahaan (A-Z)')),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Notched Pill View Switcher
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: NotchedPillCard<bool>(
              items: const [
                NotchedPillItem(
                  value: false,
                  label: 'Tampilan List',
                  icon: CupertinoIcons.list_bullet,
                ),
                NotchedPillItem(
                  value: true,
                  label: 'Papan Kanban',
                  icon: CupertinoIcons.square_grid_2x2,
                ),
              ],
              selectedValue: _isKanbanView,
              onValueChanged: (val) => setState(() => _isKanbanView = val),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Cari perusahaan, posisi, atau kota...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  size: 18,
                ),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 0.8,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 0.8,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Horizontal Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                _buildFilterChip('Semua', null, isDark),
                const SizedBox(width: 6),
                ...ApplicationStatus.values.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildFilterChip(status.label, status, isDark),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : filtered.isEmpty
                    ? _buildEmptyState(isDark)
                    : _isKanbanView
                        ? _buildKanbanView(isDark)
                        : RefreshIndicator(
                            onRefresh: () => _loadApplications(forceRefresh: true),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 150),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final app = filtered[index];
                                return ApplicationCard(
                                  application: app,
                                  onTap: () async {
                                    final updated = await Navigator.of(context).push(
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ApplicationStatus? status, bool isDark) {
    final isSelected = _selectedStatusFilter == status;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: -0.2,
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.borderDark : AppColors.borderLight),
        width: 0.8,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      onSelected: (_) => setState(() => _selectedStatusFilter = status),
    );
  }

  Widget _buildKanbanView(bool isDark) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: ApplicationStatus.values.map((status) {
        final appsInStatus = _applications.where((a) => a.status == status).toList();
        return Container(
          width: 280,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.5) : AppColors.surfaceVariant,
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
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
              Expanded(
                child: appsInStatus.isEmpty
                    ? Center(
                        child: Text(
                          'Kosong',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
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
                              final updated = await Navigator.of(context).push(
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
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return EmptyStateView(
      icon: CupertinoIcons.tray,
      title: 'Belum Ada Lamaran',
      message: 'Mulai catat lowongan dan tahapan lamaran kerjamu dengan rapi.',
      action: ElevatedButton.icon(
        onPressed: () async {
          final added = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ApplicationFormScreen(repository: widget.repository),
            ),
          );
          if (added == true) _loadApplications();
        },
        icon: const Icon(CupertinoIcons.plus, size: 16),
        label: const Text('Catat Lamaran Baru'),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}
