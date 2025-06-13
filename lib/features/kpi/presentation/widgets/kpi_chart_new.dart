import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:test_cbo/features/kpi/data/models/kpi_model.dart';
import 'package:google_fonts/google_fonts.dart';

class KpiChartNew extends StatefulWidget {
  final List<KpiGrafik> kpiData;
  final VoidCallback onRefresh;

  const KpiChartNew({
    Key? key, 
    required this.kpiData,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<KpiChartNew> createState() => _KpiChartNewState();
}

class _KpiChartNewState extends State<KpiChartNew> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Inisialisasi semua animasi
    _initializeAnimations();

    // Mulai animasi
    _animationController.forward();
  }

  void _initializeAnimations() {
    // Rotation animation untuk pie chart
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    ));

    // Scale animation untuk pie chart dan cards
    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    // Slide animation untuk kategori kinerja
    _slideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1, curve: Curves.easeOutBack),
    ));

    // Fade animation untuk kategori kinerja
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1, curve: Curves.easeOut),
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
      return _buildEmptyState();
    }

    final totalAchievement = _calculateTotalAchievement();

    return Column(
      children: [
        // Pie Chart Section
        _buildPieChartSection(),
        
        const SizedBox(height: 16),
        // Performance Category Section
        _buildPerformanceCategory(totalAchievement),
        
        const SizedBox(height: 16),
        // Expandable Detail Section
        _buildExpandableDetail(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Tidak ada data KPI'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableDetail() {
    return Container(
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
                    ? (((_animationController.value - delay) / 0.2).clamp(0.0, 1.0))
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
    final color = Color(int.parse(item.backgroundColor.replaceAll('#', '0xFF')));

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
                    valueColor: _getAchievementColor(double.parse(item.data.ach)),
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

  Widget _buildPieChartSection() {
    if (widget.kpiData.isEmpty) {
      return Container();
    }

    final totalAchievement = _calculateTotalAchievement();

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: _createPieSections(),
                            pieTouchData: PieTouchData(
                              enabled: true,
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                // Handle touch events if needed
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(8),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: totalAchievement,
                            ),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Text(
                                '${value.toStringAsFixed(1)}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _getAchievementColor(value),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.kpiData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final delay = index * 0.2;
                        final opacity = _animationController.value > delay
                            ? (((_animationController.value - delay) / 0.2).clamp(0.0, 1.0))
                            : 0.0;
                        return Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(20 * (1 - opacity), 0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Color(int.parse(item.backgroundColor.replaceAll('#', '0xFF'))),
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
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createPieSections() {
    return widget.kpiData.map((item) {
      final weight = double.tryParse(item.data.bobot) ?? 0.0;
      final color = Color(int.parse(item.backgroundColor.replaceAll('#', '0xFF')));
      
      return PieChartSectionData(
        color: color,
        value: weight,
        title: '${weight.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        showTitle: false,
      );
    }).toList();
  }

  double _calculateTotalAchievement() {
    double totalAchievement = 0;
    double totalWeight = 0;

    for (var item in widget.kpiData) {
      final achievement = double.tryParse(item.data.ach) ?? 0.0;
      final weight = double.tryParse(item.data.bobot) ?? 0.0;
      totalAchievement += (achievement * weight / 100);
      totalWeight += weight;
    }

    return totalWeight > 0 ? (totalAchievement / totalWeight) * 100 : 0;
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
        color: isActive 
            ? color.withOpacity(0.18) 
            : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive 
              ? color 
              : color.withOpacity(0.2),
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
      CategoryData('Sangat Buruk', '0-50', Colors.red, 0, 50, Icons.sentiment_very_dissatisfied),
      CategoryData('Buruk', '51-65', Colors.orange, 51, 65, Icons.sentiment_dissatisfied),
      CategoryData('Cukup', '66-75', Colors.yellow.shade700, 66, 75, Icons.sentiment_neutral),
      CategoryData('Baik', '76-90', Colors.blue, 76, 90, Icons.sentiment_satisfied),
      CategoryData('Sangat Baik', '91-100', Colors.green, 91, 100, Icons.sentiment_very_satisfied),
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

  Widget _buildPerformanceCategory(double totalAchievement) {
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
                        ),
                      ),
                      const Spacer(),
                      _buildCurrentCategoryBadge(totalAchievement),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _buildCategoryCards(totalAchievement),
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

  Widget _buildCurrentCategoryBadge(double totalAchievement) {
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
              color: _getCategoryColor(totalAchievement),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getCategoryColor(totalAchievement).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(totalAchievement),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _getCategoryLabel(totalAchievement),
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