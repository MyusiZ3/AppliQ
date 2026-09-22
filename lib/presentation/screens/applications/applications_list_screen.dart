import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../data/models/job_application.dart';
import '../../../data/repositories/job_repository.dart';
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
        titleSpacing: 20,
        title: Text(
          'Pelacak Lamaran',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // Search Toggle Button (Circular Pill as in reference image)
          _buildCircleActionButton(
            icon: _isSearchOpen ? CupertinoIcons.xmark : CupertinoIcons.search,
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

          // Add Application Button (Circular Pill as in reference image)
          _buildCircleActionButton(
            icon: CupertinoIcons.plus,
            isDark: isDark,
            onTap: () async {
              HapticFeedback.lightImpact();
              final added = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ApplicationFormScreen(repository: widget.repository),
                ),
              );
              if (added == true) _loadApplications();
            },
          ),
          const SizedBox(width: 8),

          // Sort Button (Circular Pill)
          PopupMenuButton<String>(
            tooltip: 'Urutkan',
            initialValue: _sortBy,
            onSelected: (val) => setState(() => _sortBy = val),
            offset: const Offset(0, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: isDark ? const Color(0xFF27272A) : Colors.white,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'newest', child: Text('Tanggal Terbaru')),
              const PopupMenuItem(value: 'oldest', child: Text('Tanggal Terlama')),
              const PopupMenuItem(value: 'name', child: Text('Nama Perusahaan (A-Z)')),
            ],
            child: _buildCircleActionButton(
              icon: CupertinoIcons.arrow_up_arrow_down,
              isDark: isDark,
              onTap: null,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Collapsible Search Bar (Only appears when search icon is clicked)
          if (_isSearchOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 0.8,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari perusahaan, posisi, atau lokasi...',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                      fontSize: 13.5,
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                      size: 17,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(CupertinoIcons.clear_circled_solid, size: 16),
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),

          // Notched Pill View Switcher (Daftar vs Kanban)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  _buildFilterPill('Semua', null, isDark),
                  const SizedBox(width: 8),
                  ...ApplicationStatus.values.map(
                    (status) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterPill(status.label, status, isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

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

  Widget _buildCircleActionButton({
    required IconData icon,
    required bool isDark,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
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
            size: 17,
            color: isActive
                ? (isDark ? const Color(0xFF18181B) : Colors.white)
                : (isDark ? Colors.white : const Color(0xFF18181B)),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, ApplicationStatus? status, bool isDark) {
    final isSelected = _selectedStatusFilter == status;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedStatusFilter = status);
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
        final appsInStatus = _applications.where((a) => a.status == status).toList();
        return RepaintBoundary(
          child: Container(
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
          ),
        );
      },
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
        icon: Icon(
          CupertinoIcons.plus,
          size: 16,
          color: isDark ? const Color(0xFF18181B) : Colors.white,
        ),
        label: Text(
          'Catat Lamaran Baru',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        ),
      ),
    );
  }
}
