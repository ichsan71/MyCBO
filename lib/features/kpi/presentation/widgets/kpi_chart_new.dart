import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:test_cbo/features/kpi/data/models/kpi_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class KpiChartNew extends StatefulWidget {
  final List<KpiGrafik> kpiData;
  final VoidCallback onRefresh;
  final Function(String year, String month) onFilterChanged;
  final String currentYear;
  final String currentMonth;
  final bool isFilterEnabled;
  final Function(bool)? onExpansionChanged;

  const KpiChartNew({
    Key? key,
    required this.kpiData,
    required this.onRefresh,
    required this.onFilterChanged,
    required this.currentYear,
    required this.currentMonth,
    this.isFilterEnabled = true,
    this.onExpansionChanged,
  }) : super(key: key);

  @override
  State<KpiChartNew> createState() => _KpiChartNewState();
}

class _KpiChartNewState extends State<KpiChartNew>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;
  late String _selectedYear;
  late String _selectedMonth;
  final GlobalKey _expandableDetailKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    debugPrint(
        'KpiChartNew - Initializing with year: ${widget.currentYear}, month: ${widget.currentMonth}');
    _selectedYear = widget.currentYear;
    _selectedMonth = widget.currentMonth;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _initializeAnimations();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(KpiChartNew oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update selected values if they changed from parent
    if (oldWidget.currentYear != widget.currentYear ||
        oldWidget.currentMonth != widget.currentMonth) {
      debugPrint(
          'KpiChartNew - Updating to year: ${widget.currentYear}, month: ${widget.currentMonth}');

      // Reset animations for new data
      _animationController.reset();

      setState(() {
        _selectedYear = widget.currentYear;
        _selectedMonth = widget.currentMonth;
      });

      // Start animations
      _animationController.forward();
    }
  }

  void _initializeAnimations() {
    // Rotation animation untuk pie chart
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));

    // Scale animation untuk pie chart dan cards
    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));

    // Slide animation untuk kategori kinerja
    _slideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
    ));

    // Fade animation untuk kategori kinerja
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.kpiData.isEmpty) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterSection(),
            const SizedBox(height: 32),
            Icon(
              Icons.bar_chart_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Data KPI tidak tersedia untuk periode ini',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final totalNilai = _calculateTotalNilai();

    return Column(
      children: [
        _buildFilterSection(),
        const SizedBox(height: 16),
        _buildPieChartSection(totalNilai),
        const SizedBox(height: 16),
        _buildPerformanceCategory(totalNilai),
        const SizedBox(height: 16),
        _buildExpandableDetail(),
      ],
    );
  }

  Widget _buildFilterSection() {
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
      child: Row(
        children: [
          Expanded(
            child: widget.isFilterEnabled
                ? InkWell(
                    onTap: () => _showMonthYearPicker(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMMM yyyy', 'id_ID').format(
                              DateTime(
                                int.parse(_selectedYear),
                                int.parse(_selectedMonth),
                              ),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  )
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy', 'id_ID').format(
                            DateTime(
                              int.parse(_selectedYear),
                              int.parse(_selectedMonth),
                            ),
                          ),
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey[600]),
                        ),
                        const Icon(Icons.calendar_today,
                            size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMonthYearPicker() async {
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: DateTime(
        int.parse(_selectedYear),
        int.parse(_selectedMonth),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
    );

    if (selected != null) {
      debugPrint(
          'KpiChartNew - Month/Year picked: ${selected.year}-${selected.month.toString().padLeft(2, '0')}');

      // Reset animations for new data
      _animationController.reset();

      setState(() {
        _selectedYear = selected.year.toString();
        _selectedMonth = selected.month.toString().padLeft(2, '0');
      });

      // Notify parent of date change
      widget.onFilterChanged(_selectedYear, _selectedMonth);

      // Start animations
      _animationController.forward();
    }
  }

  double _calculateTotalNilai() {
    double totalNilai = 0;
    for (var item in widget.kpiData) {
      final nilai = double.tryParse(item.data.nilai) ?? 0.0;
      totalNilai += nilai;
    }
    return totalNilai;
  }

  Widget _buildExpandableDetail() {
    return Container(
      key: _expandableDetailKey,
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });

            // Panggil callback eksternal jika ada (untuk detail page)
            if (widget.onExpansionChanged != null) {
              widget.onExpansionChanged!(expanded);
            } else {
              // Auto scroll internal hanya jika tidak ada callback eksternal
              if (expanded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final context = _expandableDetailKey.currentContext;
                  if (context != null) {
                    Scrollable.ensureVisible(
                      context,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      alignment:
                          0.1, // Scroll sedikit dari atas agar tidak terpotong
                    );
                  }
                });
              }
            }
          },
          title: Text(
            'Detail Kinerja',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildKpiCardsGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCardsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.95,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.kpiData.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.1;
            final scale = _isExpanded
                ? (_animationController.value > delay
                    ? (((_animationController.value - delay) / 0.2)
                        .clamp(0.0, 1.0))
                    : 0.0)
                : 1.0;

            return _buildKpiCard(index, scale);
          },
        );
      },
    );
  }

  Widget _buildKpiCard(int index, double scale) {
    final item = widget.kpiData[index];
    final achievement = double.tryParse(item.data.ach) ?? 0.0;
    final color =
        Color(int.parse(item.backgroundColor.replaceAll('#', '0xFF')));

    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.all(12),
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
          mainAxisSize: MainAxisSize.min,
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
                    item.label,
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
                    value: item.data.target,
                    context: context,
                  ),
                  _buildMetricRow(
                    label: 'Realisasi',
                    value: item.data.realisasi ?? '-',
                    context: context,
                  ),
                  _buildMetricRow(
                    label: 'Achievement',
                    value: '${item.data.ach}%',
                    valueColor:
                        _getAchievementColor(double.parse(item.data.ach)),
                    context: context,
                  ),
                  _buildMetricRow(
                    label: 'Nilai',
                    value: item.data.nilai,
                    context: context,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: achievement / 100,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSection(double totalNilai) {
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
                            sections: widget.kpiData.map((item) {
                              final achievement =
                                  double.tryParse(item.data.ach) ?? 0.0;
                              final color = Color(int.parse(item.backgroundColor
                                  .replaceAll('#', '0xFF')));

                              return PieChartSectionData(
                                color: color,
                                value: achievement,
                                title: achievement > 5
                                    ? '${achievement.toStringAsFixed(0)}%'
                                    : '',
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
                                radius: 50,
                                titlePositionPercentageOffset: 0.6,
                                showTitle: achievement > 5,
                              );
                            }).toList(),
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
                              color: Colors.grey[600],
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
                                  color: _getAchievementColor(value),
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
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.kpiData.map((item) {
                      debugPrint('Building legend item: ${item.label}');

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
                                color: Color(int.parse(item.backgroundColor
                                    .replaceAll('#', '0xFF'))),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.label,
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
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  // Helper method untuk membangun baris metrik
  Widget _buildMetricRow({
    required String label,
    required String value,
    Color? valueColor,
    required BuildContext context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  // Helper method untuk mendapatkan warna kategori
  Color _getCategoryColor(double value) {
    if (value >= 91) {
      return Colors.green;
    } else if (value >= 76) {
      return Colors.blue;
    } else if (value >= 66) {
      return Colors.yellow.shade700;
    } else if (value >= 51) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // Helper method untuk mendapatkan label kategori
  String _getCategoryLabel(double value) {
    if (value >= 91) {
      return 'Sangat Baik';
    } else if (value >= 76) {
      return 'Baik';
    } else if (value >= 66) {
      return 'Cukup';
    } else if (value >= 51) {
      return 'Buruk';
    } else {
      return 'Sangat Buruk';
    }
  }

  // Helper method untuk mendapatkan icon kategori
  IconData _getCategoryIcon(double value) {
    if (value >= 91) {
      return Icons.sentiment_very_satisfied;
    } else if (value >= 76) {
      return Icons.sentiment_satisfied;
    } else if (value >= 66) {
      return Icons.sentiment_neutral;
    } else if (value >= 51) {
      return Icons.sentiment_dissatisfied;
    } else {
      return Icons.sentiment_very_dissatisfied;
    }
  }

  // Helper method untuk membangun kartu kategori (diperbarui)
  Widget _buildCategoryCard(
    String label,
    String range,
    Color color,
    IconData icon,
    bool isActive,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
      width: 90,
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.18) : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : color.withOpacity(0.2),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? color : color.withOpacity(0.7),
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? color : color.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            range,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isActive ? color : color.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryCards(double currentValue) {
    final categories = [
      CategoryData('Sangat Buruk', '0-50', Colors.red, 0, 50,
          Icons.sentiment_very_dissatisfied),
      CategoryData('Buruk', '51-65', Colors.orange, 51, 65,
          Icons.sentiment_dissatisfied),
      CategoryData('Cukup', '66-75', Colors.yellow.shade700, 66, 75,
          Icons.sentiment_neutral),
      CategoryData(
          'Baik', '76-90', Colors.blue, 76, 90, Icons.sentiment_satisfied),
      CategoryData('Sangat Baik', '91-100', Colors.green, 91, 100,
          Icons.sentiment_very_satisfied),
    ];

    return categories.map((category) {
      final isActive = currentValue >= category.minValue &&
          currentValue <= category.maxValue;
      return _buildCategoryCard(
        category.label,
        category.range,
        category.color,
        category.icon,
        isActive,
      );
    }).toList();
  }

  Widget _buildPerformanceCategory(double totalNilai) {
    return Container(
      width: double.infinity,
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
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Kategori Kinerja',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Spacer(),
                      _buildCurrentCategoryBadge(totalNilai),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _buildCategoryCards(totalNilai),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentCategoryBadge(double totalNilai) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _getCategoryColor(totalNilai),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getCategoryColor(totalNilai).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(totalNilai),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _getCategoryLabel(totalNilai),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CategoryData {
  final String label;
  final String range;
  final Color color;
  final double minValue;
  final double maxValue;
  final IconData icon;

  CategoryData(
    this.label,
    this.range,
    this.color,
    this.minValue,
    this.maxValue,
    this.icon,
  );
}
