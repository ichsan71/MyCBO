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
    final int totalDone = realisasiVisit.details
        .where((detail) => detail.statusTerrealisasi == 'Done')
        .length;
    final int totalNotDone = realisasiVisit.details
        .where((detail) => detail.statusTerrealisasi == 'Not Done')
        .length;
    final int totalPending = realisasiVisit.details
        .where((detail) => detail.realisasiVisitApproved == null)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          realisasiVisit.namaBawahan,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
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
                  ),
                  _buildStatusBadge(totalPending),
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
              Row(
                children: [
                  _buildStatusIndicator('Selesai', totalDone, AppTheme.getSuccessColor(context), context),
                  const SizedBox(width: 16),
                  _buildStatusIndicator(
                      'Belum Selesai', totalNotDone, AppTheme.getErrorColor(context), context),
                  const SizedBox(width: 16),
                  _buildStatusIndicator(
                      'Menunggu', totalPending, AppTheme.getWarningColor(context), context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int totalPending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: totalPending > 0
            ? AppTheme.warningColor.withOpacity(0.15)
            : AppTheme.successColor.withOpacity(0.15),
        borderRadius: AppTheme.borderRadiusSmall,
      ),
      child: Text(
        totalPending > 0 ? 'Menunggu' : 'Diproses',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color:
              totalPending > 0 ? AppTheme.warningColor : AppTheme.successColor,
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

  Widget _buildStatusIndicator(String label, int count, Color color, BuildContext context) {
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
                color: AppTheme.getPrimaryTextColor(context),
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
