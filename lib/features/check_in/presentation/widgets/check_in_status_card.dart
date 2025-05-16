import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/check_in_status_helper.dart';

class CheckInStatusCard extends StatelessWidget {
  final String status;
  final String location;
  final String time;
  final VoidCallback? onTap;
  final bool isEnabled;

  const CheckInStatusCard({
    Key? key,
    required this.status,
    required this.location,
    required this.time,
    this.onTap,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = CheckInStatusHelper.getStatusColor(status);
    final displayStatus = CheckInStatusHelper.getDisplayStatus(context, status);
    final statusIcon = CheckInStatusHelper.getStatusIcon(status);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    displayStatus,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.location_on_outlined,
                location,
                Colors.grey[700]!,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.access_time,
                time,
                Colors.grey[700]!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
