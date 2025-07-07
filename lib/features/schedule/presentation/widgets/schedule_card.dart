import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/schedule.dart';
import '../utils/schedule_status_helper.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onTap;

  const ScheduleCard({
    Key? key,
    required this.schedule,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.getCardBackgroundColor(context),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      schedule.namaTujuan,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getPrimaryTextColor(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(schedule, context),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${schedule.tipeSchedule}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${schedule.tglVisit}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
              if (schedule.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Note: ${schedule.note}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Schedule schedule, BuildContext context) {
    final statusText = ScheduleStatusHelper.getStatusText(schedule);
    final statusColor = ScheduleStatusHelper.getStatusColor(schedule);
    final statusIcon = ScheduleStatusHelper.getStatusIcon(schedule);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
