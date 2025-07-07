import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/presentation/theme/app_theme.dart';

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
                backgroundColor: AppTheme.getCardBackgroundColor(context),
                selectedColor:
                    AppTheme.getPrimaryColor(context).withOpacity(0.1),
                checkmarkColor: AppTheme.getPrimaryColor(context),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }
}
