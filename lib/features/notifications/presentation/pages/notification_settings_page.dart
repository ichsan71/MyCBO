import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notification_bloc.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing notifications...'),
                ],
              ),
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<NotificationBloc>()
                            .add(InitializeNotifications());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is NotificationSettingsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notification Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Checkout Reminders'),
                            subtitle: const Text(
                              'Get notified every 1 hours for pending checkouts',
                            ),
                            value: state.settings.isCheckoutEnabled,
                            onChanged: (value) {
                              context.read<NotificationBloc>().add(
                                    ToggleCheckoutNotification(value),
                                  );
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Daily Greeting'),
                            subtitle: const Text(
                              'Receive a daily greeting at 9:00',
                            ),
                            value: state.settings.isDailyGreetingEnabled,
                            onChanged: (value) {
                              context.read<NotificationBloc>().add(
                                    ToggleDailyGreeting(value),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Test Buttons
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Test Notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<NotificationBloc>().add(
                                          TestCheckoutNotification(),
                                        );
                                  },
                                  label: const Text('Test Checkout'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<NotificationBloc>().add(
                                          TestDailyGreeting(),
                                        );
                                  },
                                  label: const Text('Test Greeting'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Debug Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Debug Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  context.read<NotificationBloc>().add(
                                        CheckNotificationStatus(),
                                      );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDebugItem(
                            'Notification Service Status',
                            state.isWorking ? 'Working' : 'Not Working',
                            state.isWorking ? Colors.green : Colors.red,
                          ),
                          const SizedBox(height: 8),
                          _buildDebugItem(
                            'Pending Checkouts',
                            '${state.pendingCheckouts.length} items',
                            Colors.blue,
                          ),
                          if (state.pendingCheckouts.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Pending Checkout Items:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ...state.pendingCheckouts.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text('• $item'),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          _buildDebugItem(
                            'User Name',
                            state.settings.userName,
                            Colors.black,
                          ),
                          const SizedBox(height: 8),
                          _buildDebugItem(
                            'Last Checkout Check',
                            _formatDateTime(state.settings.lastCheckoutCheck),
                            Colors.black,
                          ),
                          const SizedBox(height: 8),
                          _buildDebugItem(
                            'Last Daily Greeting',
                            _formatDateTime(state.settings.lastDailyGreeting),
                            Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }

  Widget _buildDebugItem(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    if (dateTime.millisecondsSinceEpoch == 0) {
      return 'Never';
    }
    return '${dateTime.toLocal()}';
  }
}
