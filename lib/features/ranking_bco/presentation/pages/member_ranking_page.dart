import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/member_kpi_ranking_bloc.dart';
import '../bloc/member_kpi_ranking_event.dart';
import '../bloc/member_kpi_ranking_state.dart';
import '../../domain/entities/member_kpi_entity.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';

class MemberRankingPage extends StatelessWidget {
  final int bcoId;
  final String year;
  final String month;
  const MemberRankingPage(
      {Key? key, required this.bcoId, required this.year, required this.month})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peringkat Anggota')),
      body: BlocProvider<MemberKpiRankingBloc>(
        create: (context) => sl<MemberKpiRankingBloc>()
          ..add(FetchMemberKpiRanking(bcoId: bcoId, year: year, month: month)),
        child: BlocBuilder<MemberKpiRankingBloc, MemberKpiRankingState>(
          builder: (context, state) {
            if (state is MemberKpiRankingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MemberKpiRankingError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is MemberKpiRankingLoaded) {
              if (state.members.isEmpty) {
                return const Center(child: Text('Tidak ada data anggota.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.members.length,
                itemBuilder: (context, index) {
                  final member = state.members[index];
                  return _buildMemberCard(context, member, index);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMemberCard(
      BuildContext context, MemberKpiEntity member, int index) {
    final totalNilai = member.grafik.fold<double>(
        0, (sum, g) => sum + (double.tryParse(g.data.nilai) ?? 0.0));
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.kodeRayon,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: member.grafik
                      .map((g) => _buildKpiDetailRow(context, g))
                      .toList(),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _buildCategoryBadge(context, totalNilai),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiChip(BuildContext context, MemberKpiGrafikEntity g) {
    return Chip(
      label: Text(g.label, style: GoogleFonts.poppins(fontSize: 11)),
      backgroundColor: Color(
              int.tryParse(g.backgroundColor.replaceAll('#', '0xFF')) ??
                  0xFF2196F3)
          .withOpacity(0.15),
      avatar: CircleAvatar(
        backgroundColor: Color(
            int.tryParse(g.backgroundColor.replaceAll('#', '0xFF')) ??
                0xFF2196F3),
        radius: 8,
        child: Text(
          g.data.nilai,
          style: GoogleFonts.poppins(
              fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildKpiDetailRow(BuildContext context, MemberKpiGrafikEntity g) {
    final color = Color(
        int.tryParse(g.backgroundColor.replaceAll('#', '0xFF')) ?? 0xFF2196F3);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.label,
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _buildKpiDetailItem('Nilai', g.data.nilai, color),
                    _buildKpiDetailItem('Target', g.data.target, color),
                    _buildKpiDetailItem(
                        'Realisasi', g.data.realisasi ?? '-', color),
                    _buildKpiDetailItem('Bobot', g.data.bobot, color),
                    _buildKpiDetailItem('Ach', '${g.data.ach}%', color),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiDetailItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 9, color: color)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
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
