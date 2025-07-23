import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/bco_ranking_entity.dart';
import '../../../../core/presentation/widgets/app_bar_widget.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'member_ranking_page.dart';

class BcoRankingDetailPage extends StatefulWidget {
  final BcoRankingEntity ranking;
  final String year;
  final String month;
  const BcoRankingDetailPage(
      {Key? key,
      required this.ranking,
      required this.year,
      required this.month})
      : super(key: key);

  @override
  State<BcoRankingDetailPage> createState() => _BcoRankingDetailPageState();
}

class _BcoRankingDetailPageState extends State<BcoRankingDetailPage>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  final GlobalKey _expandDetailKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.7, curve: Curves.easeInOut)),
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack)),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Detail Peringkat BCO'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(context),
                  const SizedBox(height: 16),
                  _buildInfoSection(context),
                  const SizedBox(height: 16),
                  _buildPieChartSection(context),
                  const SizedBox(height: 16),
                  _buildExpandableDetail(context),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Ambil bcoId, year, month dari widget.ranking dan context
                  final bcoId = widget.ranking.userId;
                  final year = widget.year;
                  final month = widget.month;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MemberRankingPage(
                        bcoId: bcoId,
                        year: year,
                        month: month,
                      ),
                    ),
                  );
                },
                child: const Text('Lihat Peringkat Anggota'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
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
                  Icons.emoji_events,
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
                      widget.ranking.kodeRayon,
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
                label: 'Indikator',
                value: '${widget.ranking.indikator.length}',
              ),
              const SizedBox(width: 24),
              _buildHeaderInfoItem(
                icon: Icons.star,
                label: 'Total Nilai',
                value: widget.ranking.dataKpi.toStringAsFixed(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfoItem(
      {required IconData icon, required String label, required String value}) {
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

  Widget _buildInfoSection(BuildContext context) {
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
          _buildSummaryGrid(context),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context) {
    final totalAchievement = _calculateTotalAchievement();
    final averageAchievement = widget.ranking.indikator.isNotEmpty
        ? totalAchievement / widget.ranking.indikator.length
        : 0;
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            icon: Icons.trending_up,
            label: 'Rata-rata Nilai',
            value: averageAchievement.toStringAsFixed(1),
            color: _getAchievementColor(
                context,
                averageAchievement is num
                    ? (averageAchievement as num).toDouble()
                    : 0.0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            icon: Icons.assessment,
            label: 'Total Indikator',
            value: '${widget.ranking.indikator.length}',
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
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
              color: AppTheme.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartSection(BuildContext context) {
    final totalNilai = _calculateTotalAchievement();
    final indikator = widget.ranking.indikator;
    final List<Color> colorList = [
      const Color(0xFF4CAF50), // CALL RATE
      const Color(0xFF2196F3), // COVERAGE
      const Color(0xFF3F51B5), // ACHIEVEMENT
      const Color(0xFF9C27B0), // PRODUCT NPL
      const Color(0xFF673AB7), // PRODUCT SL
      const Color(0xFF00BCD4), // QUIS
      const Color(0xFFFF9800), // KEHADIRAN DAN KEDISIPLINAN
    ];
    return Container(
      height: 220,
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
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: PieChart(
                          PieChartData(
                            sections: List.generate(indikator.length, (i) {
                              final value =
                                  double.tryParse(indikator[i].nilai) ?? 0.0;
                              final percent = totalNilai > 0
                                  ? (value / totalNilai) * 100
                                  : 0.0;
                              return PieChartSectionData(
                                color: colorList[i % colorList.length],
                                value: value,
                                title: percent > 5
                                    ? '${percent.toStringAsFixed(0)}%'
                                    : '',
                                radius: 50,
                                titleStyle: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                titlePositionPercentageOffset: 0.6,
                                showTitle: percent > 5,
                              );
                            }),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            startDegreeOffset: 270,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Total\nNilai',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.getSecondaryTextColor(context),
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 2),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: totalNilai,
                          ),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                value.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Indikator:',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(indikator.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colorList[i % colorList.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                indikator[i].indikator,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableDetail(BuildContext context) {
    return Container(
      key: _expandDetailKey,
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
        children: [
          // Header with toggle button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Kinerja',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).primaryColor),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                    if (_isExpanded) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        final ctx = _expandDetailKey.currentContext;
                        if (ctx != null) {
                          Scrollable.ensureVisible(
                            ctx,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                            alignment: 0.1,
                          );
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isExpanded ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildIndikatorGrid(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndikatorGrid(BuildContext context) {
    final List<Color> colorList = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFF3F51B5),
      const Color(0xFF9C27B0),
      const Color(0xFF673AB7),
      const Color(0xFF00BCD4),
      const Color(0xFFFF9800),
    ];
    final numberFormat = NumberFormat.decimalPattern('id');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.ranking.indikator.length,
      itemBuilder: (context, index) {
        final item = widget.ranking.indikator[index];
        final achievement = double.tryParse(item.nilai) ?? 0.0;
        final color = colorList[index % colorList.length];
        String formatValue(String? value) {
          if (value == null) return '-';
          final num? n = num.tryParse(value);
          if (n == null) return value;
          return numberFormat.format(n);
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.indikator,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMetricRow(
                        label: 'Target',
                        value: formatValue(item.target),
                        context: context),
                    _buildMetricRow(
                        label: 'Realisasi',
                        value: formatValue(item.realisasi?.toString()),
                        context: context),
                    _buildMetricRow(
                        label: 'Nilai',
                        value: formatValue(item.nilai),
                        context: context),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (achievement / 100).clamp(0.0, 1.0),
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricRow(
      {required String label,
      required String value,
      required BuildContext context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.getPrimaryTextColor(context),
          ),
        ),
      ],
    );
  }

  double _calculateTotalAchievement() {
    double total = 0;
    for (var indikator in widget.ranking.indikator) {
      total += double.tryParse(indikator.nilai) ?? 0;
    }
    return total;
  }

  Color _getAchievementColor(BuildContext context, double achievement) {
    if (achievement >= 91) {
      return AppTheme.getSuccessColor(context);
    } else if (achievement >= 76) {
      return AppTheme.getPrimaryColor(context);
    } else if (achievement >= 66) {
      return AppTheme.getWarningColor(context);
    } else if (achievement >= 51) {
      return AppTheme.getWarningColor(context);
    } else {
      return AppTheme.getErrorColor(context);
    }
  }
}
