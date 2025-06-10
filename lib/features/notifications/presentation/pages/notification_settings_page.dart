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

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  static const String _tag = 'NotificationSettingsPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarWidget(
        title: 'Pengaturan',
        automaticallyImplyLeading: true,
        showShadow: true,
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationError) {
            Logger.error(
                _tag, 'Error in notification settings: ${state.message}');
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          Logger.debug(_tag, 'Current notification state: $state');
          Logger.debug(_tag,
              'Checkout notifications enabled: ${state.isCheckoutEnabled}');
          Logger.debug(
              _tag, 'Daily greeting enabled: ${state.isDailyGreetingEnabled}');
          Logger.debug(_tag, 'Last checkout check: ${state.lastCheckoutCheck}');
          Logger.debug(_tag, 'Last daily greeting: ${state.lastDailyGreeting}');

          return ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingTile(
                      context: context,
                      title: 'Checkout Notifications',
                      subtitle: 'Get notified when you need to checkout',
                      icon: Icons.notifications_active,
                      color: Colors.blue[600]!,
                      value: state.isCheckoutEnabled,
                      onChanged: (value) {
                        Logger.debug(_tag, 'Toggling checkout notifications');
                        context
                            .read<NotificationBloc>()
                            .add(const ToggleScheduleNotifications());
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingTile(
                      context: context,
                      title: 'Daily Greeting',
                      subtitle: 'Get a friendly greeting every morning',
                      icon: Icons.wb_sunny,
                      color: Colors.amber[700]!,
                      value: state.isDailyGreetingEnabled,
                      onChanged: (value) {
                        Logger.debug(_tag, 'Toggling daily greeting');
                        context
                            .read<NotificationBloc>()
                            .add(const ToggleApprovalNotifications());
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      context: context,
                      title: 'Last Checkout Check',
                      subtitle: state.lastCheckoutCheck.toString(),
                      icon: Icons.history,
                      color: Colors.green[600]!,
                    ),
                    const Divider(height: 1),
                    _buildInfoTile(
                      context: context,
                      title: 'Last Daily Greeting',
                      subtitle: state.lastDailyGreeting.toString(),
                      icon: Icons.access_time,
                      color: Colors.purple[600]!,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
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
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
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
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
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
