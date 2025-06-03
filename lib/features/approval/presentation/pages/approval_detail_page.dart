import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/logger.dart';
import '../../../schedule/domain/entities/tipe_schedule.dart';
import '../../../schedule/presentation/bloc/tipe_schedule_bloc.dart';
import '../../domain/entities/approval.dart' as approval;
import '../../domain/entities/monthly_approval.dart' as monthly;
import '../../domain/entities/schedule.dart' as schedule;
import '../bloc/approval_bloc.dart';
import '../bloc/monthly_approval_bloc.dart';
import '../widgets/schedule_card.dart';
import '../../../../core/presentation/widgets/custom_confirmation_dialog.dart';

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
            final scheduleTypeIdInt = int.tryParse(typeScheduleId) ?? 0;
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
  final dynamic approval;
  final String userId;
  final bool isMonthlyTab;

  const ApprovalDetailPage({
    Key? key,
    required this.approval,
    required this.userId,
    required this.isMonthlyTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<MonthlyApprovalBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<ApprovalBloc>(),
        ),
      ],
      child: ApprovalDetailView(
        approval: approval,
        userId: userId,
        isMonthlyTab: isMonthlyTab,
      ),
    );
  }
}

class ApprovalDetailView extends StatefulWidget {
  final dynamic approval;
  final String userId;
  final bool isMonthlyTab;

  const ApprovalDetailView({
    Key? key,
    required this.approval,
    required this.userId,
    required this.isMonthlyTab,
  }) : super(key: key);

  @override
  State<ApprovalDetailView> createState() => _ApprovalDetailViewState();
}

