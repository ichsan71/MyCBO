import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:intl/intl.dart';
import '../bloc/kpi_member_bloc.dart';
import '../../domain/entities/kpi_member.dart';
import '../../../../core/presentation/widgets/app_bar_widget.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/shimmer_loading.dart';
import '../../data/models/kpi_model.dart';
import '../../../../core/presentation/theme/app_theme.dart';

class KpiMemberPage extends StatefulWidget {
  const KpiMemberPage({Key? key}) : super(key: key);

  @override
  State<KpiMemberPage> createState() => _KpiMemberPageState();
}

class _KpiMemberPageState extends State<KpiMemberPage> {
  final TextEditingController _searchController = TextEditingController();
  late String _currentYear;
  late String _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year.toString();
    _currentMonth = now.month.toString().padLeft(2, '0');

    _loadData();
  }

  void _loadData() {
    context.read<KpiMemberBloc>().add(LoadKpiMemberData(
          year: _currentYear,
          month: _currentMonth,
          searchQuery:
              _searchController.text.isEmpty ? null : _searchController.text,
        ));
  }

  Future<void> _showMonthYearPicker() async {
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: DateTime(
        int.parse(_currentYear),
        int.parse(_currentMonth),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
    );

    if (selected != null) {
      setState(() {
        _currentYear = selected.year.toString();
        _currentMonth = selected.month.toString().padLeft(2, '0');
      });
      _loadData();
    }
  }

  void _navigateToDetail(KpiMember kpiMember) {
    Navigator.pushNamed(
      context,
      '/kpi_member_detail',
      arguments: {
        'kpiMember': kpiMember,
        'year': _currentYear,
        'month': _currentMonth,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'KPI Anggota',
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: BlocBuilder<KpiMemberBloc, KpiMemberState>(
              builder: (context, state) {
                if (state is KpiMemberLoading) {
                  return const ShimmerLoading(
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                    ),
                  );
                }

                if (state is KpiMemberError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Terjadi kesalahan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Coba Lagi',
                          onPressed: _loadData,
                          type: AppButtonType.primary,
                        ),
                      ],
                    ),
                  );
                }

                if (state is KpiMemberLoaded) {
                  if (state.kpiMembers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart_outlined,
                            size: 64,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada data KPI Anggota',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'untuk periode ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime(int.parse(_currentYear), int.parse(_currentMonth)))}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.kpiMembers.length,
                    itemBuilder: (context, index) {
                      final kpiMember = state.kpiMembers[index];
                      return _buildKodeRayonCard(kpiMember);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKodeRayonCard(KpiMember kpiMember) {
    final totalNilai = _calculateTotalNilai(kpiMember.grafik);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(kpiMember),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Theme.of(context).primaryColor,
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
                                color: AppTheme.getSecondaryTextColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kpiMember.kodeRayon,
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
                        icon: Icons.bar_chart,
                        label: 'Indikator KPI',
                        value: '${kpiMember.grafik.length}',
                      ),
                      const SizedBox(width: 24),
                      _buildInfoItem(
                        icon: Icons.calendar_today,
                        label: 'Periode',
                        value: DateFormat('MMM yyyy', 'id_ID').format(DateTime(
                            int.parse(_currentYear), int.parse(_currentMonth))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoItem(
                        icon: Icons.star,
                        label: 'Total Nilai',
                        value: _calculateTotalNilai(kpiMember.grafik)
                            .toStringAsFixed(1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: _buildCategoryBadge(totalNilai),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
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

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari berdasarkan kode rayon...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              context.read<KpiMemberBloc>().add(SearchKpiMember(value));
            },
          ),
          const SizedBox(height: 16),
          // Month picker
          InkWell(
            onTap: _showMonthYearPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.getBorderColor(context)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'id_ID').format(
                      DateTime(
                        int.parse(_currentYear),
                        int.parse(_currentMonth),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalNilai(List<KpiGrafik> grafik) {
    double total = 0;
    for (var item in grafik) {
      total += double.tryParse(item.data.nilai) ?? 0.0;
    }
    return total;
  }

  double _calculateAverageAchievement(List<KpiGrafik> grafik) {
    if (grafik.isEmpty) return 0;
    double total = 0;
    for (var item in grafik) {
      total += double.tryParse(item.data.ach) ?? 0.0;
    }
    return total / grafik.length;
  }

  Widget _buildCategoryBadge(double achievement) {
    final color = _getCategoryColor(achievement);
    final icon = _getCategoryIcon(achievement);
    final label = _getCategoryLabel(achievement);
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

  Color _getCategoryColor(double value) {
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
