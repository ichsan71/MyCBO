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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      shadowColor: AppTheme.primaryColor.withOpacity(0.10),
      color: AppTheme.getCardBackgroundColor(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
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
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Periode:  ${approval.month}/${approval.year}',
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
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.18),
                          AppTheme.primaryColor.withOpacity(0.10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star,
                            color: AppTheme.primaryColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Extra',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    Icons.calendar_today,
                    'Total Jadwal',
                    approval.totalSchedule.toString(),
                  ),
                  _verticalDivider(context),
                  _buildInfoItem(
                    context,
                    Icons.medical_services,
                    'Dokter',
                    approval.jumlahDokter,
                  ),
                  _verticalDivider(context),
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

  Widget _verticalDivider(BuildContext context) {
    return Container(
      height: 36,
      width: 1.2,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: AppTheme.getBorderColor(context).withOpacity(0.25),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 6),
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
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getPrimaryTextColor(context),
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
