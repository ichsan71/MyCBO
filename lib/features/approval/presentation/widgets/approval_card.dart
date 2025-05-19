import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/approval.dart';

class ApprovalCard extends StatelessWidget {
  final Approval approval;
  final VoidCallback onTap;

  const ApprovalCard({
    Key? key,
    required this.approval,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${approval.month}/${approval.year}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.calendar_today,
                'Total Jadwal: ${approval.totalSchedule}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.local_hospital_outlined,
                'Dokter: ${approval.jumlahDokter}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.location_on_outlined,
                'Klinik: ${approval.jumlahKlinik}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    String statusText;
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (approval.approved) {
      case 1:
        statusText = 'Disetujui';
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        borderColor = Colors.green[300]!;
        break;
      case 2:
        statusText = 'Ditolak';
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[800]!;
        borderColor = Colors.red[300]!;
        break;
      default:
        statusText = 'Menunggu';
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        borderColor = Colors.orange[300]!;
    }

    // Sesuaikan warna untuk mode gelap
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      switch (approval.approved) {
        case 1:
          backgroundColor = Colors.green[900]!;
          textColor = Colors.green[100]!;
          borderColor = Colors.green[700]!;
          break;
        case 2:
          backgroundColor = Colors.red[900]!;
          textColor = Colors.red[100]!;
          borderColor = Colors.red[700]!;
          break;
        default:
          backgroundColor = Colors.orange[900]!;
          textColor = Colors.orange[100]!;
          borderColor = Colors.orange[700]!;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[600]
              : Colors.grey[400],
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[600]
                : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
