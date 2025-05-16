import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScheduleFilterSection extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const ScheduleFilterSection({
    Key? key,
    required this.selectedFilter,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in [
            l10n.filterAll,
            l10n.filterPendingApproval,
            l10n.filterApproved,
            l10n.filterRejected,
            l10n.filterCompleted
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  filter,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: selectedFilter == filter
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                selected: selectedFilter == filter,
                onSelected: (_) => onFilterSelected(filter),
                backgroundColor: Colors.grey[100],
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }
}
