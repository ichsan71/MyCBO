import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/realisasi_visit.dart';

class RealisasiVisitCard extends StatelessWidget {
  final RealisasiVisit realisasiVisit;
  final VoidCallback onTap;

  const RealisasiVisitCard({
    Key? key,
    required this.realisasiVisit,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Selesai: status "Done" dan sudah disetujui (realisasi_visit_approved tidak null)
    final int totalSelesai = realisasiVisit.details
        .where((detail) =>
            detail.statusTerrealisasi.toLowerCase() == 'done' &&
            detail.realisasiVisitApproved != null)
        .length;

    // Pending: status "Done" tapi belum disetujui
    final int totalPending = realisasiVisit.details
        .where((detail) =>
            detail.statusTerrealisasi.toLowerCase() == 'done' &&
            detail.realisasiVisitApproved == null)
        .length;

    // Tidak Selesai: status "Not Done" atau status lainnya
    final int totalTidakSelesai = realisasiVisit.details
        .where((detail) =>
            detail.statusTerrealisasi.toLowerCase() == 'not done' ||
            detail.statusTerrealisasi.toLowerCase() == 'notdone' ||
            detail.statusTerrealisasi.toLowerCase() == 'not_done')
        .length;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    realisasiVisit.namaBawahan,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Role: ${realisasiVisit.role}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Total Jadwal',
                realisasiVisit.totalSchedule.toString(),
                Icons.calendar_today,
                context,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Dokter',
                realisasiVisit.jumlahDokter,
                Icons.medical_services,
                context,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Klinik',
                realisasiVisit.jumlahKlinik,
                Icons.local_hospital,
                context,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Terrealisasi',
                '${realisasiVisit.totalTerrealisasi}/${realisasiVisit.totalSchedule}',
                Icons.check_circle,
                context,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.getCardBackgroundColor(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.getBorderColor(context),
                    width: 0.5,
                  ),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildStatusIndicator(
                        'Selesai', totalSelesai, Colors.green, context),
                    _buildStatusIndicator('Tidak Selesai', totalTidakSelesai,
                        Colors.red, context),
                    _buildStatusIndicator(
                        'Menunggu', totalPending, Colors.orange, context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.getSecondaryTextColor(context),
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.getSecondaryTextColor(context),
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

  Widget _buildStatusIndicator(
      String label, int count, Color color, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $count',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.getPrimaryTextColor(context),
          ),
        ),
      ],
    );
  }
}
