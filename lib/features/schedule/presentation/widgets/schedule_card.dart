import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final lowerDraft = schedule.draft.toLowerCase().trim();
    final statusColor = ScheduleStatusHelper.getStatusColor(
      schedule.statusCheckin,
      schedule.draft,
    );
    final displayStatus = ScheduleStatusHelper.getDisplayStatus(
      context,
      schedule.statusCheckin,
      schedule.draft,
      schedule.approved,
      schedule.namaApprover,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color:
          lowerDraft.contains('rejected') ? Colors.red.shade50 : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: statusColor,
                width: 8,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(displayStatus, statusColor, lowerDraft),
                if (schedule.namaApprover?.isNotEmpty ?? false)
                  _buildApproverInfo(lowerDraft),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today,
                  schedule.tglVisit,
                  lowerDraft,
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.access_time,
                  'Shift ${schedule.shift}',
                  lowerDraft,
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.medical_services_outlined,
                  schedule.tipeSchedule,
                  lowerDraft,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      String displayStatus, Color statusColor, String lowerDraft) {
    return Row(
      children: [
        Expanded(
          child: Text(
            schedule.namaTujuan,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: lowerDraft.contains('rejected')
                  ? Colors.red.shade700
                  : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            displayStatus,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApproverInfo(String lowerDraft) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        schedule.approved == 1
            ? 'Disetujui oleh ${schedule.namaApprover}'
            : lowerDraft.contains('rejected')
                ? 'Ditolak oleh ${schedule.namaApprover}'
                : '',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: lowerDraft.contains('rejected')
              ? Colors.red.shade700
              : Colors.green.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, String lowerDraft) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: lowerDraft.contains('rejected')
              ? Colors.red.shade400
              : Colors.grey[700],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: lowerDraft.contains('rejected')
                  ? Colors.red.shade400
                  : Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
