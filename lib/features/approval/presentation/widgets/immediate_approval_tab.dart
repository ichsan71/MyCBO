import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/approval.dart';
import '../bloc/approval_bloc.dart';

class ImmediateApprovalTab extends StatelessWidget {
  const ImmediateApprovalTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApprovalBloc, ApprovalState>(
      builder: (context, state) {
        if (state is ApprovalLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ApprovalError) {
          return Center(child: Text(state.message));
        } else if (state is ApprovalLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.approvals.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Setujui Semua Jadwal',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Text(
                                  'Apakah Anda yakin ingin menyetujui semua jadwal?',
                                  style: GoogleFonts.poppins(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Batal',
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      for (var approval in state.approvals) {
                                        if (approval.approved == 0) {
                                          context.read<ApprovalBloc>().add(
                                                ApproveRequest(
                                                  approvalId: approval.id,
                                                  notes: '',
                                                  context: context,
                                                ),
                                              );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successColor,
                                    ),
                                    child: Text(
                                      'Setujui Semua',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
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
                            String comment = '';
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Tolak Semua Jadwal',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Apakah Anda yakin ingin menolak semua jadwal?',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      onChanged: (value) => comment = value,
                                      decoration: InputDecoration(
                                        labelText: 'Alasan Penolakan',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      maxLines: 3,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Batal',
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (comment.trim().isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'Alasan penolakan harus diisi'),
                                            backgroundColor:
                                                AppTheme.errorColor,
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.pop(context);
                                      for (var approval in state.approvals) {
                                        if (approval.approved == 0) {
                                          context.read<ApprovalBloc>().add(
                                                RejectRequest(
                                                  idSchedule:
                                                      approval.id.toString(),
                                                  idRejecter: approval.userId
                                                      .toString(),
                                                  comment: comment,
                                                  context: context,
                                                ),
                                              );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.errorColor,
                                    ),
                                    child: Text(
                                      'Tolak Semua',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
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
                );
              }
              final approval = state.approvals[index - 1];
              return _buildApprovalCard(context, approval);
            },
          );
        }
        return const Center(child: Text('Tidak ada data'));
      },
    );
  }

  Widget _buildApprovalCard(BuildContext context, Approval approval) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
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
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Tanggal: ${approval.tglVisit}',
                      ),
                      _buildDetailRow(
                        Icons.location_on,
                        'Tujuan: ${approval.tujuan}',
                      ),
                      if (approval.note.isNotEmpty)
                        _buildDetailRow(
                          Icons.note,
                          'Catatan: ${approval.note}',
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _showRejectDialog(context, approval);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.close, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tolak',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<ApprovalBloc>().add(
                          ApproveRequest(
                            approvalId: approval.id,
                            notes: '',
                            context: context,
                          ),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Setujui',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
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

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, Approval approval) {
    String comment = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Alasan Penolakan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          onChanged: (value) => comment = value,
          decoration: InputDecoration(
            hintText: 'Masukkan alasan penolakan',
            hintStyle: GoogleFonts.poppins(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ApprovalBloc>().add(
                    RejectRequest(
                      idSchedule: approval.id.toString(),
                      idRejecter: approval.userId.toString(),
                      comment: comment,
                      context: context,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Tolak',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
