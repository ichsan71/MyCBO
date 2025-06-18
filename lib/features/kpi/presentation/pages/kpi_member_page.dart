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
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
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
                            color: Colors.grey[600],
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
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada data KPI Anggota',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'untuk periode ${DateFormat('MMMM yyyy', 'id_ID').format(
                              DateTime(int.parse(_currentYear), int.parse(_currentMonth))
                            )}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(kpiMember),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                            color: Colors.grey[600],
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
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
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
                    value: DateFormat('MMM yyyy', 'id_ID').format(
                      DateTime(int.parse(_currentYear), int.parse(_currentMonth))
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
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
                border: Border.all(color: Colors.grey[300]!),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 