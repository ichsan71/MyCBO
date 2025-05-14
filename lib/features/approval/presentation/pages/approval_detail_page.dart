import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/util/injection_container.dart';
import '../../domain/entities/approval.dart';
import '../bloc/approval_bloc.dart';
import '../bloc/approval_event.dart';
import '../bloc/approval_state.dart';

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
      child: ApprovalDetailView(approval: approval, userId: userId),
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
  // Tambahkan state untuk tracking jadwal yang sudah disetujui
  final Set<int> _approvedSchedules = {};
  final Set<int> _rejectedSchedules = {};

  @override
  void initState() {
    super.initState();
    // Inisialisasi status jadwal yang sudah disetujui/ditolak
    for (var detail in widget.approval.details) {
      if (detail.approved == 1) {
        _approvedSchedules.add(detail.id);
      } else if (detail.approved == 2) {
        _rejectedSchedules.add(detail.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Persetujuan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: BlocListener<ApprovalBloc, ApprovalState>(
        listener: (context, state) {
          if (state is ApprovalSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message),
                backgroundColor: Colors.green,
              ),
            );
            // Kembali ke halaman sebelumnya setelah sukses
            Future.delayed(const Duration(milliseconds: 1500), () {
              Navigator.pop(context);
            });
          } else if (state is ApprovalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 24),
                  // Tambahkan tombol Setujui Semua jika ada jadwal yang belum disetujui
                  if (widget.approval.details.any((detail) =>
                      !_approvedSchedules.contains(detail.id) &&
                      !_rejectedSchedules.contains(detail.id)))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton.icon(
                        onPressed: _showApproveAllConfirmation,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Setujui Semua Jadwal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ..._buildDetailSections(),
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),

            // Loading overlay
            BlocBuilder<ApprovalBloc, ApprovalState>(
              builder: (context, state) {
                if (state is ApprovalSending) {
                  return Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.approval.namaBawahan,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.approval.approved == 0
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.approval.approved == 0
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                  child: Text(
                    widget.approval.approved == 0
                        ? 'Belum Disetujui'
                        : 'Disetujui',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.approval.approved == 0
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.medical_services_outlined,
              label: 'Total Jadwal',
              value: '${widget.approval.totalSchedule}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Jumlah Dokter',
              value: widget.approval.jumlahDokter,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.local_hospital_outlined,
              label: 'Jumlah Klinik',
              value: widget.approval.jumlahKlinik,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Periode',
              value: '${widget.approval.month}/${widget.approval.year}',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailSections() {
    final List<Widget> sections = [];

    for (var i = 0; i < widget.approval.details.length; i++) {
      final detail = widget.approval.details[i];
      final isApproved = _approvedSchedules.contains(detail.id);
      final isRejected = _rejectedSchedules.contains(detail.id);

      sections.add(
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isApproved
                      ? Colors.green
                      : isRejected
                          ? Colors.red
                          : Colors.blue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jadwal #${i + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (isApproved)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      )
                    else if (isRejected)
                      const Icon(
                        Icons.cancel,
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'Tujuan',
                      value: detail.tujuanData.namaDokter,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Tanggal',
                      value: _formatDate(detail.tglVisit),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.access_time,
                      label: 'Shift',
                      value: detail.shift,
                    ),
                    const SizedBox(height: 12),

                    // Produk section
                    Text(
                      'Produk:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: detail.productData.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.grey.shade300,
                        ),
                        itemBuilder: (context, index) {
                          final product = detail.productData[index];
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              product.namaProduct,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tombol aksi untuk setiap jadwal
                    if (!isApproved && !isRejected)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showRejectConfirmation(context, detail.id),
                              icon: const Icon(Icons.cancel_outlined,
                                  color: Colors.red),
                              label: const Text('Tolak'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _showApproveConfirmation(context, detail.id),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Setujui'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
            ],
          ),
        ),
      );
    }

    return sections;
  }

  void _showApproveAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Persetujuan Semua'),
        content: const Text(
          'Apakah Anda yakin ingin menyetujui semua jadwal yang belum disetujui?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveAllSchedules();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Setujui Semua'),
          ),
        ],
      ),
    );
  }

  void _approveAllSchedules() {
    for (var detail in widget.approval.details) {
      if (!_approvedSchedules.contains(detail.id) &&
          !_rejectedSchedules.contains(detail.id)) {
        _sendApproval(detail.id, true);
      }
    }
  }

  void _showApproveConfirmation(BuildContext context, int scheduleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Persetujuan'),
        content: const Text(
          'Apakah Anda yakin ingin menyetujui jadwal ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendApproval(scheduleId, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showRejectConfirmation(BuildContext context, int scheduleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penolakan'),
        content: const Text(
          'Apakah Anda yakin ingin menolak jadwal ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendApproval(scheduleId, false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _sendApproval(int scheduleId, bool isApproved) {
    context.read<ApprovalBloc>().add(
          SendApprovalEvent(
            scheduleId: scheduleId,
            userId: widget.userId,
            isApproved: isApproved,
          ),
        );

    // Update local state
    setState(() {
      if (isApproved) {
        _approvedSchedules.add(scheduleId);
        _rejectedSchedules.remove(scheduleId);
      } else {
        _rejectedSchedules.add(scheduleId);
        _approvedSchedules.remove(scheduleId);
      }
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
