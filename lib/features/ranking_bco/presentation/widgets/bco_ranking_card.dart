import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/bco_ranking_entity.dart';
import '../../../../core/presentation/theme/app_theme.dart';

class BcoRankingCard extends StatelessWidget {
  final BcoRankingEntity ranking;
  final int index;
  final VoidCallback? onTap;
  const BcoRankingCard(
      {Key? key, required this.ranking, required this.index, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalNilai = double.tryParse(ranking.dataKpi.toString()) ?? 0.0;
    // Trophy color logic
    Color trophyColor;
    switch (index) {
      case 0:
        trophyColor = const Color(0xFFFFD700); // Gold
        break;
      case 1:
        trophyColor = const Color(0xFFC0C0C0); // Silver
        break;
      case 2:
        trophyColor = const Color(0xFFCD7F32); // Bronze
        break;
      default:
        trophyColor = Theme.of(context).primaryColor; // Biru default
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16, left: 2, right: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Trophy with rank number inside
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 40,
                            color: trophyColor,
                          ),
                          Positioned(
                            top: 8, // lebih naik ke atas
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kode Rayon',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.getSecondaryTextColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ranking.kodeRayon,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
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
                      _buildInfoItem(
                        context,
                        icon: Icons.bar_chart,
                        label: 'Indikator',
                        value: '${ranking.indikator.length}',
                      ),
                      const SizedBox(width: 24),
                      _buildInfoItem(
                        context,
                        icon: Icons.star,
                        label: 'Total Nilai',
                        value: totalNilai.toStringAsFixed(1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Badge status di kanan atas
            Positioned(
              top: 12,
              right: 12,
              child: _buildCategoryBadge(context, totalNilai),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.getSecondaryTextColor(context),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.getPrimaryTextColor(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(BuildContext context, double value) {
    final color = _getCategoryColor(context, value);
    final icon = _getCategoryIcon(value);
    final label = _getCategoryLabel(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(BuildContext context, double value) {
    if (value >= 91) {
      return AppTheme.getSuccessColor(context);
    } else if (value >= 76) {
      return AppTheme.getPrimaryColor(context);
    } else if (value >= 66) {
      return AppTheme.getWarningColor(context);
    } else if (value >= 51) {
      return AppTheme.getWarningColor(context);
    } else {
      return AppTheme.getErrorColor(context);
    }
  }

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
}
