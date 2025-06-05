import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/notification_settings.dart';
import '../bloc/notification_settings_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan Notifikasi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<NotificationSettingsBloc, NotificationSettingsState>(
        builder: (context, state) {
          if (state is NotificationSettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationSettingsError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          } else if (state is NotificationSettingsLoaded) {
            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  return _buildSettingsForm(
                    context,
                    state.settings,
                    authState.user.role.toLowerCase() != 'ps',
                  );
                }
                return const Center(
                  child: Text('Silakan login terlebih dahulu'),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSettingsForm(
    BuildContext context,
    NotificationSettings settings,
    bool showApprovalAndRealization,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSwitchTile(
          context: context,
          title: 'Pengingat Check-out',
          subtitle: 'Notifikasi pengingat check-out setiap 2 jam',
          value: settings.isCheckoutReminderEnabled,
          onChanged: (value) {
            context.read<NotificationSettingsBloc>().add(
                  UpdateNotificationSettings(
                    settings: settings.copyWith(
                      isCheckoutReminderEnabled: value,
                    ),
                  ),
                );
          },
        ),
        if (settings.isCheckoutReminderEnabled) ...[
          const SizedBox(height: 8),
          _buildTimePickerTile(
            context: context,
            settings: settings,
            title: 'Waktu Mulai Pengingat',
            subtitle: 'Atur waktu mulai pengingat check-out',
            currentTime: settings.checkoutReminderStartTime,
            onTimeSelected: (time) {
              context.read<NotificationSettingsBloc>().add(
                    UpdateNotificationSettings(
                      settings: settings.copyWith(
                        checkoutReminderStartTime: time,
                      ),
                    ),
                  );
            },
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: Text(
                'Interval Pengingat',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Setiap ${settings.checkoutReminderInterval} jam sekali',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
        if (showApprovalAndRealization) ...[
          const Divider(height: 32),
          _buildSwitchTile(
            context: context,
            title: 'Notifikasi Persetujuan',
            subtitle: 'Notifikasi ketika ada persetujuan jadwal',
            value: settings.isApprovalNotificationEnabled,
            onChanged: (value) {
              context.read<NotificationSettingsBloc>().add(
                    UpdateNotificationSettings(
                      settings: settings.copyWith(
                        isApprovalNotificationEnabled: value,
                      ),
                    ),
                  );
            },
          ),
          const Divider(height: 32),
          _buildSwitchTile(
            context: context,
            title: 'Notifikasi Realisasi Visit',
            subtitle: 'Notifikasi ketika ada realisasi kunjungan',
            value: settings.isVisitRealizationEnabled,
            onChanged: (value) {
              context.read<NotificationSettingsBloc>().add(
                    UpdateNotificationSettings(
                      settings: settings.copyWith(
                        isVisitRealizationEnabled: value,
                      ),
                    ),
                  );
            },
          ),
        ],
        const SizedBox(height: 32),
        Card(
          child: ListTile(
            title: Text(
              'Test Notifikasi',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Kirim notifikasi test untuk memeriksa pengaturan',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                context.read<NotificationSettingsBloc>().add(
                      const SendTestNotification(),
                    );
              },
              child: Text(
                'Test',
                style: GoogleFonts.poppins(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTimePickerTile({
    required BuildContext context,
    required NotificationSettings settings,
    required String title,
    required String subtitle,
    required String currentTime,
    required Function(String) onTimeSelected,
  }) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: TextButton(
          onPressed: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: _parseTimeString(currentTime),
            );
            if (picked != null) {
              onTimeSelected(
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
              );
            }
          },
          child: Text(
            currentTime,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
