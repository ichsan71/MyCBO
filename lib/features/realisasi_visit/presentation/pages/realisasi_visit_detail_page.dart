import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_bar_widget.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_card.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/realisasi_visit.dart';
import '../bloc/realisasi_visit_bloc.dart';

class RealisasiVisitDetailPage extends StatelessWidget {
  final RealisasiVisit realisasiVisit;
  final int userId;

  const RealisasiVisitDetailPage({
    Key? key,
    required this.realisasiVisit,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RealisasiVisitBloc>(),
      child: RealisasiVisitDetailView(
        realisasiVisit: realisasiVisit,
        userId: userId,
      ),
    );
  }
}

class RealisasiVisitDetailView extends StatefulWidget {
  final RealisasiVisit realisasiVisit;
  final int userId;

  const RealisasiVisitDetailView({
    Key? key,
    required this.realisasiVisit,
    required this.userId,
  }) : super(key: key);

  @override
  State<RealisasiVisitDetailView> createState() =>
      RealisasiVisitDetailViewState();
}

class RealisasiVisitDetailViewState extends State<RealisasiVisitDetailView> {
  final List<String> _selectedScheduleIds = [];
  bool _isProcessing = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // final _animatedListKey = GlobalKey<AnimatedListState>();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  String _selectedStatusFilter = 'Semua';
  bool _selectAll = false;

