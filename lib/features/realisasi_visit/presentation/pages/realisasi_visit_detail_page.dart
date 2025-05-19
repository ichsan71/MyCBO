import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  _RealisasiVisitDetailViewState createState() =>
      _RealisasiVisitDetailViewState();
}

class _RealisasiVisitDetailViewState extends State<RealisasiVisitDetailView> {
  final List<String> _selectedScheduleIds = [];
  bool _isProcessing = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  String _selectedFilter = 'Semua';

  // Gunakan metode untuk mendapatkan filter options
  List<Map<String, dynamic>> get filterOptions => [
        {'name': 'Semua', 'icon': Icons.filter_list},
        {'name': 'Dokter', 'icon': Icons.person},
        {'name': 'Tanggal', 'icon': Icons.calendar_today},
        {'name': 'Status', 'icon': Icons.info},
        {'name': 'Produk', 'icon': Icons.medication},
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
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
              ),
            );
            Navigator.pop(context);
          } else if (state is RealisasiVisitRejected) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
              ),
            );
            Navigator.pop(context);
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
                    if (_hasPendingSchedules()) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.borderRadiusMedium,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.batch_prediction,
                                    size: 16, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Persetujuan Massal',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pilih jadwal untuk diproses:',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    text:
                                        'Setujui (${_selectedScheduleIds.length})',
                                    onPressed: _selectedScheduleIds.isNotEmpty
                                        ? () => _showApprovalDialog(true)
                                        : null,
                                    type: AppButtonType.success,
                                    isFullWidth: true,
                                    prefixIcon: const Icon(Icons.check_circle,
                                        size: 14, color: Colors.white),
                                    fontSize: 12,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AppButton(
                                    text:
                                        'Tolak (${_selectedScheduleIds.length})',
                                    onPressed: _selectedScheduleIds.isNotEmpty
                                        ? () => _showApprovalDialog(false)
                                        : null,
                                    type: AppButtonType.error,
                                    isFullWidth: true,
                                    prefixIcon: const Icon(Icons.cancel,
                                        size: 14, color: Colors.white),
                                    fontSize: 12,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      'Daftar Jadwal',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
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
                  color: AppTheme.primaryColor.withOpacity(0.1),
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
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  _isSearchFocused ? AppTheme.primaryColor : Colors.grey[300]!,
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
                color: Colors.grey[400],
              ),
              prefixIcon: Icon(
                Icons.search,
                color:
                    _isSearchFocused ? AppTheme.primaryColor : Colors.grey[400],
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
                      color: Colors.grey[400],
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
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filterOptions.map((filter) {
              final bool isSelected = _selectedFilter == filter['name'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter['name'];
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filter['icon'],
                          size: 14,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          filter['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.white : Colors.grey[600],
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
          const SizedBox(height: 8),
          _buildSearchResultInfo(),
        ],
      ],
    );
  }

  Widget _buildSearchResultInfo() {
    final int pendingCount = widget.realisasiVisit.details
        .where((detail) => detail.realisasiVisitApproved == null)
        .where(_filterSchedule)
        .length;
    final int approvedCount = widget.realisasiVisit.details
        .where((detail) => detail.realisasiVisitApproved != null)
        .where(_filterSchedule)
        .length;
    final int totalCount = pendingCount + approvedCount;

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
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_selectedFilter != 'Semua') ...[
            Text(
              ' (Filter: ${_selectedFilter})',
              style: GoogleFonts.poppins(
                fontSize: 12,
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
    final pendingSchedules = widget.realisasiVisit.details
        .where((detail) => detail.realisasiVisitApproved == null)
        .where(_filterSchedule)
        .toList();
    final approvedSchedules = widget.realisasiVisit.details
        .where((detail) => detail.realisasiVisitApproved != null)
        .where(_filterSchedule)
        .toList();

    if (_searchQuery.isNotEmpty &&
        pendingSchedules.isEmpty &&
        approvedSchedules.isEmpty) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Center(
          key: const ValueKey('no-results'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Tidak ada jadwal yang sesuai',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coba kata kunci pencarian lain',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Hapus Pencarian',
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
                type: AppButtonType.outline,
                prefixIcon: const Icon(Icons.refresh, size: 14),
                fontSize: 14,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            'results-${pendingSchedules.length}-${approvedSchedules.length}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingSchedules.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.pending_actions,
                  size: 16,
                  color: AppTheme.warningColor,
                ),
                const SizedBox(width: 6),
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
            const SizedBox(height: 8),
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
                        } else {
                          _selectedScheduleIds.add(schedule.id.toString());
                        }
                      });
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          if (approvedSchedules.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 6),
                Text(
                  'Sudah Diproses (${approvedSchedules.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
    final DateTime visitDate = DateTime.parse(schedule.tglVisit);
    final String formattedDate = DateFormat('dd MMM yyyy').format(visitDate);
    final bool isDone = schedule.statusTerrealisasi == 'Done';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderRadiusSmall,
        border: isSelected
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : Border.all(color: Colors.grey.shade200),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        size: 14, color: AppTheme.primaryColor),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        schedule.tujuanData.namaDokter,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.event,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Tanggal: $formattedDate',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(schedule),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildDetailRow('Shift', schedule.shift, Icons.access_time),
                const SizedBox(height: 4),
                _buildDetailRow('Jenis', schedule.jenis, Icons.category),
                const SizedBox(height: 4),
                _buildDetailRow(
                    'Status', schedule.statusTerrealisasi, Icons.info),
                const SizedBox(height: 8),
                if (isDone) ...[
                  _buildDetailRow(
                      'Check-in', schedule.checkin ?? '-', Icons.login),
                  const SizedBox(height: 4),
                  _buildDetailRow(
                      'Check-out', schedule.checkout ?? '-', Icons.logout),
                  const SizedBox(height: 16),

                  // Menampilkan foto check-in
                  if (schedule.fotoSelfie != null &&
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

                  // Menampilkan foto check-out
                  if (schedule.fotoSelfieDua != null &&
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
                ],
                Row(
                  children: [
                    Icon(Icons.medication,
                        size: 14, color: AppTheme.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      'Produk:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: schedule.productData.map((product) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.namaProduct,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (schedule.note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.note, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Catatan:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule.note,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                if (schedule.realisasiVisitApproved == null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Tooltip(
                          message: canApprove
                              ? ''
                              : 'Sudah melewati batas waktu persetujuan',
                          child: AppButton(
                            text: 'Setujui',
                            onPressed: canApprove
                                ? () {
                                    _approveSchedule([schedule.id.toString()]);
                                  }
                                : null,
                            type: AppButtonType.success,
                            isFullWidth: true,
                            prefixIcon: const Icon(Icons.check_circle,
                                size: 14, color: Colors.white),
                            fontSize: 12,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Tooltip(
                          message: canApprove
                              ? ''
                              : 'Sudah melewati batas waktu persetujuan',
                          child: AppButton(
                            text: 'Tolak',
                            onPressed: canApprove
                                ? () {
                                    _rejectSchedule([schedule.id.toString()]);
                                  }
                                : null,
                            type: AppButtonType.error,
                            isFullWidth: true,
                            prefixIcon: Icon(Icons.cancel,
                                size: 14, color: Colors.white),
                            fontSize: 12,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!canApprove) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.warning_amber_rounded,
                                color: Colors.amber[700], size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Batas waktu berakhir',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber[900],
                                  ),
                                ),
                                Text(
                                  'Maksimal H+1 jam 12 siang',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.amber[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
        decoration: BoxDecoration(
          borderRadius: AppTheme.borderRadiusSmall,
          border: Border.all(color: Colors.grey[300]!),
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
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 30, color: Colors.red),
                          const SizedBox(height: 4),
                          Text(
                            'Gagal memuat gambar',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 16,
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
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              'Foto Detail',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat gambar',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [IconData? icon]) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
        ],
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
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
      badgeColor = AppTheme.warningColor;
      statusText = 'Menunggu';
      statusIcon = Icons.hourglass_empty;
    } else if (schedule.realisasiVisitApproved == '1') {
      badgeColor = AppTheme.successColor;
      statusText = 'Disetujui';
      statusIcon = Icons.check_circle;
    } else {
      badgeColor = AppTheme.errorColor;
      statusText = 'Ditolak';
      statusIcon = Icons.cancel;
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
              fontSize: 12,
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
    if (schedule.realisasiVisitApproved != null) {
      return false;
    }

    // Cek apakah jadwal masih dalam batas waktu (sebelum jam 12 siang)
    final DateTime now = DateTime.now();
    final DateTime visitDate = DateTime.parse(schedule.tglVisit);
    final DateTime nextDay =
        DateTime(visitDate.year, visitDate.month, visitDate.day + 1, 12, 0);

    return now.isBefore(nextDay);
  }

  void _showApprovalDialog(bool isApprove) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isApprove
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isApprove ? Icons.check_circle : Icons.cancel,
                color: isApprove ? AppTheme.successColor : AppTheme.errorColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isApprove ? 'Setujui Jadwal' : 'Tolak Jadwal',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isApprove
                  ? 'Yakin menyetujui ${_selectedScheduleIds.length} jadwal?'
                  : 'Yakin menolak ${_selectedScheduleIds.length} jadwal?',
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tindakan ini tidak dapat dibatalkan.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.borderRadiusMedium,
        ),
        actions: [
          AppButton(
            text: 'Batal',
            onPressed: () => Navigator.pop(context),
            type: AppButtonType.outline,
            prefixIcon: const Icon(Icons.close, size: 14),
            fontSize: 12,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          AppButton(
            text: isApprove ? 'Setujui' : 'Tolak',
            onPressed: () {
              Navigator.pop(context);
              if (isApprove) {
                _approveSchedule(_selectedScheduleIds);
              } else {
                _rejectSchedule(_selectedScheduleIds);
              }
            },
            type: isApprove ? AppButtonType.success : AppButtonType.error,
            prefixIcon: Icon(
              isApprove ? Icons.check : Icons.close,
              size: 14,
              color: Colors.white,
            ),
            fontSize: 12,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ],
      ),
    );
  }

  void _approveSchedule(List<String> scheduleIds) {
    setState(() => _isProcessing = true);
    context.read<RealisasiVisitBloc>().add(
          ApproveRealisasiVisitEvent(
            idAtasan: widget.userId,
            idSchedule: scheduleIds,
          ),
        );
  }

  void _rejectSchedule(List<String> scheduleIds) {
    setState(() => _isProcessing = true);
    context.read<RealisasiVisitBloc>().add(
          RejectRealisasiVisitEvent(
            idAtasan: widget.userId,
            idSchedule: scheduleIds,
          ),
        );
  }

  bool _filterSchedule(RealisasiVisitDetail schedule) {
    if (_searchQuery.isEmpty) {
      return true;
    }

    final String query = _searchQuery.toLowerCase();
    final String doctorName = schedule.tujuanData.namaDokter.toLowerCase();
    final DateTime visitDate = DateTime.parse(schedule.tglVisit);
    final String formattedDate =
        DateFormat('dd MMM yyyy').format(visitDate).toLowerCase();
    final String status = schedule.statusTerrealisasi.toLowerCase();
    final String shift = schedule.shift.toLowerCase();
    final String jenis = schedule.jenis.toLowerCase();
    final String products = schedule.productData
        .map((product) => product.namaProduct.toLowerCase())
        .join(' ');

    switch (_selectedFilter) {
      case 'Dokter':
        return doctorName.contains(query);
      case 'Tanggal':
        return formattedDate.contains(query);
      case 'Status':
        return status.contains(query) ||
            shift.contains(query) ||
            jenis.contains(query);
      case 'Produk':
        return products.contains(query);
      default: // 'Semua'
        return doctorName.contains(query) ||
            formattedDate.contains(query) ||
            status.contains(query) ||
            shift.contains(query) ||
            jenis.contains(query) ||
            products.contains(query);
    }
  }
}
