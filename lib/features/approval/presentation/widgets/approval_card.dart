import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/presentation/theme/app_theme.dart';
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
    // Hitung jumlah jadwal untuk setiap status
    final int totalMenunggu = approval.details.where((d) => d.approved == 0).length;
    final int totalDisetujui = approval.details.where((d) => d.approved == 1).length;
    final int totalDitolak = approval.details.where((d) => d.approved == 2).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.borderRadiusMedium,
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.borderRadiusMedium,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Periode: ${approval.month}/${approval.year}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(totalMenunggu),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Total Jadwal',
                approval.totalSchedule.toString(),
                Icons.calendar_today,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Dokter',
                approval.jumlahDokter,
                Icons.medical_services,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Klinik',
                approval.jumlahKlinik,
                Icons.local_hospital,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatusIndicator('Menunggu', totalMenunggu, Colors.orange),
                  const SizedBox(width: 16),
                  _buildStatusIndicator('Disetujui', totalDisetujui, Colors.green),
                  const SizedBox(width: 16),
                  _buildStatusIndicator('Ditolak', totalDitolak, Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int totalMenunggu) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: totalMenunggu > 0
            ? AppTheme.warningColor.withOpacity(0.15)
            : AppTheme.successColor.withOpacity(0.15),
        borderRadius: AppTheme.borderRadiusSmall,
        border: Border.all(
          color: totalMenunggu > 0
              ? AppTheme.warningColor.withOpacity(0.3)
              : AppTheme.successColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        totalMenunggu > 0 ? 'Menunggu' : 'Diproses',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: totalMenunggu > 0 ? AppTheme.warningColor : AppTheme.successColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 4),
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

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '$label: $count',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
