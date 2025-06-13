import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:test_cbo/core/utils/logger.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:image/image.dart' as img;
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/schedule.dart';
import '../../data/models/checkin_request_model.dart';
import '../../data/models/checkout_request_model.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/checkin_form.dart';
import '../widgets/checkout_form.dart';
import '../../../../core/presentation/widgets/shimmer_schedule_detail_loading.dart';
import '../../../check_in/presentation/utils/dialog_helper.dart';

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
  DateTime? _parseDate(String dateStr) {
    try {
      // Format yang diharapkan: MM/dd/yyyy
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;

      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      Logger.error('ScheduleDetailPage', 'Error parsing date: $dateStr - $e');
      return null;
    }
  }

  bool _isScheduleToday() {
    final scheduleDate = _parseDate(widget.schedule.tglVisit);
    if (scheduleDate == null) return false;

    final now = DateTime.now();
    return scheduleDate.year == now.year &&
           scheduleDate.month == now.month &&
           scheduleDate.day == now.day;
  }

  String _formatDisplayDate(String dateStr) {
    final date = _parseDate(dateStr);
    if (date == null) return dateStr;

    // Format ke dd/MM/yyyy untuk tampilan
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    // Refresh schedule data when page is opened
    _refreshSchedule();
  }

  void _refreshSchedule() {
    context.read<ScheduleBloc>().add(
          GetSchedulesEvent(userId: widget.userId),
        );
  }

  // Loading dialog widget
  Widget _buildLoadingDialog(String message) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(message),
          ],
        ),
      ),
    );
  }

  Future<String?> _compressImage(String imagePath) async {
    try {
      // Baca file gambar
      final bytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return null;
      }

      // Resize gambar
      final resizedImage = img.copyResize(
        image,
        width: 1024, // Tentukan lebar maksimum
      );

      // Kompres dan simpan gambar
      final compressedBytes = img.encodeJpg(resizedImage, quality: 70);

      // Tentukan lokasi file output
      final directory = Directory(imagePath).parent;
      final outputPath =
          '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Simpan file
      final compressedFile = File(outputPath);
      await compressedFile.writeAsBytes(compressedBytes);

      // Log ukuran file
      final originalSize = await File(imagePath).length();
      final compressedSize = await compressedFile.length();

      Logger.info('ScheduleDetailPage',
          'Ukuran file asli: ${originalSize ~/ 1024} KB, ukuran setelah kompresi: ${compressedSize ~/ 1024} KB');

      return outputPath;
    } catch (e) {
      Logger.error(
          'ScheduleDetailPage', 'Error saat kompresi gambar: ${e.toString()}');
      return null;
    }
  }

  Future<void> _handleCheckin(
      BuildContext context, CheckinRequestModel request) async {
    if (!mounted) return;

    try {
      context.read<ScheduleBloc>().add(
            CheckInEvent(request: request),
          );

      // Store context for later use
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Check-in berhasil'),
          backgroundColor: Colors.green,
        ),
      );

      navigator.pop(); // Close bottom sheet
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleCheckout(
      BuildContext context, CheckoutRequestModel request) async {
    if (!mounted) return;

    try {
      context.read<ScheduleBloc>().add(
            CheckOutEvent(
              request: request,
              userId: widget.userId,
            ),
          );

      // Store context for later use
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Check-out berhasil'),
          backgroundColor: Colors.green,
        ),
      );

      // Close bottom sheet and navigate to schedule list
      navigator.popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _hasUncheckedOutSchedules(List<Schedule> schedules) {
    return schedules.any((s) =>
        s.id != widget.schedule.id && // Don't check current schedule
        (s.statusCheckin.toLowerCase().trim() == 'check-in' ||
            s.statusCheckin.toLowerCase().trim() == 'belum checkout'));
  }

  void _showCheckinForm(BuildContext context) {
    if (!mounted) return;

    final BuildContext currentContext = context;
    final scheduleBloc = currentContext.read<ScheduleBloc>();

    showModalBottomSheet(
      context: currentContext,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: BlocProvider<ScheduleBloc>.value(
          value: scheduleBloc,
          child: Builder(
            builder: (builderContext) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: CheckinForm(
                  scheduleId: widget.schedule.id,
                  userId: widget.userId,
                  onSubmit: (request) {
                    _handleCheckin(builderContext, request);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      Logger.info('ScheduleDetailPage', 'Check-in form closed');
    }).catchError((error) {
      if (!mounted) return;
      Logger.error('ScheduleDetailPage', 'Error on check-in form: $error');
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _showCheckoutForm(BuildContext context) {
    if (!mounted) return;

    final BuildContext currentContext = context;
    final scheduleBloc = currentContext.read<ScheduleBloc>();

    showModalBottomSheet(
      context: currentContext,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => WillPopScope(
        onWillPop: () async {
          // Show confirmation dialog before closing
          final shouldClose = await showDialog<bool>(
            context: bottomSheetContext,
            builder: (context) => AlertDialog(
              title: const Text('Konfirmasi'),
              content:
                  const Text('Apakah Anda yakin ingin membatalkan check-out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Tidak'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Ya'),
                ),
              ],
            ),
          );
          return shouldClose ?? false;
        },
        child: SafeArea(
          child: BlocProvider<ScheduleBloc>.value(
            value: scheduleBloc,
            child: Builder(
              builder: (builderContext) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: CheckoutForm(
                    schedule: widget.schedule,
                    onSubmit: (request) {
                      _handleCheckout(builderContext, request);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Refresh schedule list before popping
        _refreshSchedule();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(
              'Detail Jadwal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Refresh schedule list before popping
                _refreshSchedule();
                Navigator.pop(context);
              },
            ),
            actions: [
              if (widget.schedule.draft
                  .toLowerCase()
                  .trim()
                  .contains('rejected'))
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      '/edit_schedule',
                      arguments: widget.schedule.id,
                    );
                    // Refresh schedule after editing
                    _refreshSchedule();
                  },
                ),
            ],
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: BlocConsumer<ScheduleBloc, ScheduleState>(
          listener: (context, state) {
            if (state is CheckInSuccess || state is CheckOutSuccess) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state is CheckInSuccess
                        ? 'Check-in berhasil!'
                        : 'Check-out berhasil!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              // Pop back to schedule list
              Navigator.pop(context);
            } else if (state is ScheduleError) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ScheduleLoading) {
              return const ShimmerScheduleDetailLoading();
            }

            final theme = Theme.of(context);
            final lowerDraft = widget.schedule.draft.toLowerCase().trim();
            final status = widget.schedule.statusCheckin.toLowerCase().trim();
            final isToday = _isScheduleToday();

            return Container(
              color: theme.colorScheme.background,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCard(
                      title: 'Informasi Jadwal',
                      icon: Icons.calendar_today,
                      iconColor: theme.colorScheme.primary,
                      children: [
                        _buildDetailRow(
                          label: 'Tipe Schedule',
                          value: widget.schedule.namaTipeSchedule ??
                              widget.schedule.tipeSchedule,
                          icon: Icons.label_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          label: 'Tanggal Visit',
                          value: _formatDisplayDate(widget.schedule.tglVisit),
                          icon: Icons.event,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          label: 'Shift',
                          value: widget.schedule.shift ?? '',
                          icon: Icons.access_time,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRowWithStatus(
                          label: 'Status',
                          value: _getDetailedStatus(widget.schedule),
                          status: widget.schedule.statusCheckin,
                          draft: widget.schedule.draft ?? '',
                          approved: widget.schedule.approved,
                          icon: Icons.info_outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Informasi Tujuan',
                      icon: Icons.person,
                      iconColor: theme.colorScheme.secondary,
                      children: [
                        _buildDetailRow(
                          label: 'Tujuan',
                          value: widget.schedule.tujuan,
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          label: 'Nama Tujuan',
                          value: widget.schedule.namaTujuan,
                          icon: Icons.account_circle_outlined,
                        ),
                        if (widget.schedule.namaSpesialis?.isNotEmpty ==
                            true) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            label: 'Spesialis',
                            value: widget.schedule.namaSpesialis ?? '-',
                            icon: Icons.local_hospital_outlined,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Informasi Produk',
                      icon: Icons.shopping_bag,
                      iconColor: theme.colorScheme.tertiary,
                      children: [
                        _buildDetailRow(
                          label: 'Nama Produk',
                          value: widget.schedule.namaProduct ?? '-',
                          icon: Icons.medication_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          label: 'Divisi',
                          value: widget.schedule.namaDivisi ?? '-',
                          icon: Icons.category_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Catatan',
                      icon: Icons.note,
                      iconColor: theme.colorScheme.primary,
                      children: [
                        _buildDetailRow(
                          label: 'Catatan',
                          value: widget.schedule.note?.isNotEmpty == true
                              ? widget.schedule.note ?? ''
                              : '',
                          icon: Icons.comment_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRowWithStatus(
                          label: 'Status Jadwal',
                          value: _getDetailedStatus(widget.schedule),
                          status: widget.schedule.statusCheckin,
                          draft: widget.schedule.draft ?? '',
                          approved: widget.schedule.approved,
                          icon: Icons.verified_outlined,
                        ),
                        if (widget.schedule.namaApprover != null &&
                            widget.schedule.namaApprover!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            label: 'Approver Jadwal',
                            value: widget.schedule.namaApprover!,
                            icon: Icons.person_outlined,
                          ),
                        ],
                        if (widget.schedule.approved == 1) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            label: 'Approver Realisasi',
                            value: widget.schedule.realisasiApprove != null &&
                                    widget.schedule.realisasiApprove! > 0
                                ? widget.schedule.namaApprover ??
                                    'Tidak diketahui'
                                : 'Belum disetujui',
                            icon: Icons.approval_outlined,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (widget.schedule.approved == 0 &&
                        !widget.schedule.draft
                            .toLowerCase()
                            .trim()
                            .contains('rejected'))
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange.shade800,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jadwal Belum Disetujui',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Jadwal ini masih menunggu persetujuan dari approver. Anda tidak dapat melakukan check-in sebelum jadwal disetujui.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Tambahkan warning untuk realisasi yang belum disetujui
                    if (widget.schedule.approved == 1 &&
                        (widget.schedule.statusCheckin.toLowerCase().trim() ==
                                'detail' ||
                            widget.schedule.statusCheckin
                                    .toLowerCase()
                                    .trim() ==
                                'check-out' ||
                            widget.schedule.statusCheckin
                                    .toLowerCase()
                                    .trim() ==
                                'selesai') &&
                        (widget.schedule.realisasiApprove == null ||
                            widget.schedule.realisasiApprove == 0))
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.pending_outlined,
                                color: Colors.orange.shade800,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Menunggu Persetujuan Realisasi',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Realisasi kunjungan Anda sedang dalam proses persetujuan. Silakan tunggu hingga approver menyetujui realisasi kunjungan.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (status == 'belum checkin' &&
                        widget.schedule.approved == 1 &&
                        !lowerDraft.contains('rejected'))
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          onPressed: isToday
                              ? () {
                                  Logger.info('ScheduleDetailPage',
                                      'Status saat ini: ${widget.schedule.statusCheckin}');
                                  Logger.info('ScheduleDetailPage',
                                      'Tombol check-in ditekan');
                                  _showCheckinForm(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: theme.colorScheme.primary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.login,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isToday
                                    ? 'Check-in'
                                    : 'Check-in hanya untuk hari ini',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (status == 'check-in' || status == 'belum checkout')
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          onPressed: isToday
                              ? () {
                                  Logger.info('ScheduleDetailPage',
                                      'Status saat ini: ${widget.schedule.statusCheckin}');
                                  Logger.info('ScheduleDetailPage',
                                      'Tombol check-out ditekan');
                                  _showCheckoutForm(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: theme.colorScheme.secondary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isToday
                                    ? 'Check-out'
                                    : 'Check-out hanya untuk hari ini',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle(fontWeight: FontWeight.bold);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.surface.withValues(alpha: 127),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(title, style: titleStyle),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final labelStyle = textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ) ??
        TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        );

    final valueStyle = textTheme.titleMedium ?? const TextStyle();

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: labelStyle),
              Text(value, style: valueStyle),
            ],
          ),
        ),
      ],
    );
  }

  String _getDetailedStatus(Schedule schedule) {
    final lowerDraft = schedule.draft.toLowerCase().trim();
    final status = schedule.statusCheckin.toLowerCase().trim();

    if (lowerDraft.contains('rejected')) {
      return 'Ditolak';
    }

    if (schedule.approved == 0) {
      return 'Menunggu Persetujuan';
    }

    // Schedule is approved (schedule.approved == 1)
    switch (status) {
      case 'belum checkin':
        return 'Disetujui - Menunggu Check-in';
      case 'check-in':
      case 'belum checkout':
        return 'Disetujui - Menunggu Check-out';
      case 'check-out':
      case 'selesai':
        return 'Selesai';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Ditolak':
        return Colors.red.shade700;
      case 'Menunggu Persetujuan':
        return Colors.orange.shade700;
      case 'Disetujui - Menunggu Check-in':
        return Colors.blue.shade700;
      case 'Disetujui - Menunggu Check-out':
        return Colors.green.shade700;
      case 'Selesai':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildStatusBadge(Schedule schedule) {
    final lowerStatus = schedule.statusCheckin.toLowerCase().trim();
    final lowerDraft = schedule.draft.toLowerCase().trim();

    String statusText;
    Color statusColor;
    IconData statusIcon;

    // Cek status ditolak
    if (lowerDraft.contains('rejected')) {
      statusText = 'Ditolak';
      statusColor = Colors.red.shade700;
      statusIcon = Icons.cancel_outlined;
    }
    // Cek status menunggu persetujuan
    else if (schedule.approved == 0) {
      statusText = 'Menunggu Persetujuan';
      statusColor = Colors.orange.shade700;
      statusIcon = Icons.pending_outlined;
    }
    // Untuk jadwal yang sudah disetujui
    else if (schedule.approved == 1) {
      // Jika status check-in adalah detail dan realisasi belum disetujui
      if ((lowerStatus == 'detail' ||
              lowerStatus == 'check-out' ||
              lowerStatus == 'selesai') &&
          (schedule.realisasiApprove == null ||
              schedule.realisasiApprove == 0)) {
        statusText = 'Menunggu Persetujuan';
        statusColor = Colors.orange.shade700;
        statusIcon = Icons.pending_outlined;
      }
      // Jika sudah check-out atau selesai dan realisasi disetujui
      else if ((lowerStatus == 'check-out' ||
              lowerStatus == 'selesai' ||
              lowerStatus == 'detail') &&
          schedule.realisasiApprove == 1) {
        statusText = 'Selesai';
        statusColor = Colors.teal.shade700;
        statusIcon = Icons.check_circle_outlined;
      }
      // Status check-in
      else if (lowerStatus == 'belum checkin') {
        statusText = 'Check-in';
        statusColor = Colors.blue.shade700;
        statusIcon = Icons.login_outlined;
      }
      // Status check-out
      else if (lowerStatus == 'check-in' || lowerStatus == 'belum checkout') {
        statusText = 'Check-out';
        statusColor = Colors.green.shade700;
        statusIcon = Icons.logout_outlined;
      } else {
        statusText = schedule.statusCheckin;
        statusColor = Colors.grey.shade700;
        statusIcon = Icons.help_outline;
      }
    } else {
      statusText = schedule.statusCheckin;
      statusColor = Colors.grey.shade700;
      statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(Schedule schedule) {
    final lowerStatus = schedule.statusCheckin.toLowerCase().trim();
    final lowerDraft = schedule.draft.toLowerCase().trim();

    // Tampilkan warning untuk jadwal yang menunggu persetujuan
    if (schedule.approved == 0 && !lowerDraft.contains('rejected')) {
      return _buildWarningCard(
        'Jadwal ini sedang menunggu persetujuan.',
        'Anda tidak dapat melakukan check-in sebelum jadwal disetujui.',
        Colors.orange.shade700,
      );
    }
    // Tampilkan warning untuk jadwal yang menunggu persetujuan realisasi
    else if (schedule.approved == 1 &&
        (lowerStatus == 'detail' ||
            lowerStatus == 'check-out' ||
            lowerStatus == 'selesai') &&
        (schedule.realisasiApprove == null || schedule.realisasiApprove == 0)) {
      return _buildWarningCard(
        'Menunggu persetujuan realisasi kunjungan.',
        'Realisasi kunjungan Anda sedang dalam proses persetujuan.',
        Colors.orange.shade700,
      );
    }
    // Tampilkan warning untuk jadwal yang ditolak
    else if (lowerDraft.contains('rejected')) {
      return _buildWarningCard(
        'Jadwal ini telah ditolak.',
        schedule.alasanReject?.isNotEmpty == true
            ? 'Alasan: ${schedule.alasanReject}'
            : 'Silakan hubungi approver Anda untuk informasi lebih lanjut.',
        Colors.red.shade700,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildWarningCard(String title, String message, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithStatus({
    required String label,
    required String value,
    required String status,
    required String draft,
    required int approved,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final labelStyle = textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ) ??
        TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        );

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: labelStyle),
              const SizedBox(height: 4),
              _buildStatusBadge(widget.schedule),
            ],
          ),
        ),
      ],
    );
  }
}
