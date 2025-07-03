import 'package:flutter/material.dart';
import '../../../schedule/domain/entities/schedule.dart';
import '../../../../core/utils/logger.dart';

class ScheduleDetailPage extends StatefulWidget {
  final Schedule schedule;
  final int userId;

  const ScheduleDetailPage({
    Key? key,
    required this.schedule,
    required this.userId,
  }) : super(key: key);

  @override
  State<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends State<ScheduleDetailPage> {
  bool _isScheduleToday() {
    try {
      // Parse tanggal dengan format MM/dd/yyyy
      final dateParts = widget.schedule.tglVisit.split('/');
      if (dateParts.length != 3) return false;
      
      final scheduleDate = DateTime(
        int.parse(dateParts[2]), // year
        int.parse(dateParts[0]), // month
        int.parse(dateParts[1]), // day
      );
      
      final now = DateTime.now();
      return scheduleDate.year == now.year &&
             scheduleDate.month == now.month &&
             scheduleDate.day == now.day;
    } catch (e) {
      Logger.error('ScheduleDetailPage', 'Error parsing schedule date: $e');
      return false;
    }
  }

  DateTime? _parseScheduleDate() {
    try {
      final dateParts = widget.schedule.tglVisit.split('/');
      if (dateParts.length != 3) return null;
      
      return DateTime(
        int.parse(dateParts[2]), // year
        int.parse(dateParts[0]), // month
        int.parse(dateParts[1]), // day
      );
    } catch (e) {
      Logger.error('ScheduleDetailPage', 'Error parsing schedule date: $e');
      return null;
    }
  }

  String _formatDisplayDate(String dateStr) {
    try {
      final dateParts = dateStr.split('/');
      if (dateParts.length != 3) return dateStr;

      final month = int.parse(dateParts[0]);
      final day = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // Format tanggal ke format yang lebih user-friendly (dd/MM/yyyy)
      return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
    } catch (e) {
      Logger.error('ScheduleDetailPage', 'Error formatting display date: $e');
      return dateStr;
    }
  }

  bool _isScheduleDateValid() {
    try {
      final dateParts = widget.schedule.tglVisit.split('/');
      if (dateParts.length != 3) return false;
      
      final month = int.parse(dateParts[0]);
      final day = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);
      
      // Validasi basic untuk tanggal
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;
      if (year < 2000 || year > 2100) return false;
      
      // Coba buat DateTime object untuk validasi lebih lanjut
      return true;
    } catch (e) {
      Logger.error('ScheduleDetailPage', 'Error validating schedule date: $e');
      return false;
    }
  }

  Widget _buildScheduleActions() {
    _parseScheduleDate();
    final isToday = _isScheduleToday();
    final isValidDate = _isScheduleDateValid();

    // Jika tanggal tidak valid, tampilkan pesan error
    if (!isValidDate) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Format tanggal tidak valid: ${widget.schedule.tglVisit}',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      );
    }

    // Lanjutkan dengan logika normal jika tanggal valid
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isToday && widget.schedule.approved == 1) ...[
            ElevatedButton.icon(
              onPressed: () {
                // Handle check-in/check-out action
              },
              icon: Icon(
                widget.schedule.statusCheckin.toLowerCase() == 'belum checkin'
                    ? Icons.login
                    : Icons.logout,
              ),
              label: Text(
                widget.schedule.statusCheckin.toLowerCase() == 'belum checkin'
                    ? 'Check-in'
                    : 'Check-out',
              ),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jadwal'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Detail informasi jadwal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.schedule.namaTujuan,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tanggal: ${_formatDisplayDate(widget.schedule.tglVisit)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'Shift: ${widget.schedule.shift}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (widget.schedule.note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Catatan:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          widget.schedule.note,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Action buttons
            _buildScheduleActions(),
          ],
        ),
      ),
    );
  }
} 