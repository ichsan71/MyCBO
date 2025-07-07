import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/monthly_approval.dart';
import 'package:intl/intl.dart';

class MonthlyApprovalCard extends StatelessWidget {
  final MonthlyApproval approval;
  final VoidCallback? onTap;

  const MonthlyApprovalCard({
    Key? key,
    required this.approval,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final monthName =
        DateFormat('MMMM', 'id_ID').format(DateTime(0, approval.month));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.getBorderColor(context)),
      ),
      elevation: 0,
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
                            color: AppTheme.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Periode: $monthName ${approval.year}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Call Plan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    Icons.calendar_today,
                    'Total Jadwal',
                    approval.totalSchedule.toString(),
                  ),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                    context,
                    Icons.medical_services,
                    'Dokter',
                    approval.jumlahDokter,
                  ),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                    context,
                    Icons.local_hospital,
                    'Klinik',
                    approval.jumlahKlinik,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.getSecondaryTextColor(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
