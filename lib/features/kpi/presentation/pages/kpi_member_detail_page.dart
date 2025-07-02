import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/kpi_member.dart';
import '../widgets/kpi_chart_new.dart';
import '../../../../core/presentation/widgets/app_bar_widget.dart';

class KpiMemberDetailPage extends StatefulWidget {
  final KpiMember kpiMember;
  final String year;
  final String month;

  const KpiMemberDetailPage({
    Key? key,
    required this.kpiMember,
    required this.year,
    required this.month,
  }) : super(key: key);

  @override
  State<KpiMemberDetailPage> createState() => _KpiMemberDetailPageState();
}

class _KpiMemberDetailPageState extends State<KpiMemberDetailPage> {
  final GlobalKey _chartSectionKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Detail KPI',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 16),
            _buildInfoSection(),
            const SizedBox(height: 16),
            _buildChartSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kode Rayon',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.kpiMember.kodeRayon,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeaderInfoItem(
                icon: Icons.bar_chart,
                label: 'Indikator KPI',
                value: '${widget.kpiMember.grafik.length}',
              ),
              const SizedBox(width: 24),
              _buildHeaderInfoItem(
                icon: Icons.calendar_today,
                label: 'Periode',
                value: DateFormat('MMMM yyyy', 'id_ID').format(
                    DateTime(int.parse(widget.year), int.parse(widget.month))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Kinerja',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryGrid(),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    final totalAchievement = _calculateTotalAchievement();
    final averageAchievement =
        totalAchievement / widget.kpiMember.grafik.length;
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.trending_up,
            label: 'Rata-rata Achievement',
            value: '${averageAchievement.toStringAsFixed(1)}%',
            color: _getAchievementColor(averageAchievement),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.assessment,
            label: 'Total Indikator',
            value: '${widget.kpiMember.grafik.length}',
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      key: _chartSectionKey,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: KpiChartNew(
        kpiData: widget.kpiMember.grafik,
        onRefresh: () {
          // Refresh functionality if needed
        },
        onFilterChanged: (year, month) {
          // Filter functionality if needed
        },
        currentYear: widget.year,
        currentMonth: widget.month,
        isFilterEnabled: false,
        onExpansionChanged: (isExpanded) {
          // Auto scroll ketika expansion tile dibuka di detail page
          if (isExpanded) {
            Future.delayed(const Duration(milliseconds: 300), () {
              final context = _chartSectionKey.currentContext;
              if (context != null) {
                Scrollable.ensureVisible(
                  context,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  alignment: 0.0, // Scroll ke bagian atas chart
                );
              }
            });
          }
        },
      ),
    );
  }

  double _calculateTotalAchievement() {
    double total = 0;
    for (var grafik in widget.kpiMember.grafik) {
      total += double.tryParse(grafik.data.ach) ?? 0;
    }
    return total;
  }

  Color _getAchievementColor(double achievement) {
    if (achievement >= 100) {
      return Colors.green;
    } else if (achievement >= 80) {
      return Colors.blue;
    } else if (achievement >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
} 
