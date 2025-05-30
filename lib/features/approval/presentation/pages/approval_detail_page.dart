import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_bar_widget.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_card.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/logger.dart';
import '../../../schedule/domain/entities/tipe_schedule.dart';
import '../../../schedule/presentation/bloc/tipe_schedule_bloc.dart';
import '../../domain/entities/approval.dart';
import '../bloc/approval_bloc.dart';

class ScheduleTypeDisplay extends StatelessWidget {
  final String typeScheduleId;

  const ScheduleTypeDisplay({
    Key? key,
    required this.typeScheduleId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TipeScheduleBloc, TipeScheduleState>(
      builder: (context, state) {
        String displayName = typeScheduleId;

        if (state is TipeScheduleLoaded && state.tipeSchedules.isNotEmpty) {
          try {
            // Konversi typeScheduleId ke int untuk perbandingan
            final scheduleTypeIdInt = int.tryParse(typeScheduleId) ?? 0;

            // Cari tipe schedule berdasarkan ID
            final scheduleType = state.tipeSchedules.firstWhere(
              (type) => type.id == scheduleTypeIdInt,
              orElse: () => const TipeSchedule(
                id: 0,
                name: '',
                createdAt: '',
              ),
            );

            displayName = scheduleType.name;
            Logger.info('TipeSchedule',
                'Berhasil mendapatkan tipe jadwal: $displayName');
          } catch (e) {
            Logger.error('TipeSchedule', 'Error mendapatkan tipe jadwal: $e');
            displayName = 'Tidak Diketahui';
          }
        }

        return Row(
          children: [
            Icon(
              Icons.category,
              size: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Tipe: ',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                displayName.isNotEmpty ? displayName : '-',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}

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
    // Selalu buat instance baru dari service locator
    final approvalBloc = sl<ApprovalBloc>();
    final tipeScheduleBloc = sl<TipeScheduleBloc>();

    // Mulai mengambil data type schedule
    tipeScheduleBloc.add(const GetTipeSchedulesEvent());

    return MultiBlocProvider(
      providers: [
        BlocProvider<ApprovalBloc>.value(
          value: approvalBloc,
        ),
        BlocProvider<TipeScheduleBloc>.value(
          value: tipeScheduleBloc,
        ),
      ],
      child: ApprovalDetailView(
        approval: approval,
        userId: userId,
        // Berikan bloc ke view untuk menutupnya ketika dispose
        approvalBloc: approvalBloc,
        tipeScheduleBloc: tipeScheduleBloc,
      ),
    );
  }
}

class ApprovalDetailView extends StatefulWidget {
  final Approval approval;
  final int userId;
  final ApprovalBloc approvalBloc;
  final TipeScheduleBloc tipeScheduleBloc;

  const ApprovalDetailView({
    Key? key,
    required this.approval,
    required this.userId,
    required this.approvalBloc,
    required this.tipeScheduleBloc,
  }) : super(key: key);

  @override
  State<ApprovalDetailView> createState() => _ApprovalDetailViewState();
}

class _ApprovalDetailViewState extends State<ApprovalDetailView>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _notesController = TextEditingController();
  String? _notesError;
  bool _isProcessing = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Logger.info('ApprovalDetailView', 'initState dipanggil');
    // Bukan lagi di initState karena sudah dipindahkan ke create BlocProvider
    if (kDebugMode) {
      print('🔄 ApprovalDetailView initState');
      // Debug untuk melihat detail approval
      print('🔄 Approval details: ${widget.approval.details.length} items');
      if (widget.approval.details.isNotEmpty) {
        final firstDetail = widget.approval.details.first;
        print(
            '🔄 First detail - typeSchedule: ${firstDetail.typeSchedule}, tujuan: ${firstDetail.tujuan}');
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    // Jangan tutup bloc di sini, karena akan ditangani oleh service locator
    super.dispose();
  }

  void _showApprovalDialog(bool isApprove, {int? scheduleId}) {
    if (!mounted) return;
    _notesError = null;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            backgroundColor: Colors.white,
            elevation: 24,
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isApprove
                        ? AppTheme.successColor.withOpacity(0.12)
                        : AppTheme.errorColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isApprove
                            ? AppTheme.successColor.withOpacity(0.18)
                            : AppTheme.errorColor.withOpacity(0.18),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    isApprove ? Icons.check_circle : Icons.cancel,
                    color:
                        isApprove ? AppTheme.successColor : AppTheme.errorColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isApprove ? 'Setujui Jadwal' : 'Tolak Jadwal',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    isApprove
                        ? scheduleId != null
                            ? 'Apakah Anda yakin ingin menyetujui jadwal ini?'
                            : 'Apakah Anda yakin ingin menyetujui semua jadwal?'
                        : 'Apakah Anda yakin ingin menolak jadwal ini?',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Colors.grey, thickness: 0.3),
                  const SizedBox(height: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _notesController,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Catatan (minimal 50 karakter)',
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: AppTheme.borderRadiusSmall,
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppTheme.borderRadiusSmall,
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppTheme.borderRadiusSmall,
                            borderSide: BorderSide(
                                color: AppTheme.primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          filled: true,
                          fillColor: Colors.grey[50],
                          errorText: _notesError,
                        ),
                        maxLines: 3,
                        onChanged: (_) {
                          if (_notesError != null) {
                            setStateDialog(() {
                              _notesError = null;
                            });
                          }
                          setStateDialog(() {}); // update counter
                        },
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final notes = _notesController.text;
                          final charCount = notes.length;
                          return Text(
                            '$charCount/50 karakter',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: charCount >= 50 ? Colors.blue : Colors.red,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withOpacity(0.18),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tindakan ini tidak dapat dibatalkan.',
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
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.borderRadiusLarge,
            ),
            actions: [
              AppButton(
                text: 'Batal',
                onPressed: () => Navigator.pop(dialogContext),
                type: AppButtonType.outline,
                prefixIcon: const Icon(Icons.close, size: 16),
                fontSize: 14,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              ),
              AppButton(
                text: isApprove ? 'Setujui' : 'Tolak',
                onPressed: () {
                  final notes = _notesController.text;
                  final charCount = notes.length;
                  if (notes.trim().isEmpty) {
                    setStateDialog(() {
                      _notesError = 'Catatan wajib diisi.';
                    });
                    return;
                  } else if (charCount < 50) {
                    setStateDialog(() {
                      _notesError = 'Catatan minimal 50 karakter.';
                    });
                    return;
                  }
                  Navigator.pop(dialogContext);
                  if (scheduleId != null) {
                    _processApproval(scheduleId, isApprove);
                  } else {
                    _processAllApprovals(isApprove);
                  }
                },
                type: isApprove ? AppButtonType.success : AppButtonType.error,
                prefixIcon: Icon(
                  isApprove ? Icons.check : Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
                fontSize: 14,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              ),
            ],
          ),
        );
      },
    );
  }

  void _processApproval(int scheduleId, bool isApprove) {
    if (!mounted) return;
    setState(() => _isProcessing = true);
    if (isApprove) {
      widget.approvalBloc.add(
        SendApprovalEvent(
          scheduleId: scheduleId,
          userId: widget.userId,
          isApproved: true,
        ),
      );
    } else {
      widget.approvalBloc.add(
        RejectRequestEvent(
          idSchedule: scheduleId.toString(),
          idRejecter: widget.userId.toString(),
          comment: _notesController.text,
        ),
      );
    }
  }

  void _processAllApprovals(bool isApprove) {
    if (!mounted) return;
    setState(() => _isProcessing = true);
    final pendingDetails =
        widget.approval.details.where((d) => d.approved == 0).toList();
    if (isApprove) {
      int totalPending = pendingDetails.length;
      int processed = 0;
      for (var detail in pendingDetails) {
        widget.approvalBloc.add(
          SendApprovalEvent(
            scheduleId: detail.id,
            userId: widget.userId,
            isApproved: true,
          ),
        );
        processed++;
        if (processed == totalPending && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Semua jadwal berhasil disetujui'),
              backgroundColor: AppTheme.successColor,
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.borderRadiusSmall,
              ),
            ),
          );
          Navigator.pop(context);
        }
      }
    } else {
      // Tolak semua sekaligus
      final idList = pendingDetails.map((d) => d.id.toString()).toList();
      final idString = idList.join(',');
      widget.approvalBloc.add(
        RejectRequestEvent(
          idSchedule: idString,
          idRejecter: widget.userId.toString(),
          comment: _notesController.text,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Semua jadwal berhasil ditolak'),
          backgroundColor: AppTheme.errorColor,
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.borderRadiusSmall,
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Don't forget this line if using AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: const AppBarWidget(
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
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
              ),
            );
          } else if (state is ApprovalError) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
              ),
            );
          } else if (state is ApprovalInitial) {
            setState(() => _isProcessing = false);
            Navigator.pop(context);
          } else if (state is ApprovalProcessing || state is ApprovalSending) {
            setState(() => _isProcessing = true);
          }
        },
        builder: (context, state) {
          if (state is ApprovalProcessing ||
              state is ApprovalSending ||
              _isProcessing) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: _buildScheduleListSliver(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'ID: ${widget.approval.idBawahan}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    Color backgroundColor;
    Color borderColor;

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    switch (widget.approval.approved) {
      case 0:
        text = 'Menunggu';
        if (isDark) {
          color = Colors.orange[300]!;
          backgroundColor = Colors.orange[900]!;
          borderColor = Colors.orange[700]!;
        } else {
          color = AppTheme.warningColor;
          backgroundColor = color.withOpacity(0.15);
          borderColor = color.withOpacity(0.3);
        }
        break;
      case 1:
        text = 'Disetujui';
        if (isDark) {
          color = Colors.green[300]!;
          backgroundColor = Colors.green[900]!;
          borderColor = Colors.green[700]!;
        } else {
          color = AppTheme.successColor;
          backgroundColor = color.withOpacity(0.15);
          borderColor = color.withOpacity(0.3);
        }
        break;
      case 2:
        text = 'Ditolak';
        if (isDark) {
          color = Colors.red[300]!;
          backgroundColor = Colors.red[900]!;
          borderColor = Colors.red[700]!;
        } else {
          color = AppTheme.errorColor;
          backgroundColor = color.withOpacity(0.15);
          borderColor = color.withOpacity(0.3);
        }
        break;
      default:
        text = 'Tidak Diketahui';
        if (isDark) {
          color = Colors.grey[300]!;
          backgroundColor = Colors.grey[900]!;
          borderColor = Colors.grey[700]!;
        } else {
          color = Colors.grey;
          backgroundColor = color.withOpacity(0.15);
          borderColor = color.withOpacity(0.3);
        }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppTheme.borderRadiusLarge,
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildScheduleListSliver() {
    if (widget.approval.details.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(
            'Tidak ada jadwal',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final detail = widget.approval.details[index];

          return ScheduleCard(
            detail: detail,
            onApprove: (id) => _showApprovalDialog(true, scheduleId: id),
            onReject: (id) => _showApprovalDialog(false, scheduleId: id),
          );
        },
        childCount: widget.approval.details.length,
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final dynamic detail;
  final Function(int) onApprove;
  final Function(int) onReject;

  const ScheduleCard({
    Key? key,
    required this.detail,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final approvedStatus = detail.approved;
    final doctorName = detail.tujuanData?.namaDokter ?? 'Tidak ada nama';
    final clinicName = detail.tujuanData?.namaKlinik ?? '';
    final visitDate = detail.tglVisit;
    final shift = detail.shift;
    final note = detail.note ?? '';
    final hasProductData = detail.productData?.isNotEmpty ?? false;
    final realisasiStatus = detail.realisasiApprove;

    final Color statusColor;
    final Color backgroundColor;
    final Color borderColor;
    final String statusText;
    final Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final Color secondaryTextColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : Colors.black54;

    switch (approvedStatus) {
      case 1:
        statusColor = AppTheme.successColor;
        backgroundColor = AppTheme.successColor.withOpacity(0.1);
        borderColor = AppTheme.successColor.withOpacity(0.3);
        statusText = 'Disetujui';
        break;
      case 2:
        statusColor = AppTheme.errorColor;
        backgroundColor = AppTheme.errorColor.withOpacity(0.1);
        borderColor = AppTheme.errorColor.withOpacity(0.3);
        statusText = 'Ditolak';
        break;
      default:
        statusColor = AppTheme.warningColor;
        backgroundColor = AppTheme.warningColor.withOpacity(0.1);
        borderColor = AppTheme.warningColor.withOpacity(0.3);
        statusText = 'Menunggu';
    }

    String getRealisasiStatusText() {
      switch (realisasiStatus) {
        case 1:
          return 'Realisasi Disetujui';
        case 2:
          return 'Realisasi Ditolak';
        default:
          return 'Belum Direalisasi';
      }
    }

    Color getRealisasiStatusColor() {
      switch (realisasiStatus) {
        case 1:
          return Colors.green;
        case 2:
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: approvedStatus == 2
              ? AppTheme.errorColor.withOpacity(0.3)
              : approvedStatus == 1
                  ? AppTheme.successColor.withOpacity(0.3)
                  : Colors.grey.shade200,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        if (clinicName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            clinicName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor, width: 1.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              approvedStatus == 0
                                  ? Icons.hourglass_empty
                                  : approvedStatus == 1
                                      ? Icons.check_circle
                                      : Icons.cancel,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (approvedStatus == 1) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: getRealisasiStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: getRealisasiStatusColor().withOpacity(0.3),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                realisasiStatus == 1
                                    ? Icons.check_circle
                                    : realisasiStatus == 2
                                        ? Icons.cancel
                                        : Icons.schedule,
                                size: 14,
                                color: getRealisasiStatusColor(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                getRealisasiStatusText(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: getRealisasiStatusColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      context,
                      Icons.calendar_today,
                      'Tanggal:',
                      visitDate,
                      secondaryTextColor,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
                      Icons.access_time,
                      'Shift:',
                      shift,
                      secondaryTextColor,
                    ),
                    const SizedBox(height: 8),
                    ScheduleTypeDisplay(typeScheduleId: detail.typeSchedule),
                  ],
                ),
              ),
              if (hasProductData && detail.productData != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Produk:',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: detail.productData?.map<Widget>((product) {
                              if (product == null) {
                                return const SizedBox.shrink();
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  product.namaProduct ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              );
                            }).toList() ??
                            [],
                      ),
                    ],
                  ),
                ),
              ],
              if (note.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.note,
                            size: 16,
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Catatan:',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        note,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (approvedStatus == 0) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Setujui',
                        onPressed: () => onApprove(detail.id),
                        type: AppButtonType.success,
                        isFullWidth: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        text: 'Tolak',
                        onPressed: () => onReject(detail.id),
                        type: AppButtonType.error,
                        isFullWidth: true,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color? iconColor,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '-',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
