import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/monthly_approval.dart';
import '../bloc/monthly_approval_bloc.dart';

class MonthlyApprovalTab extends StatefulWidget {
  const MonthlyApprovalTab({Key? key}) : super(key: key);

  @override
  State<MonthlyApprovalTab> createState() => _MonthlyApprovalTabState();
}

class _MonthlyApprovalTabState extends State<MonthlyApprovalTab> {
  final Map<int, bool> _selectedSchedules = {};
  bool _isJoinVisit = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthlyApprovalBloc, MonthlyApprovalState>(
      builder: (context, state) {
        if (state is MonthlyApprovalLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MonthlyApprovalError) {
          return Center(child: Text(state.message));
        } else if (state is MonthlyApprovalLoaded) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _handleBulkApprove(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.check_circle),
                        label: Text(
                          'Setujui Semua',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _handleBulkReject(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.cancel),
                        label: Text(
                          'Tolak Semua',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.approvals.length,
                  itemBuilder: (context, index) {
                    final approval = state.approvals[index];
                    return _buildApprovalCard(context, approval);
                  },
                ),
              ),
            ],
          );
        }
        return const Center(child: Text('Tidak ada data'));
      },
    );
  }

  Widget _buildApprovalCard(BuildContext context, MonthlyApproval approval) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                approval.namaBawahan,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.calendar_today,
                    'Jadwal: ${approval.totalSchedule}',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.medical_services,
                    'Dokter: ${approval.jumlahDokter}',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.local_hospital,
                    'Klinik: ${approval.jumlahKlinik}',
                  ),
                ],
              ),
            ],
          ),
          children: [
            Column(
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: Text(
                                'Join Visit',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: _isJoinVisit,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isJoinVisit = value ?? false;
                                  if (!_isJoinVisit) {
                                    _selectedSchedules.clear();
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      if (_isJoinVisit)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Pilih jadwal yang akan di-join',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppTheme.secondaryTextColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: approval.details.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final detail = approval.details[index];
                          final isSelected =
                              _selectedSchedules[detail.id] ?? false;

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (_isJoinVisit) {
                                  _selectedSchedules.clear();
                                  _selectedSchedules[detail.id] =
                                      value ?? false;
                                } else {
                                  _selectedSchedules[detail.id] =
                                      value ?? false;
                                }
                              });
                            },
                            title: Text(
                              detail.tujuanData.namaDokter,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                _buildDetailRow(
                                  Icons.calendar_today,
                                  'Tanggal: ${detail.tglVisit}',
                                ),
                                _buildDetailRow(
                                  Icons.access_time,
                                  'Shift: ${detail.shift}',
                                ),
                                _buildDetailRow(
                                  Icons.medical_services,
                                  'Produk: ${detail.productData.map((p) => p.namaProduct).join(", ")}',
                                ),
                                if (detail.note.isNotEmpty)
                                  _buildDetailRow(
                                    Icons.note,
                                    'Catatan: ${detail.note}',
                                  ),
                              ],
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final selectedIds = _selectedSchedules.entries
                                .where((e) => e.value)
                                .map((e) => e.key)
                                .toList();

                            if (selectedIds.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Pilih minimal satu jadwal'),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                              return;
                            }

                            if (_isJoinVisit && selectedIds.length > 1) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Untuk Join Visit, pilih hanya satu jadwal'),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                              return;
                            }

                            context.read<MonthlyApprovalBloc>().add(
                                  SendMonthlyApproval(
                                    scheduleIds: selectedIds,
                                    scheduleJoinVisitIds: _isJoinVisit
                                        ? [selectedIds.first.toString()]
                                        : [],
                                    userId: approval.idBawahan,
                                    userAtasanId: approval.idBawahan,
                                    context: context,
                                  ),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Setujui yang Dipilih',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.secondaryTextColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBulkApprove(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          BlocBuilder<MonthlyApprovalBloc, MonthlyApprovalState>(
        builder: (context, state) {
          if (state is! MonthlyApprovalLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return AlertDialog(
            title: Text('Konfirmasi', style: GoogleFonts.poppins()),
            content: Text(
              'Apakah Anda yakin ingin menyetujui semua jadwal?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal', style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  // Collect all schedule IDs that are not approved yet
                  final scheduleIds = <int>[];
                  for (var approval in state.approvals) {
                    if (approval.approved == 0) {
                      scheduleIds.addAll(
                        approval.details.map((detail) => detail.id).toList(),
                      );
                    }
                  }

                  if (scheduleIds.isNotEmpty) {
                    // Get the first approval to get userId and userAtasanId
                    final approval = state.approvals.first;
                    context.read<MonthlyApprovalBloc>().add(
                          SendMonthlyApproval(
                            scheduleIds: scheduleIds,
                            scheduleJoinVisitIds: const [], // No join visit for bulk approve
                            userId: approval.idBawahan,
                            userAtasanId: approval.idBawahan,
                            context: context,
                          ),
                        );
                  }
                },
                child: Text('Setujui', style: GoogleFonts.poppins()),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleBulkReject(BuildContext context) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) =>
          BlocBuilder<MonthlyApprovalBloc, MonthlyApprovalState>(
        builder: (context, state) {
          if (state is! MonthlyApprovalLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return AlertDialog(
            title: Text('Konfirmasi', style: GoogleFonts.poppins()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Apakah Anda yakin ingin menolak semua jadwal?',
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: 'Alasan Penolakan',
                    labelStyle: GoogleFonts.poppins(),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal', style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () {
                  if (commentController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Alasan penolakan harus diisi',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  // Collect all schedule IDs that are not approved yet
                  final scheduleIds = <int>[];
                  for (var approval in state.approvals) {
                    if (approval.approved == 0) {
                      scheduleIds.addAll(
                        approval.details.map((detail) => detail.id).toList(),
                      );
                    }
                  }

                  if (scheduleIds.isNotEmpty) {
                    // Get the first approval to get userId and userAtasanId
                    final approval = state.approvals.first;
                    context.read<MonthlyApprovalBloc>().add(
                          SendMonthlyApproval(
                            scheduleIds: scheduleIds,
                            scheduleJoinVisitIds: const [], // No join visit for bulk reject
                            userId: approval.idBawahan,
                            userAtasanId: approval.idBawahan,
                            isRejected: true,
                            comment: commentController.text,
                            context: context,
                          ),
                        );
                  }
                },
                child: Text('Tolak', style: GoogleFonts.poppins()),
              ),
            ],
          );
        },
      ),
    );
  }
}
