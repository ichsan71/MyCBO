import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/schedule.dart';

class ScheduleCard extends StatefulWidget {
  final Schedule schedule;
  final bool isSelected;
  final Function(bool) onSelect;
  final bool isMonthlyTab;
  final bool isJoinVisit;
  final Function(bool)? onJoinVisitChanged;
  final bool canJoinVisit;

  const ScheduleCard({
    Key? key,
    required this.schedule,
    required this.isSelected,
    required this.onSelect,
    required this.isMonthlyTab,
    this.isJoinVisit = false,
    this.onJoinVisitChanged,
    this.canJoinVisit = true,
  }) : super(key: key);

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  @override
  Widget build(BuildContext context) {
    final approvedStatus = widget.schedule.approved;
    final doctorName =
        widget.schedule.tujuanData.namaDokter ?? 'Tidak ada nama';
    final clinicName = widget.schedule.tujuanData.namaKlinik ?? '';
    final visitDate = widget.schedule.tglVisit;
    final shift = widget.schedule.shift;
    final note = widget.schedule.note ?? '';
    final hasProductData = widget.schedule.productData.isNotEmpty;

    final Color statusColor;
    final Color backgroundColor;
    final Color borderColor;
    final String statusText;

    switch (approvedStatus) {
      case 1:
        statusColor = AppTheme.getSuccessColor(context);
        backgroundColor = AppTheme.getSuccessColor(context).withOpacity(0.1);
        borderColor = AppTheme.getSuccessColor(context).withOpacity(0.3);
        statusText = 'Disetujui';
        break;
      case 2:
        statusColor = AppTheme.getErrorColor(context);
        backgroundColor = AppTheme.getErrorColor(context).withOpacity(0.1);
        borderColor = AppTheme.getErrorColor(context).withOpacity(0.3);
        statusText = 'Ditolak';
        break;
      default:
        statusColor = AppTheme.getWarningColor(context);
        backgroundColor = AppTheme.getWarningColor(context).withOpacity(0.1);
        borderColor = AppTheme.getWarningColor(context).withOpacity(0.3);
        statusText = 'Menunggu';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: approvedStatus == 0
          ? () => widget.onSelect(!widget.isSelected)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getSecondaryTextColor(context).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: widget.isJoinVisit
                ? AppTheme.getSuccessColor(context)
                : widget.isSelected
                    ? AppTheme.getPrimaryColor(context)
                    : approvedStatus == 2
                        ? AppTheme.getErrorColor(context).withOpacity(0.3)
                        : approvedStatus == 1
                            ? AppTheme.getSuccessColor(context).withOpacity(0.3)
                            : AppTheme.getBorderColor(context),
            width: widget.isJoinVisit ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: AppTheme.getPrimaryColor(context).withOpacity(0.07),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (approvedStatus == 0)
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: widget.isSelected,
                            onChanged: (value) =>
                                widget.onSelect(value ?? false),
                            activeColor: AppTheme.getPrimaryColor(context),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      if (approvedStatus == 0) const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctorName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getPrimaryTextColor(context),
                            ),
                          ),
                          if (clinicName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              clinicName,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.getSecondaryTextColor(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor, width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          approvedStatus == 0
                              ? Icons.hourglass_empty
                              : approvedStatus == 1
                                  ? Icons.check_circle
                                  : Icons.cancel,
                          size: 13,
                          color: statusColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          statusText,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.getPrimaryColor(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        visitDate,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.getPrimaryTextColor(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.getPrimaryColor(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        shift,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.getPrimaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  if (hasProductData) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.medical_services,
                          size: 16,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: widget.schedule.productData
                                .map((e) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.getPrimaryColor(context)
                                            .withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        e.namaProduct,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: AppTheme.getPrimaryTextColor(
                                              context),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.getPrimaryTextColor(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (widget.isMonthlyTab && widget.isSelected) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: widget.isJoinVisit,
                    onChanged:
                        widget.canJoinVisit ? widget.onJoinVisitChanged : null,
                    activeColor: AppTheme.getSuccessColor(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Join Visit',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: widget.isJoinVisit
                          ? AppTheme.getSuccessColor(context)
                          : widget.canJoinVisit
                              ? AppTheme.getPrimaryTextColor(context)
                              : AppTheme.getSecondaryTextColor(context)
                                  .withOpacity(0.5),
                      fontWeight: widget.isJoinVisit
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (widget.isJoinVisit) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.group,
                      size: 16,
                      color: AppTheme.getSuccessColor(context),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
