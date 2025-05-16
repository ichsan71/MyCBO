import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/util/injection_container.dart';
import '../../../../core/presentation/widgets/app_bar_widget.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/approval.dart';
import '../bloc/approval_bloc.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_overlay_loading.dart';

class ApprovalDetailPage extends StatelessWidget {
  final Approval approval;
  final int userId;

  const ApprovalDetailPage({
    Key? key,
    required this.approval,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ApprovalBloc>(),
      child: ApprovalDetailView(
        approval: approval,
        userId: userId,
      ),
    );
  }
}

class ApprovalDetailView extends StatefulWidget {
  final Approval approval;
  final int userId;

  const ApprovalDetailView({
    Key? key,
    required this.approval,
    required this.userId,
  }) : super(key: key);

  @override
  _ApprovalDetailViewState createState() => _ApprovalDetailViewState();
}

class _ApprovalDetailViewState extends State<ApprovalDetailView> {
  final TextEditingController _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showApprovalDialog(bool isApprove, {int? scheduleId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isApprove ? 'Setujui Jadwal' : 'Tolak Jadwal',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isApprove
                  ? scheduleId != null
                      ? 'Apakah Anda yakin ingin menyetujui jadwal ini?'
                      : 'Apakah Anda yakin ingin menyetujui semua jadwal?'
                  : 'Apakah Anda yakin ingin menolak jadwal ini?',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        actions: [
          AppButton(
            text: 'Batal',
            onPressed: () => Navigator.pop(context),
            type: AppButtonType.outline,
          ),
          AppButton(
            text: isApprove ? 'Setujui' : 'Tolak',
            onPressed: () {
              Navigator.pop(context);
              if (scheduleId != null) {
                _processApproval(scheduleId, isApprove);
              } else {
                _processAllApprovals(isApprove);
              }
            },
            type: isApprove ? AppButtonType.success : AppButtonType.error,
          ),
        ],
      ),
    );
  }

  void _processApproval(int scheduleId, bool isApprove) {
    setState(() => _isProcessing = true);
    context.read<ApprovalBloc>().add(
          SendApprovalEvent(
            scheduleId: scheduleId,
            userId: widget.userId,
            isApproved: isApprove,
          ),
        );
  }

  void _processAllApprovals(bool isApprove) {
    setState(() => _isProcessing = true);
    // Hitung total jadwal yang belum disetujui/ditolak
    int totalPending =
        widget.approval.details.where((d) => d.approved == 0).length;
    int processed = 0;

    // Proses semua jadwal satu per satu
    for (var detail in widget.approval.details) {
      if (detail.approved == 0) {
        // Hanya proses yang belum disetujui/ditolak
        context.read<ApprovalBloc>().add(
              SendApprovalEvent(
                scheduleId: detail.id,
                userId: widget.userId,
                isApproved: isApprove,
              ),
            );
        processed++;

        // Jika ini adalah jadwal terakhir yang diproses, tampilkan snackbar
        if (processed == totalPending) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isApprove
                  ? 'Semua jadwal berhasil disetujui'
                  : 'Semua jadwal berhasil ditolak'),
              backgroundColor:
                  isApprove ? AppTheme.successColor : AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
            ),
          );
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Detail Persetujuan',
      ),
      body: BlocConsumer<ApprovalBloc, ApprovalState>(
        listener: (context, state) {
          if (state is ApprovalSent) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
              ),
            );
            Navigator.pop(context);
          } else if (state is ApprovalError) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ApprovalSending || _isProcessing) {
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
                    if (widget.approval.approved == 0) ...[
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Setujui Semua',
                              onPressed: () => _showApprovalDialog(true),
                              type: AppButtonType.success,
                              isFullWidth: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppButton(
                              text: 'Tolak Semua',
                              onPressed: () => _showApprovalDialog(false),
                              type: AppButtonType.error,
                              isFullWidth: true,
                            ),
                          ),
                        ],
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
                    const SizedBox(height: 16),
                    _buildScheduleList(),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                radius: 24,
                child: Text(
                  widget.approval.namaBawahan[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.approval.namaBawahan,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'ID: ${widget.approval.idBawahan}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                  'Total Jadwal', '${widget.approval.details.length}'),
              _buildInfoItem(
                'Menunggu',
                '${widget.approval.details.where((d) => d.approved == 0).length}',
              ),
              _buildInfoItem(
                'Disetujui',
                '${widget.approval.details.where((d) => d.approved == 1).length}',
              ),
              _buildInfoItem(
                'Ditolak',
                '${widget.approval.details.where((d) => d.approved == 2).length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (widget.approval.approved) {
      case 0:
        color = AppTheme.warningColor;
        text = 'Menunggu';
        break;
      case 1:
        color = AppTheme.successColor;
        text = 'Disetujui';
        break;
      case 2:
        color = AppTheme.errorColor;
        text = 'Ditolak';
        break;
      default:
        color = Colors.grey;
        text = 'Tidak Diketahui';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    if (widget.approval.details.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada jadwal',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.approval.details.length,
      itemBuilder: (context, index) {
        final detail = widget.approval.details[index];
        return _buildScheduleCard(detail);
      },
    );
  }

  Widget _buildScheduleCard(dynamic detail) {
    // Handle null safety untuk approved
    final int approvedStatus = detail.approved ?? 0;

    Color statusColor;
    String statusText;

    switch (approvedStatus) {
      case 0:
        statusColor = AppTheme.warningColor;
        statusText = 'Menunggu';
        break;
      case 1:
        statusColor = AppTheme.successColor;
        statusText = 'Disetujui';
        break;
      case 2:
        statusColor = AppTheme.errorColor;
        statusText = 'Ditolak';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Tidak Diketahui';
    }

    // Dapatkan informasi dokter dan klinik dari tujuanData dengan null safety
    final hasTujuanData = detail.tujuanData != null;
    final String doctorName = hasTujuanData &&
            detail.tujuanData.namaDokter != null &&
            detail.tujuanData.namaDokter.isNotEmpty
        ? detail.tujuanData.namaDokter
        : 'Dokter';
    final String clinicName = hasTujuanData &&
            detail.tujuanData.namaKlinik != null &&
            detail.tujuanData.namaKlinik.isNotEmpty
        ? detail.tujuanData.namaKlinik
        : '';

    // Tanggal kunjungan dengan null safety
    final String visitDate =
        detail.tglVisit != null && detail.tglVisit.isNotEmpty
            ? detail.tglVisit
            : '-';

    // Tipe jadwal dengan null safety
    final String scheduleType =
        detail.typeSchedule != null && detail.typeSchedule.isNotEmpty
            ? detail.typeSchedule
            : 'Jadwal Reguler';

    // Shift dengan null safety
    final String shift =
        detail.shift != null && detail.shift.isNotEmpty ? detail.shift : '-';

    // Note dengan null safety
    final String note = detail.note != null ? detail.note : '';

    // Product data dengan null safety
    final hasProductData =
        detail.productData != null && detail.productData.isNotEmpty;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  doctorName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusLarge),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (clinicName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              clinicName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Tanggal: $visitDate',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Shift: $shift',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.category,
                size: 16,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Tipe: $scheduleType',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),

          // Tampilkan produk jika ada
          if (hasProductData) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Produk:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...detail.productData.map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          product.namaProduct ?? 'Produk',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          // Tampilkan catatan jika ada
          if (note.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Catatan:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              note,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],

          // Tombol aksi untuk jadwal yang menunggu persetujuan
          if (approvedStatus == 0)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Setujui',
                      onPressed: () =>
                          _showApprovalDialog(true, scheduleId: detail.id),
                      type: AppButtonType.success,
                      isFullWidth: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      text: 'Tolak',
                      onPressed: () =>
                          _showApprovalDialog(false, scheduleId: detail.id),
                      type: AppButtonType.error,
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
