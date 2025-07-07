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
import 'package:shimmer/shimmer.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  static const String _tag = 'NotificationSettingsPage';

  @override
  void initState() {
    super.initState();
    // Initialize notifications when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBloc>().add(const InitializeNotifications());
    });
  }

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
          // Debug logging
          Logger.debug(_tag, 'Current state: ${state.runtimeType}');
          if (state is NotificationSettingsLoaded) {
            Logger.debug(_tag,
                'Settings loaded: checkout=${state.isCheckoutEnabled}, greeting=${state.isDailyGreetingEnabled}');
          }

          if (state is NotificationLoading) {
            return _buildShimmerLoading(context);
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
                    color: AppTheme.getErrorColor(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.error}: ${state.message}',
                    style: GoogleFonts.poppins(
                      color: AppTheme.getErrorColor(context),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<NotificationBloc>()
                          .add(const InitializeNotifications());
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationSettingsLoaded) {
            return _buildSettingsContent(context, state, l10n);
          }

          // Show shimmer loading for initial state
          return _buildShimmerLoading(context);
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
          AppTheme.getWarningColor(context),
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
            // Test buttons
            // _buildTestButton(
            //   context,
            //   title: 'Test Notifikasi Checkout',
            //   subtitle: 'Klik untuk test notifikasi checkout',
            //   icon: Icons.notifications_active,
            //   onTap: () async {
            //     try {
            //       final notificationService = di.sl<LocalNotificationService>();
            //       await notificationService.showTestCheckoutNotification(state.userName);
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           content: Text('Test notifikasi checkout berhasil!'),
            //           backgroundColor: Colors.green,
            //         ),
            //       );
            //     } catch (e) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text('Error: $e'),
            //           backgroundColor: Colors.red,
            //         ),
            //       );
            //     }
            //   },
            // ),
            // _buildTestButton(
            //   context,
            //   title: 'Test Notifikasi Sapaan',
            //   subtitle: 'Klik untuk test notifikasi sapaan pagi',
            //   icon: Icons.wb_sunny,
            //   onTap: () async {
            //     try {
            //       final notificationService = di.sl<LocalNotificationService>();
            //       await notificationService.showTestDailyGreeting(state.userName);
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           content: Text('Test notifikasi sapaan berhasil!'),
            //           backgroundColor: Colors.green,
            //         ),
            //       );
            //     } catch (e) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text('Error: $e'),
            //           backgroundColor: Colors.red,
            //         ),
            //       );
            //     }
            //   },
            // ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          context,
          l10n.appearanceSettingsTitle,
          Icons.palette,
          AppTheme.getPrimaryColor(context),
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
            // _buildLanguageSelector(context, l10n),
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
                        ? AppTheme.getPrimaryColor(context).withOpacity(0.1)
                        : AppTheme.getCardBackgroundColor(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: value
                        ? AppTheme.getPrimaryColor(context)
                        : AppTheme.getSecondaryTextColor(context),
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
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
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
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
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

  Widget _buildTestButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
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
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.getSecondaryTextColor(context).withOpacity(0.3),
      highlightColor: AppTheme.getCardBackgroundColor(context),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Notification settings section shimmer
          Container(
            decoration: BoxDecoration(
              color: AppTheme.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 150,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                // Shimmer items
                for (int i = 0; i < 4; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.getBackgroundColor(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 200,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Appearance settings section shimmer
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 150,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                // Shimmer items
                for (int i = 0; i < 2; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 200,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
