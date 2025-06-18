import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:test_cbo/core/presentation/theme/theme_provider.dart';
import 'package:test_cbo/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:test_cbo/features/notifications/presentation/bloc/notification_event.dart';
import 'package:test_cbo/features/notifications/presentation/bloc/notification_state.dart';
import 'package:test_cbo/core/presentation/widgets/app_bar_widget.dart';
import 'package:test_cbo/core/utils/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  static const String _tag = 'NotificationSettingsPage';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarWidget(
        title: l10n.settingsTitle,
        automaticallyImplyLeading: true,
        showShadow: true,
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            Logger.error(
                _tag, 'Error in notification settings: ${state.message}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.error}: ${state.message}',
                    style: GoogleFonts.poppins(
                      color: Colors.red[700],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is NotificationSettingsLoaded) {
            return _buildSettingsContent(context, state, l10n);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    NotificationSettingsLoaded state,
    AppLocalizations l10n,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSettingsSection(
          context,
          l10n.notificationSettingsTitle,
          Icons.notifications_active,
          Colors.orange,
          [
            _buildAnimatedSwitchTile(
              context,
              title: l10n.checkoutNotifications,
              subtitle: l10n.checkoutNotificationsDesc,
              value: state.isCheckoutEnabled,
              icon: Icons.logout,
              onChanged: (value) {
                context.read<NotificationBloc>().add(
                      ToggleCheckoutNotification(enabled: value),
                    );
              },
            ),
            _buildAnimatedSwitchTile(
              context,
              title: l10n.dailyGreeting,
              subtitle: l10n.dailyGreetingDesc,
              value: state.isDailyGreetingEnabled,
              icon: Icons.wb_sunny,
              onChanged: (value) {
                context.read<NotificationBloc>().add(
                      ToggleDailyGreetingNotification(enabled: value),
                    );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          context,
          l10n.appearanceSettingsTitle,
          Icons.palette,
          Colors.purple,
          [
            SwitchListTile(
              title: Text(
                l10n.darkMode,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
              secondary: Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Theme.of(context).primaryColor,
              ),
            ),
            _buildLanguageSelector(context, l10n),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAnimatedSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: value
                        ? Theme.of(context)
                            .primaryColor
                            .withOpacity(0.1)
                        : Colors.grey.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: value ? Theme.of(context).primaryColor : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.withAlpha(38),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Implement language selection
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .primaryColor
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.language,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.language,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      Text(
                        l10n.languageDesc,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.withAlpha(13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
