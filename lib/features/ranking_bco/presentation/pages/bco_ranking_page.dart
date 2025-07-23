import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../bloc/bco_ranking_bloc.dart';
import '../bloc/bco_ranking_event.dart';
import '../bloc/bco_ranking_state.dart';
import '../../domain/entities/bco_ranking_entity.dart';
import '../widgets/bco_ranking_card.dart';
import 'bco_ranking_detail_page.dart';
import '../../../../core/presentation/theme/app_theme.dart';

class BcoRankingPage extends StatefulWidget {
  final String token;
  final String year;
  final String month;
  const BcoRankingPage(
      {Key? key, required this.token, required this.year, required this.month})
      : super(key: key);

  @override
  State<BcoRankingPage> createState() => _BcoRankingPageState();
}

class _BcoRankingPageState extends State<BcoRankingPage> {
  late String _currentYear;
  late String _currentMonth;
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _currentYear = widget.year;
    _currentMonth = widget.month;
    _loadData();
  }

  void _loadData() {
    context.read<BcoRankingBloc>().add(FetchBcoRanking(
          token: widget.token,
          year: _currentYear,
          month: _currentMonth,
        ));
  }

  Future<void> _showMonthYearPicker() async {
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: DateTime(int.parse(_currentYear), int.parse(_currentMonth)),
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BcoRankingBloc>.value(
      value: BlocProvider.of<BcoRankingBloc>(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Peringkat BCO'),
        ),
        body: Column(
          children: [
            _buildFilterSection(),
            Expanded(
              child: BlocBuilder<BcoRankingBloc, BcoRankingState>(
                builder: (context, state) {
                  if (state is BcoRankingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BcoRankingError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is BcoRankingLoaded) {
                    final filtered =
                        _searchQuery == null || _searchQuery!.isEmpty
                            ? state.rankings
                            : state.rankings
                                .where((r) => r.kodeRayon
                                    .toLowerCase()
                                    .contains(_searchQuery!.toLowerCase()))
                                .toList();
                    if (filtered.isEmpty) {
                      return const Center(
                          child: Text('Tidak ada data peringkat BCO.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final ranking = filtered[index];
                        return BcoRankingCard(
                          ranking: ranking,
                          index: index,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BcoRankingDetailPage(
                                  ranking: ranking,
                                  year: _currentYear,
                                  month: _currentMonth,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
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
              setState(() {
                _searchQuery = value;
              });
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