class _ApprovalDetailViewState extends State<ApprovalDetailView>
    with AutomaticKeepAliveClientMixin {
  final Set<int> _selectedScheduleIds = {};
  final Set<String> _joinVisitScheduleIds = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Logger.info('ApprovalDetailView', 'initState dipanggil');
    if (kDebugMode) {
      print('🔄 ApprovalDetailView initState');
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
    super.dispose();
  }

  void _onScheduleSelect(int scheduleId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedScheduleIds.add(scheduleId);
      } else {
        _selectedScheduleIds.remove(scheduleId);
      }
    });
  }

  void _onJoinVisitChanged(int scheduleId, bool isJoinVisit) {
    setState(() {
      if (isJoinVisit) {
        _joinVisitScheduleIds.add(scheduleId.toString());
      } else {
        _joinVisitScheduleIds.remove(scheduleId.toString());
      }
    });
  }

  schedule.Schedule _convertToSchedule(dynamic detail) {
    if (detail is monthly.MonthlyScheduleDetail) {
      return schedule.Schedule(
        idSchedule: detail.id,
        tglVisit: detail.tglVisit,
        shift: detail.shift,
        approved: 0,
        note: detail.note,
        tujuanData: schedule.TujuanData(
          namaDokter: detail.tujuanData.namaDokter,
          namaKlinik: '',
        ),
        productData: detail.productData
            .map((p) => schedule.ProductData(namaProduct: p.namaProduct))
            .toList(),
      );
    } else if (detail is approval.Detail) {
      return schedule.Schedule(
        idSchedule: detail.id,
        tglVisit: detail.tglVisit,
        shift: detail.shift,
        approved: detail.approved,
        note: detail.note,
        tujuanData: schedule.TujuanData(
          namaDokter: detail.tujuanData.namaDokter,
          namaKlinik: detail.tujuanData.namaKlinik,
        ),
        productData: detail.productData
            .map((p) => schedule.ProductData(namaProduct: p.namaProduct))
            .toList(),
      );
    } else {
      throw Exception('Unsupported detail type');
    }
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
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
            Text(
              'Ringkasan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Total Jadwal',
                    widget.isMonthlyTab
                        ? (widget.approval as monthly.MonthlyApproval)
                            .totalSchedule
                            .toString()
                        : (widget.approval as approval.Approval)
                            .totalSchedule
                            .toString(),
                    Icons.calendar_month,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Dokter',
                    widget.isMonthlyTab
                        ? (widget.approval as monthly.MonthlyApproval)
                            .jumlahDokter
                            .toString()
                        : (widget.approval as approval.Approval)
                            .jumlahDokter
                            .toString(),
                    Icons.medical_services,
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedScheduleIds.isEmpty || _isLoading
                        ? null
                        : () => _handleApprove(),
                    icon: const Icon(Icons.check),
                    label: Text(
                      'Setujui yang Dipilih',
                      style: GoogleFonts.poppins(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppTheme.successColor.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedScheduleIds.isEmpty || _isLoading
                        ? null
                        : () => _handleReject(),
                    icon: const Icon(Icons.close),
                    label: Text(
                      'Tolak yang Dipilih',
                      style: GoogleFonts.poppins(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppTheme.errorColor.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleListSliver() {
    final List<dynamic> details = widget.isMonthlyTab
        ? (widget.approval as monthly.MonthlyApproval).details
        : (widget.approval as approval.Approval).details;

    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final schedule = _convertToSchedule(details[index]);
            final isSelected =
                _selectedScheduleIds.contains(schedule.idSchedule);
            final isJoinVisit =
                _joinVisitScheduleIds.contains(schedule.idSchedule.toString());
            final canJoinVisit = widget.isMonthlyTab && isSelected;

            return ScheduleCard(
              schedule: schedule,
              isSelected: isSelected,
              onSelect: (selected) =>
                  _onScheduleSelect(schedule.idSchedule, selected),
              isMonthlyTab: widget.isMonthlyTab,
              isJoinVisit: isJoinVisit,
              canJoinVisit: canJoinVisit,
              onJoinVisitChanged: (value) =>
                  _onJoinVisitChanged(schedule.idSchedule, value),
            );
          },
          childCount: details.length,
        ),
      ),
    );
  }

  void _handleApprove() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const CustomConfirmationDialog(
        title: 'Konfirmasi Persetujuan',
        message: 'Apakah Anda yakin ingin menyetujui jadwal ini?',
        showTextField: true,
        hintText: 'Tambahkan catatan (opsional)',
        confirmText: 'Setujui',
        minLength: 10,
        maxLength: 200,
      ),
    );

    if (result != null) {
      if (!mounted) return;

      if (widget.isMonthlyTab) {
        final monthlyApproval = widget.approval as monthly.MonthlyApproval;
        context.read<MonthlyApprovalBloc>().add(
              SendMonthlyApproval(
                scheduleIds: _selectedScheduleIds.toList(),
                scheduleJoinVisitIds: _joinVisitScheduleIds.toList(),
                userId: monthlyApproval.idBawahan,
                userAtasanId: int.parse(widget.userId),
              ),
            );
      } else {
        final immediateApproval = widget.approval as approval.Approval;
        final scheduleId = immediateApproval.details.first.id;
        context.read<ApprovalBloc>().add(
              ApproveRequest(
                approvalId: scheduleId,
                notes: result,
              ),
            );
      }
    }
  }

  void _handleReject() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const CustomConfirmationDialog(
        title: 'Konfirmasi Penolakan',
        message: 'Apakah Anda yakin ingin menolak jadwal ini?',
        showTextField: true,
        hintText: 'Berikan alasan penolakan',
        confirmText: 'Tolak',
        isDestructive: true,
        minLength: 10,
        maxLength: 200,
      ),
    );

    if (result != null) {
      if (!mounted) return;

      if (widget.isMonthlyTab) {
        final monthlyApproval = widget.approval as monthly.MonthlyApproval;
        context.read<MonthlyApprovalBloc>().add(
              SendMonthlyApproval(
                scheduleIds: _selectedScheduleIds.toList(),
                scheduleJoinVisitIds: [],
                userId: monthlyApproval.idBawahan,
                userAtasanId: int.parse(widget.userId),
                isRejected: true,
                comment: result,
              ),
            );
      } else {
        final immediateApproval = widget.approval as approval.Approval;
        context.read<ApprovalBloc>().add(
              RejectRequest(
                idSchedule: immediateApproval.id.toString(),
                idRejecter: widget.userId,
                comment: result,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Persetujuan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MonthlyApprovalBloc, MonthlyApprovalState>(
            listener: (context, state) {
              setState(() => _isLoading = state is MonthlyApprovalLoading);

              if (state is MonthlyApprovalSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: AppTheme.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
                Navigator.pop(context);
              } else if (state is MonthlyApprovalError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: AppTheme.errorColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
          ),
          BlocListener<ApprovalBloc, ApprovalState>(
            listener: (context, state) {
              setState(() => _isLoading = state is ApprovalLoading);

              if (state is ApprovalSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: AppTheme.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
                Navigator.pop(context);
              } else if (state is ApprovalError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: AppTheme.errorColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
          ),
        ],
        child: Container(
          color: Colors.grey[50],
          child: CustomScrollView(
            slivers: [
              _buildHeaderSection(),
              _buildScheduleListSliver(),
            ],
          ),
        ),
      ),
    );
  }
}
