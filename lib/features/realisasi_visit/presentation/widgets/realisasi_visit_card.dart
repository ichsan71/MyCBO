import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

    // Cek apakah ada jadwal yang melewati batas approval
    final overdueInfo = _getOverdueApprovalInfo();

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
              // Warning banner untuk jadwal yang melewati batas approval
              if (overdueInfo.hasOverdue) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.errorColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${overdueInfo.overdueCount} jadwal melewati batas approval',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
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

  // Helper function untuk mendeteksi jadwal yang melewati batas approval
  OverdueInfo _getOverdueApprovalInfo() {
    int overdueCount = 0;

    for (final detail in realisasiVisit.details) {
      // Hanya cek jadwal yang status "done" tapi belum disetujui
      if (detail.statusTerrealisasi.toLowerCase() == 'done' &&
          detail.realisasiVisitApproved == null) {
        final DateTime? visitDate = _parseVisitDate(detail.tglVisit);
        if (visitDate != null) {
          final DateTime now = DateTime.now();
          final DateTime today = DateTime(now.year, now.month, now.day);
          final DateTime yesterday = today.subtract(const Duration(days: 1));
          final DateTime visitDateOnly =
              DateTime(visitDate.year, visitDate.month, visitDate.day);

          // Case 1: Visit kemarin - deadline adalah hari ini jam 12 siang
          if (visitDateOnly.isAtSameMomentAs(yesterday)) {
            final DateTime deadline =
                DateTime(now.year, now.month, now.day, 12, 0);
            if (now.isAfter(deadline)) {
              overdueCount++;
            }
          }
          // Case 2: Visit lebih dari 1 hari yang lalu - sudah pasti lewat deadline
          else if (visitDateOnly.isBefore(yesterday)) {
            overdueCount++;
          }
        }
      }
    }

    return OverdueInfo(
      hasOverdue: overdueCount > 0,
      overdueCount: overdueCount,
    );
  }

  // Helper function untuk parse tanggal (sama dengan di detail page)
  DateTime? _parseVisitDate(String dateStr) {
    try {
      // Remove any leading/trailing whitespace
      dateStr = dateStr.trim();

      // Try ISO format first (yyyy-MM-dd)
      if (dateStr.contains('-') && dateStr.split('-').length == 3) {
        try {
          return DateTime.parse(dateStr);
        } catch (_) {
          // Continue to other formats if ISO parsing fails
        }
      }

      // Try MM/dd/yyyy format
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          try {
            final month = int.parse(parts[0]);
            final day = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            return DateTime(year, month, day);
          } catch (_) {
            // Continue to other formats
          }
        }
      }

      // Try dd MMM yyyy format (e.g., "01 Jul 2025")
      try {
        final ddMMMyyyyFormat = DateFormat('dd MMM yyyy', 'en_US');
        return ddMMMyyyyFormat.parse(dateStr);
      } catch (_) {
        // Continue to other formats
      }

      // Try dd/MM/yyyy format
      try {
        final ddMMyyyyFormat = DateFormat('dd/MM/yyyy');
        return ddMMyyyyFormat.parse(dateStr);
      } catch (_) {
        // Continue to other formats
      }

      // Try dd-MM-yyyy format
      try {
        final ddMMyyyyDashFormat = DateFormat('dd/MM/yyyy');
        return ddMMyyyyDashFormat.parse(dateStr.replaceAll('-', '/'));
      } catch (_) {
        // Continue to other formats
      }

      // Try yyyy-MM-dd format with different separators
      try {
        final yyyyMMddFormat = DateFormat('yyyy-MM-dd');
        return yyyyMMddFormat.parse(dateStr);
      } catch (_) {
        // Continue to other formats
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.primaryColor,
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

// Class untuk menyimpan informasi overdue
class OverdueInfo {
  final bool hasOverdue;
  final int overdueCount;

  const OverdueInfo({
    required this.hasOverdue,
    required this.overdueCount,
  });
}
