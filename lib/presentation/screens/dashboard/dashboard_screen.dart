import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/job_repository.dart';
import '../../widgets/metric_card.dart';

class DashboardScreen extends StatefulWidget {
  final JobRepository repository;

  const DashboardScreen({super.key, required this.repository});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.repository.getDashboardStats();
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final total = _stats['total_applications'] as int? ?? 0;
    final applied = _stats['applied_count'] as int? ?? 0;
    final interview = _stats['interview_count'] as int? ?? 0;
    final offering = _stats['offering_count'] as int? ?? 0;
    final accepted = _stats['accepted_count'] as int? ?? 0;
    final rejected = _stats['rejected_count'] as int? ?? 0;
    final noResponse = _stats['no_response_count'] as int? ?? 0;

    final byWorkSystem = Map<String, dynamic>.from(_stats['by_work_system'] as Map? ?? {});
    final byPortal = Map<String, dynamic>.from(_stats['by_portal'] as Map? ?? {});

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          'Analitik & Statistik',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // KPI Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      MetricCard(
                        label: 'Total Lamaran',
                        value: '$total',
                        icon: Icons.assignment_outlined,
                        accentColor: AppColors.primary,
                      ),
                      MetricCard(
                        label: 'Interview',
                        value: '$interview',
                        icon: Icons.record_voice_over_outlined,
                        accentColor: AppColors.statusInterview,
                      ),
                      MetricCard(
                        label: 'Offering',
                        value: '$offering',
                        icon: Icons.card_giftcard_outlined,
                        accentColor: AppColors.statusOffering,
                      ),
                      MetricCard(
                        label: 'Diterima',
                        value: '$accepted',
                        icon: Icons.verified_outlined,
                        accentColor: AppColors.statusAccepted,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Status Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distribusi Status Lamaran',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressBarRow('Applied', applied, total, AppColors.statusApplied, isDark),
                        const SizedBox(height: 10),
                        _buildProgressBarRow('Interview', interview, total, AppColors.statusInterview, isDark),
                        const SizedBox(height: 10),
                        _buildProgressBarRow('Offering', offering, total, AppColors.statusOffering, isDark),
                        const SizedBox(height: 10),
                        _buildProgressBarRow('Accepted', accepted, total, AppColors.statusAccepted, isDark),
                        const SizedBox(height: 10),
                        _buildProgressBarRow('Rejected', rejected, total, AppColors.statusRejected, isDark),
                        const SizedBox(height: 10),
                        _buildProgressBarRow('No Response', noResponse, total, AppColors.statusNoResponse, isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Work System Distribution
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sistem Kerja',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...byWorkSystem.entries.map((entry) {
                          final count = entry.value as int;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildProgressBarRow(
                              entry.key,
                              count,
                              total,
                              AppColors.primary,
                              isDark,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Portal Breakdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sumber Portal Loker',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...byPortal.entries.map((entry) {
                          final count = entry.value as int;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildProgressBarRow(
                              entry.key,
                              count,
                              total,
                              AppColors.statusInterview,
                              isDark,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressBarRow(String label, int count, int total, Color color, bool isDark) {
    final ratio = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    final percentage = (ratio * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
            Text(
              '$count ($percentage%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
