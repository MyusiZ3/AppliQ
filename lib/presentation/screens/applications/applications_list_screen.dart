import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../data/models/job_application.dart';
import '../../../data/repositories/job_repository.dart';
import '../../widgets/application_card.dart';
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
  String _sortBy = 'newest'; // newest, oldest, name

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.repository.getApplications();
      setState(() {
        _applications = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat lamaran: $e')),
        );
      }
    }
  }

  Future<void> _toggleFavorite(JobApplication app) async {
    await widget.repository.toggleFavorite(app.id);
    _loadApplications();
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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pelacak Lamaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
            Text(
              '${_applications.length} Total Lamaran Tercatat',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isKanbanView ? Icons.view_list_outlined : Icons.view_column_outlined,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
            tooltip: _isKanbanView ? 'Tampilan Daftar' : 'Tampilan Kanban',
            onPressed: () {
              setState(() => _isKanbanView = !_isKanbanView);
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.sort,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
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
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari perusahaan atau posisi...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  size: 20,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Horizontal Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

          // Application Content (List or Kanban)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? _buildEmptyState(isDark)
                    : _isKanbanView
                        ? _buildKanbanView(isDark)
                        : RefreshIndicator(
                            onRefresh: _loadApplications,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80, top: 4),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Tambah Lamaran',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: () async {
          final added = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ApplicationFormScreen(repository: widget.repository),
            ),
          );
          if (added == true) _loadApplications();
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, ApplicationStatus? status, bool isDark) {
    final isSelected = _selectedStatusFilter == status;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (_) {
        setState(() => _selectedStatusFilter = status);
      },
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
            color: isDark ? AppColors.darkSurfaceSubtle.withValues(alpha: 0.3) : AppColors.lightSurfaceSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              Expanded(
                child: appsInStatus.isEmpty
                    ? Center(
                        child: Text(
                          'Kosong',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada lamaran ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah kata kunci pencarian atau filter status.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