  // Filter status options
  List<Map<String, dynamic>> get statusFilterOptions => [
        {'name': 'Semua', 'icon': Icons.filter_list, 'color': Colors.grey},
        {
          'name': 'Selesai',
          'icon': Icons.check_circle_outline,
          'color': Colors.green
        },
        {
          'name': 'Pending',
          'icon': Icons.pending_outlined,
          'color': Colors.orange
        },
        {
          'name': 'Tidak Selesai',
          'icon': Icons.cancel_outlined,
          'color': Colors.red
        },
      ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Detail Realisasi Visit',
      ),
      body: BlocConsumer<RealisasiVisitBloc, RealisasiVisitState>(
        listener: (context, state) {
          if (state is RealisasiVisitApproved) {
            setState(() {
              _isProcessing = false;
              // Clear selections after successful approval
              _selectedScheduleIds.clear();
              _selectAll = false;
            });

            // Navigate back immediately
            Navigator.pop(
                context, true); // Pass true untuk menandakan perubahan berhasil

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Realisasi visit berhasil disetujui'),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
              ),
            );
          } else if (state is RealisasiVisitRejected) {
            setState(() {
              _isProcessing = false;
              // Clear selections after successful rejection
              _selectedScheduleIds.clear();
              _selectAll = false;
            });

            // Navigate back immediately
            Navigator.pop(
                context, true); // Pass true untuk menandakan perubahan berhasil

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Realisasi visit berhasil ditolak'),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
              ),
            );
          } else if (state is RealisasiVisitError) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RealisasiVisitProcessing || _isProcessing) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 24),

                    // Search & Filter Card
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.search,
                                size: 18,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cari & Filter',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSearchBar(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section title with counter
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.getBorderColor(context),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: (255 * 0.1),
                                    red: AppTheme.primaryColor.red.toDouble(),
                                    green:
                                        AppTheme.primaryColor.green.toDouble(),
                                    blue: AppTheme.primaryColor.blue.toDouble(),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.list_alt,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Daftar Jadwal',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: (255 * 0.1),
                                red: AppTheme.primaryColor.red.toDouble(),
                                green: AppTheme.primaryColor.green.toDouble(),
                                blue: AppTheme.primaryColor.blue.toDouble(),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${widget.realisasiVisit.details.length} Jadwal',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bulk Approval Card - redesigned
                    if (_hasPendingSchedules()) ...[
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.approval,
                                      size: 20,
                                      color: AppTheme.successColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Persetujuan Massal',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.successColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.getCardBackgroundColor(
                                          context),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppTheme.getBorderColor(context),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '${_selectedScheduleIds.length} terpilih',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.getSecondaryTextColor(
                                            context),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            if (widget.realisasiVisit.details.any((schedule) =>
                                _canApproveSchedule(schedule))) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Pilih semua jadwal yang tersedia',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppTheme.getSecondaryTextColor(
                                            context),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Pilih Semua',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      Checkbox(
                                        value: _selectAll,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _selectAll = value ?? false;
                                            if (_selectAll) {
                                              _selectedScheduleIds.clear();
                                              _selectedScheduleIds.addAll(
                                                widget.realisasiVisit.details
                                                    .where((schedule) =>
                                                        _canApproveSchedule(
                                                            schedule))
                                                    .map((schedule) =>
                                                        schedule.id.toString()),
                                              );
                                            } else {
                                              _selectedScheduleIds.clear();
                                            }
                                          });
                                        },
                                        activeColor: AppTheme.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            AppButton(
                              text:
                                  'Setujui Jadwal Terpilih (${_selectedScheduleIds.length})',
                              onPressed: _selectedScheduleIds.isNotEmpty
                                  ? () => _showApprovalDialog(true)
                                  : null,
                              type: AppButtonType.success,
                              isFullWidth: true,
                              prefixIcon: const Icon(Icons.check_circle,
                                  size: 16, color: Colors.white),
                              fontSize: 14,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    _buildScheduleList(),
                    const SizedBox(height: 80), // Padding untuk bottom buttons
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(
                    alpha: (255 * 0.1),
                    red: AppTheme.primaryColor.red.toDouble(),
                    green: AppTheme.primaryColor.green.toDouble(),
                    blue: AppTheme.primaryColor.blue.toDouble(),
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.realisasiVisit.namaBawahan,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _buildInfoRow('Role', widget.realisasiVisit.role, Icons.work),
          const SizedBox(height: 4),
          _buildInfoRow(
              'Total Jadwal',
              widget.realisasiVisit.totalSchedule.toString(),
              Icons.calendar_today),
          const SizedBox(height: 4),
          _buildInfoRow('Jumlah Dokter', widget.realisasiVisit.jumlahDokter,
              Icons.medical_services),
          const SizedBox(height: 4),
          _buildInfoRow('Jumlah Klinik', widget.realisasiVisit.jumlahKlinik,
              Icons.local_hospital),
          const SizedBox(height: 4),
          _buildInfoRow('Total Terrealisasi',
              widget.realisasiVisit.totalTerrealisasi, Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [IconData? icon]) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
        ],
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getCardBackgroundColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isSearchFocused
                  ? AppTheme.primaryColor
                  : AppTheme.getBorderColor(context),
              width: _isSearchFocused ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cari nama dokter, tanggal, status...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.getSecondaryTextColor(context),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: _isSearchFocused
                    ? AppTheme.primaryColor
                    : AppTheme.getSecondaryTextColor(context),
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                      color: AppTheme.getSecondaryTextColor(context),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              // Simpan riwayat pencarian jika diperlukan
              _searchFocusNode.unfocus();
            },
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: statusFilterOptions.map((filter) {
              final bool isSelected = _selectedStatusFilter == filter['name'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedStatusFilter = filter['name'];
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.getCardBackgroundColor(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.getBorderColor(context),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filter['icon'],
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.getSecondaryTextColor(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          filter['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_searchQuery.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSearchResultInfo(),
        ],
      ],
    );
  }

  Widget _buildSearchResultInfo() {
    final filteredSchedules =
        widget.realisasiVisit.details.where(_filterSchedule).toList();
    final int totalCount = filteredSchedules.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 14, color: Colors.blue[700]),
          const SizedBox(width: 6),
          Text(
            'Ditemukan $totalCount jadwal',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_selectedStatusFilter != 'Semua') ...[
            Text(
              ' (Filter: $_selectedStatusFilter)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blue[700],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    // Filter semua jadwal berdasarkan status filter dan search query
    final filteredSchedules =
        widget.realisasiVisit.details.where(_filterSchedule).toList();

    // Kelompokkan berdasarkan status category
    final pendingSchedules = filteredSchedules
        .where((detail) => _getScheduleStatusCategory(detail) == 'Pending')
        .toList();
    final approvedSchedules = filteredSchedules
        .where((detail) => _getScheduleStatusCategory(detail) == 'Selesai')
        .toList();
    final notCompletedSchedules = filteredSchedules
        .where(
            (detail) => _getScheduleStatusCategory(detail) == 'Tidak Selesai')
        .toList();

    if (filteredSchedules.isEmpty) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Center(
          key: const ValueKey('no-results'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getCardBackgroundColor(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off,
                    size: 60, color: AppTheme.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada jadwal yang sesuai',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getPrimaryTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedStatusFilter != 'Semua'
                    ? 'Tidak ada jadwal dengan status "$_selectedStatusFilter"'
                    : 'Coba kata kunci pencarian lain',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Reset Filter',
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _selectedStatusFilter = 'Semua';
                  });
                },
                type: AppButtonType.outline,
                prefixIcon: const Icon(Icons.refresh, size: 16),
                fontSize: 14,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: ValueKey(
            'results-${pendingSchedules.length}-${approvedSchedules.length}-${notCompletedSchedules.length}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingSchedules.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pending_actions,
                    size: 16,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Menunggu Persetujuan (${pendingSchedules.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingSchedules.length,
              itemBuilder: (context, index) {
                final schedule = pendingSchedules[index];
                final bool isSelected =
                    _selectedScheduleIds.contains(schedule.id.toString());
                final bool canApprove = _canApproveSchedule(schedule);

                return _buildScheduleCard(
                  schedule,
                  isSelected,
                  canApprove,
                  onToggleSelection: () {
                    if (canApprove) {
                      setState(() {
                        if (isSelected) {
                          _selectedScheduleIds.remove(schedule.id.toString());
                          _selectAll = false;
                        } else {
                          _selectedScheduleIds.add(schedule.id.toString());
                          final approvableSchedules = pendingSchedules
                              .where((s) => _canApproveSchedule(s))
                              .map((s) => s.id.toString())
                              .toList();
                          _selectAll = approvableSchedules
                              .every((id) => _selectedScheduleIds.contains(id));
                        }
                      });
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          if (notCompletedSchedules.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.errorColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 16,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tidak Selesai (${notCompletedSchedules.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notCompletedSchedules.length,
              itemBuilder: (context, index) {
                final schedule = notCompletedSchedules[index];
                return _buildScheduleCard(schedule, false, false);
              },
            ),
            const SizedBox(height: 24),
          ],
          if (approvedSchedules.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.successColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sudah Diproses (${approvedSchedules.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: approvedSchedules.length,
              itemBuilder: (context, index) {
                final schedule = approvedSchedules[index];
                return _buildScheduleCard(schedule, false, false);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    RealisasiVisitDetail schedule,
    bool isSelected,
    bool canApprove, {
    VoidCallback? onToggleSelection,
  }) {
    final DateTime? visitDate = _parseVisitDate(schedule.tglVisit);
    final String formattedDate = visitDate != null
        ? DateFormat('dd MMM yyyy').format(visitDate)
        : schedule.tglVisit; // Fallback to original string if parsing fails
    final bool isDone = schedule.statusTerrealisasi == 'Done';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackgroundColor(context),
        borderRadius: AppTheme.borderRadiusSmall,
        border: isSelected
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggleSelection,
          borderRadius: AppTheme.borderRadiusSmall,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (canApprove)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                if (onToggleSelection != null) {
                                  onToggleSelection();
                                }
                              },
                              activeColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.person,
                                  size: 14, color: AppTheme.primaryColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  schedule.tujuanData.namaDokter.isEmpty
                                      ? 'Dokter (ID: ${schedule.idTujuan})'
                                      : schedule.tujuanData.namaDokter,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (canApprove)
                          const SizedBox(width: 24), // Align with checkbox
                        Icon(Icons.event,
                            size: 14,
                            color: AppTheme.getSecondaryTextColor(context)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Tanggal: $formattedDate',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(schedule),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.getBorderColor(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shift & Jenis
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 18, color: AppTheme.primaryColor),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Shift',
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color:
                                                AppTheme.getSecondaryTextColor(
                                                    context))),
                                    Text(schedule.shift,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.category,
                                    size: 18, color: AppTheme.primaryColor),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Jenis',
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color:
                                                AppTheme.getSecondaryTextColor(
                                                    context))),
                                    Text(schedule.jenis,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Status (text only)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline,
                              size: 18, color: AppTheme.primaryColor),
                          const SizedBox(width: 6),
                          Text('Status',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color:
                                      AppTheme.getSecondaryTextColor(context))),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              schedule.statusTerrealisasi,
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (schedule.lokasi != null &&
                          schedule.lokasi!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on,
                                size: 18, color: AppTheme.primaryColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Lokasi',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: AppTheme.getSecondaryTextColor(
                                              context))),
                                  Text(
                                    schedule.lokasi!,
                                    style: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isDone ||
                          (schedule.checkin != null &&
                              schedule.checkin!.isNotEmpty)) ...[
                        const SizedBox(height: 14),
                        Divider(
                            color: AppTheme.getBorderColor(context),
                            thickness: 0.7,
                            height: 1),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.login,
                                      size: 18, color: AppTheme.primaryColor),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Check-in',
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: AppTheme
                                                    .getSecondaryTextColor(
                                                        context))),
                                        Text(
                                          schedule.checkin ?? '-',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.logout,
                                      size: 18, color: AppTheme.primaryColor),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Check-out',
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: AppTheme
                                                    .getSecondaryTextColor(
                                                        context))),
                                        Text(
                                          schedule.checkout ?? '-',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Foto Check-in
                if (isDone &&
                    schedule.fotoSelfie != null &&
                    schedule.fotoSelfie!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.photo_camera,
                          size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Foto Check-in:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildImageView(schedule.fotoSelfie!),
                  const SizedBox(height: 12),
                ],

                // Foto Check-out
                if (isDone &&
                    schedule.fotoSelfieDua != null &&
                    schedule.fotoSelfieDua!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.photo_camera,
                          size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Foto Check-out:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildImageView(schedule.fotoSelfieDua!),
                  const SizedBox(height: 12),
                ],

                // Produk Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medication,
                              size: 14, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            'Produk:',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (schedule.productData.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            "Tidak ada produk",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[500],
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: schedule.productData.map((product) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                product.namaProduct,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                // Notes Section
                if (schedule.note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note,
                                size: 14, color: AppTheme.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              'Catatan:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          schedule.note,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageView(String imageName) {
    final String imageUrl = Constants.baseImageUrl + imageName;

    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imageUrl),
      child: Container(
        width: double.infinity,
        height: 160,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        decoration: BoxDecoration(
          borderRadius: AppTheme.borderRadiusSmall,
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: AppTheme.borderRadiusSmall,
              child: Hero(
                tag: imageUrl,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 30, color: AppTheme.errorColor),
                          const SizedBox(height: 4),
                          Text(
                            'Gagal memuat gambar',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Perbesar',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _FullScreenImageViewer(imageUrl: imageUrl),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildDetailRowCompact(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryColor),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(RealisasiVisitDetail schedule) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    if (schedule.realisasiVisitApproved == null) {
      if (schedule.statusTerrealisasi.toLowerCase() == 'not done') {
        badgeColor = AppTheme.warningColor;
        statusText = 'Pending';
        statusIcon = Icons.hourglass_empty;
      } else if (schedule.statusTerrealisasi.toLowerCase() == 'done') {
        badgeColor = AppTheme.warningColor;
        statusText = 'Menunggu';
        statusIcon = Icons.hourglass_empty;
      } else {
        badgeColor = AppTheme.warningColor;
        statusText = 'Pending';
        statusIcon = Icons.hourglass_empty;
      }
    } else {
      badgeColor = AppTheme.successColor;
      statusText = 'Disetujui';
      statusIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: AppTheme.borderRadiusSmall,
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasPendingSchedules() {
    return widget.realisasiVisit.details
        .any((detail) => detail.realisasiVisitApproved == null);
  }

  bool _canApproveSchedule(RealisasiVisitDetail schedule) {
    // Jika jadwal sudah disetujui atau ditolak
    if (schedule.realisasiVisitApproved != null) {
      return false;
    }

    // Jika status terealisasi adalah "not done", tidak bisa disetujui
    final status = schedule.statusTerrealisasi.toLowerCase().trim();
    if (status == 'not done' || status == 'notdone' || status == 'not_done') {
      return false;
    }

    // Cek apakah jadwal bisa di-approve berdasarkan tanggal visit
    try {
      final DateTime now = DateTime.now();
      final DateTime? visitDate = _parseVisitDate(schedule.tglVisit);

      if (visitDate == null) {
        // Jika parsing tanggal gagal, tidak bisa approve untuk keamanan
        return false;
      }

      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = today.subtract(const Duration(days: 1));
      final DateTime visitDateOnly =
          DateTime(visitDate.year, visitDate.month, visitDate.day);

      // Case 1: Visit hari ini - bisa approve kapan saja
      if (visitDateOnly.isAtSameMomentAs(today)) {
        return true;
      }

      // Case 2: Visit kemarin - bisa approve sampai hari ini jam 12 siang
      if (visitDateOnly.isAtSameMomentAs(yesterday)) {
        final DateTime deadline = DateTime(now.year, now.month, now.day, 12, 0);
        return now.isBefore(deadline);
      }

      // Case 3: Visit selain hari ini dan kemarin - tidak bisa approve
      return false;
    } catch (e) {
      // Jika terjadi error parsing tanggal, return false untuk keamanan
      return false;
    }
  }

  DateTime? _parseVisitDate(String dateStr) {
    try {
      // Remove any leading/trailing whitespace
      dateStr = dateStr.trim();

      // Try ISO format first (yyyy-MM-dd)
      if (dateStr.contains('-') && dateStr.split('-').length == 3) {
        try {
          return DateTime.parse(dateStr);
        } catch (_) {
          // Continue to other formats if ISO parsing fails
        }
      }

      // Try MM/dd/yyyy format
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          try {
            final month = int.parse(parts[0]);
            final day = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            return DateTime(year, month, day);
          } catch (_) {
            // Continue to other formats
          }
        }
      }

      // Try dd MMM yyyy format (e.g., "01 Jul 2025")
      try {
        final ddMMMyyyyFormat = DateFormat('dd MMM yyyy', 'en_US');
        return ddMMMyyyyFormat.parse(dateStr);
      } catch (_) {
        // Continue to other formats
      }

      // Try dd/MM/yyyy format
      try {
        final ddMMyyyyFormat = DateFormat('dd/MM/yyyy');
        return ddMMyyyyFormat.parse(dateStr);
      } catch (_) {
        // Continue to other formats
      }

      // Try dd-MM-yyyy format
      try {
        final ddMMyyyyDashFormat = DateFormat('dd/MM/yyyy');
        return ddMMyyyyDashFormat.parse(dateStr.replaceAll('-', '/'));
      } catch (_) {
        // Continue to other formats
      }

      // Try yyyy-MM-dd format with different separators
      try {
        final yyyyMMddFormat = DateFormat('yyyy-MM-dd');
        return yyyyMMddFormat.parse(dateStr);
      } catch (_) {
        // Continue to other formats
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  void _showApprovalDialog(bool isApprove) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.borderRadiusLarge,
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isApprove
                    ? AppTheme.successColor.withOpacity(0.12)
                    : AppTheme.errorColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isApprove ? Icons.check_circle : Icons.cancel,
                color: isApprove ? AppTheme.successColor : AppTheme.errorColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                isApprove
                    ? 'Konfirmasi Setujui Jadwal'
                    : 'Konfirmasi Tolak Jadwal',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              isApprove
                  ? 'Anda akan menyetujui ${_selectedScheduleIds.length} jadwal realisasi visit.'
                  : 'Anda akan menolak ${_selectedScheduleIds.length} jadwal realisasi visit.',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tindakan ini tidak dapat dibatalkan. Pastikan data sudah benar sebelum melanjutkan.',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Batal',
                  onPressed: () => Navigator.pop(context),
                  type: AppButtonType.outline,
                  prefixIcon: const Icon(Icons.close, size: 16),
                  fontSize: 14,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: isApprove ? 'Setujui' : 'Tolak',
                  onPressed: () {
                    Navigator.pop(context);
                    if (isApprove) {
                      _handleApproveSelected();
                    } else {
                      _handleRejectSelected();
                    }
                  },
                  type: isApprove ? AppButtonType.success : AppButtonType.error,
                  prefixIcon: Icon(
                    isApprove ? Icons.check : Icons.cancel,
                    size: 16,
                    color: Colors.white,
                  ),
                  fontSize: 14,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleApproveSelected() {
    if (_selectedScheduleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih minimal satu jadwal untuk disetujui'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.borderRadiusSmall,
          ),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Convert selected IDs to list of integers
    final List<int> selectedIds =
        _selectedScheduleIds.map((id) => int.parse(id)).toList();

    context.read<RealisasiVisitBloc>().add(
          ApproveRealisasiVisitEvent(
            idRealisasiVisits: selectedIds,
            idUser: widget.userId,
          ),
        );
  }

  void _handleRejectSelected() {
    if (_selectedScheduleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih minimal satu jadwal untuk ditolak'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.borderRadiusSmall,
          ),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Convert selected IDs to list of integers
    final List<int> selectedIds =
        _selectedScheduleIds.map((id) => int.parse(id)).toList();

    context.read<RealisasiVisitBloc>().add(
          RejectRealisasiVisitEvent(
            idRealisasiVisits: selectedIds,
            idUser: widget.userId,
            reason: 'Ditolak oleh atasan', // Add default reason
          ),
        );
  }

  String _getScheduleStatusCategory(RealisasiVisitDetail schedule) {
    final status = schedule.statusTerrealisasi.toLowerCase().trim();
    final isApproved = schedule.realisasiVisitApproved != null;

    // Selesai: status "done" dan sudah disetujui (realisasi_visit_approved tidak null)
    if (status == 'done' && isApproved) {
      return 'Selesai';
    }

    // Pending: status "done" tapi belum disetujui
    if (status == 'done' && !isApproved) {
      return 'Pending';
    }

    // Tidak Selesai: status "not done" atau status lainnya
    if (status == 'not done' || status == 'notdone' || status == 'not_done') {
      return 'Tidak Selesai';
    }

    // Default untuk status lainnya
    return 'Tidak Selesai';
  }

  bool _filterSchedule(RealisasiVisitDetail schedule) {
    // Filter berdasarkan status category terlebih dahulu
    final String statusCategory = _getScheduleStatusCategory(schedule);
    if (_selectedStatusFilter != 'Semua' &&
        statusCategory != _selectedStatusFilter) {
      return false;
    }

    // Jika tidak ada search query, return true (sudah difilter berdasarkan status)
    if (_searchQuery.isEmpty) {
      return true;
    }

    // Search functionality untuk semua field
    final String query = _searchQuery.toLowerCase();
    final String doctorName = schedule.tujuanData.namaDokter.toLowerCase();
    final DateTime? visitDate = _parseVisitDate(schedule.tglVisit);
    final String formattedDate = visitDate != null
        ? DateFormat('dd MMM yyyy').format(visitDate).toLowerCase()
        : schedule.tglVisit.toLowerCase(); // Fallback to original string
    final String status = schedule.statusTerrealisasi.toLowerCase();
    final String shift = schedule.shift.toLowerCase();
    final String jenis = schedule.jenis.toLowerCase();
    final String products = schedule.formattedProductNames.toLowerCase();

    return doctorName.contains(query) ||
        formattedDate.contains(query) ||
        status.contains(query) ||
        shift.contains(query) ||
        jenis.contains(query) ||
        products.contains(query);
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;

  const _FullScreenImageViewer({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    Matrix4 endMatrix;
    if (_transformationController.value != Matrix4.identity()) {
      endMatrix = Matrix4.identity();
    } else {
      endMatrix = Matrix4.identity()..scale(2.0);
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Foto Detail',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            onPressed: _onDoubleTap,
            tooltip: 'Zoom In/Out',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: GestureDetector(
          onDoubleTap: _onDoubleTap,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (_animation != null) {
                _transformationController.value = _animation!.value;
              }
              return InteractiveViewer(
                transformationController: _transformationController,
                panEnabled: true,
                scaleEnabled: true,
                boundaryMargin: const EdgeInsets.all(0),
                minScale: 0.5,
                maxScale: 5.0,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Hero(
                    tag: widget.imageUrl,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.black,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Memuat gambar...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Gagal memuat gambar',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Periksa koneksi internet Anda',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    // Trigger rebuild to retry loading
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
