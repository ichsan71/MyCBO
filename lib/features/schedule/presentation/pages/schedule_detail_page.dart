import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_cbo/core/utils/logger.dart';
import 'dart:io';
import 'dart:async';
import 'package:image/image.dart' as img;
import '../../domain/entities/schedule.dart';
import '../utils/schedule_status_helper.dart';
import '../../data/models/checkin_request_model.dart';
import '../../data/models/checkout_request_model.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../widgets/checkin_form.dart';
import '../widgets/checkout_form.dart';
import '../../../../core/presentation/widgets/shimmer_schedule_detail_loading.dart';
import '../../../../core/presentation/widgets/success_message.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    _refreshSchedule();
  }

  void _refreshSchedule() {
    context.read<ScheduleBloc>().add(
          GetSchedulesEvent(userId: widget.userId),
        );
  }

  void _showMessage(BuildContext context, String message,
      {bool isError = false}) {
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.clearSnackBars();

    if (isError) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.getErrorColor(context),
        ),
      );
    } else {
      SuccessMessage.show(
        context: context,
        message: message,
        onDismissed: () {
          if (mounted) {
            _refreshSchedule();
          }
        },
      );
    }
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
      // Simpan navigator sebelum operasi asynchronous
      final navigator = Navigator.of(context);

      context.read<ScheduleBloc>().add(
            CheckInEvent(request: request),
          );

      // Tunggu sebentar untuk memastikan state sudah terupdate
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Tutup bottom sheet menggunakan navigator yang disimpan
      navigator.pop();

      // Refresh jadwal
      _refreshSchedule();
    } catch (e) {
      if (!mounted) return;
      _showMessage(context, 'Terjadi kesalahan: ${e.toString()}',
          isError: true);
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

      // Tunggu sebentar untuk memastikan state sudah terupdate
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Kembali ke halaman utama
      Navigator.popUntil(context, (route) => route.isFirst);

      // Refresh jadwal
      _refreshSchedule();
    } catch (e) {
      if (!mounted) return;
      _showMessage(context, 'Terjadi kesalahan: ${e.toString()}',
          isError: true);
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
      backgroundColor: AppTheme.getCardBackgroundColor(context),
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
                  onSubmit: (request) =>
                      _handleCheckin(builderContext, request),
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
      _showMessage(context, 'Terjadi kesalahan: ${error.toString()}',
          isError: true);
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
      backgroundColor: AppTheme.getCardBackgroundColor(context),
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
        _refreshSchedule();
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
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
            if (!mounted) return;

            if (state is CheckInSuccess) {
              // Gunakan Future.microtask untuk menghindari setState atau rebuild saat widget di-dispose
              Future.microtask(() {
                if (mounted) {
                  _showMessage(context, 'Check-in berhasil!');
                }
              });
            } else if (state is CheckOutSuccess) {
              Future.microtask(() {
                if (mounted) {
                  _showMessage(context, 'Check-out berhasil!');
                }
              });
            } else if (state is ScheduleError) {
              Future.microtask(() {
                if (mounted) {
                  _showMessage(context, state.message, isError: true);
                }
              });
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

            // Get the schedule type display value
            final scheduleTypeDisplay =
                widget.schedule.namaTipeSchedule?.isNotEmpty == true
                    ? widget.schedule.namaTipeSchedule!
                    : widget.schedule.tipeSchedule.isNotEmpty
                        ? widget.schedule.tipeSchedule
                        : 'Tidak ada tipe';

            Logger.info('ScheduleDetailPage',
                'tipeSchedule: ${widget.schedule.tipeSchedule}');
            Logger.info('ScheduleDetailPage',
                'namaTipeSchedule: ${widget.schedule.namaTipeSchedule}');
            Logger.info('ScheduleDetailPage',
                'scheduleTypeDisplay: $scheduleTypeDisplay');

            return Container(
              color: AppTheme.getBackgroundColor(context),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCard(
                      title: 'Informasi Jadwal',
                      icon: Icons.calendar_today,
                      iconColor: AppTheme.getPrimaryColor(context),
                      children: [
                        _buildDetailRow(
                          label: 'Tipe Schedule',
                          value: scheduleTypeDisplay,
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
                          value: widget.schedule.shift,
                          icon: Icons.access_time,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRowWithStatus(
                          label: 'Status',
                          value: _getDetailedStatus(widget.schedule),
                          status: widget.schedule.statusCheckin,
                          draft: widget.schedule.draft,
                          approved: widget.schedule.approved,
                          icon: Icons.info_outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Informasi Tujuan',
                      icon: Icons.person,
                      iconColor: AppTheme.getSecondaryColor(context),
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
                      iconColor: AppTheme.getTertiaryColor(context),
                      children: [
                        if (widget.schedule.namaProduct != null &&
                            widget.schedule.namaProduct!.isNotEmpty) ...[
                          Text(
                            'Produk',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.schedule.namaProduct!
                                .split(',')
                                .where((product) => product.trim().isNotEmpty)
                                .map((product) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.getPrimaryColor(context)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color:
                                              AppTheme.getPrimaryColor(context)
                                                  .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: IntrinsicWidth(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.medication,
                                              size: 16,
                                              color: AppTheme.getPrimaryColor(
                                                  context),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                product.trim(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  height: 1.2,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppTheme.getPrimaryColor(
                                                          context),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ] else
                          _buildDetailRow(
                            label: 'Nama Produk',
                            value: '-',
                            icon: Icons.medication_outlined,
                          ),
                        const SizedBox(height: 12),
                        if (widget.schedule.namaDivisi != null &&
                            widget.schedule.namaDivisi!.isNotEmpty) ...[
                          Text(
                            'Divisi',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.getSecondaryColor(context)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.getSecondaryColor(context)
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: IntrinsicWidth(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.category,
                                    size: 16,
                                    color: AppTheme.getSecondaryColor(context),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      widget.schedule.namaDivisi!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        height: 1.2,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            AppTheme.getSecondaryColor(context),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else
                          _buildDetailRow(
                            label: 'Divisi',
                            value: '-',
                            icon: Icons.category_outlined,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Catatan',
                      icon: Icons.note,
                      iconColor: AppTheme.getPrimaryColor(context),
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
                            value: ScheduleStatusHelper.isRealisasiApproved(
                                    widget.schedule.realisasiApprove)
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
                          color: AppTheme.getWarningColor(context)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.getWarningColor(context)
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.getWarningColor(context)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: AppTheme.getWarningColor(context),
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
                                      color: AppTheme.getWarningColor(context),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Jadwal ini masih menunggu persetujuan dari approver. Anda tidak dapat melakukan check-in sebelum jadwal disetujui.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppTheme.getWarningColor(context),
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
                        !ScheduleStatusHelper.isRealisasiApproved(
                            widget.schedule.realisasiApprove))
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.getWarningColor(context)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.getWarningColor(context)
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.getWarningColor(context)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.pending_outlined,
                                color: AppTheme.getWarningColor(context),
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
                                      color: AppTheme.getWarningColor(context),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Realisasi kunjungan Anda sedang dalam proses persetujuan. Silakan tunggu hingga approver menyetujui realisasi kunjungan.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppTheme.getWarningColor(context),
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
                            backgroundColor: AppTheme.getPrimaryColor(context),
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
                            backgroundColor:
                                AppTheme.getSecondaryColor(context),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getPrimaryTextColor(context),
                ),
              ),
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
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.getPrimaryColor(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getPrimaryTextColor(context),
                ),
              ),
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

  Color _getStatusColor(String status, BuildContext context) {
    switch (status) {
      case 'Ditolak':
        return AppTheme.getErrorColor(context);
      case 'Menunggu Persetujuan':
        return AppTheme.getWarningColor(context);
      case 'Disetujui - Menunggu Check-in':
        return AppTheme.getPrimaryColor(context);
      case 'Disetujui - Menunggu Check-out':
        return AppTheme.getSuccessColor(context);
      case 'Selesai':
        return AppTheme.getTertiaryColor(context);
      default:
        return AppTheme.getSecondaryTextColor(context);
    }
  }

  Widget _buildStatusBadge(Schedule schedule, BuildContext context) {
    final lowerStatus = schedule.statusCheckin.toLowerCase().trim();
    final lowerDraft = schedule.draft.toLowerCase().trim();

    String statusText;
    Color statusColor;
    IconData statusIcon;

    // Cek status ditolak
    if (lowerDraft.contains('rejected')) {
      statusText = 'Ditolak';
      statusColor = AppTheme.getErrorColor(context);
      statusIcon = Icons.cancel_outlined;
    }
    // Cek status menunggu persetujuan
    else if (schedule.approved == 0) {
      statusText = 'Menunggu Persetujuan';
      statusColor = AppTheme.getWarningColor(context);
      statusIcon = Icons.pending_outlined;
    }
    // Untuk jadwal yang sudah disetujui
    else if (schedule.approved == 1) {
      // Jika status check-in adalah detail dan realisasi belum disetujui
      if ((lowerStatus == 'detail' ||
              lowerStatus == 'check-out' ||
              lowerStatus == 'selesai') &&
          !ScheduleStatusHelper.isRealisasiApproved(
              schedule.realisasiApprove)) {
        statusText = 'Menunggu Persetujuan';
        statusColor = AppTheme.getWarningColor(context);
        statusIcon = Icons.pending_outlined;
      }
      // Jika sudah check-out atau selesai dan realisasi disetujui
      else if ((lowerStatus == 'check-out' ||
              lowerStatus == 'selesai' ||
              lowerStatus == 'detail') &&
          ScheduleStatusHelper.isRealisasiApproved(schedule.realisasiApprove)) {
        statusText = 'Selesai';
        statusColor = AppTheme.getTertiaryColor(context);
        statusIcon = Icons.check_circle_outlined;
      }
      // Status check-in
      else if (lowerStatus == 'belum checkin') {
        statusText = 'Check-in';
        statusColor = AppTheme.getPrimaryColor(context);
        statusIcon = Icons.login_outlined;
      }
      // Status check-out
      else if (lowerStatus == 'check-in' || lowerStatus == 'belum checkout') {
        statusText = 'Check-out';
        statusColor = AppTheme.getSuccessColor(context);
        statusIcon = Icons.logout_outlined;
      } else {
        statusText = schedule.statusCheckin;
        statusColor = AppTheme.getSecondaryTextColor(context);
        statusIcon = Icons.help_outline;
      }
    } else {
      statusText = schedule.statusCheckin;
      statusColor = AppTheme.getSecondaryTextColor(context);
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
        AppTheme.getWarningColor(context),
      );
    }
    // Tampilkan warning untuk jadwal yang menunggu persetujuan realisasi
    else if (schedule.approved == 1 &&
        (lowerStatus == 'detail' ||
            lowerStatus == 'check-out' ||
            lowerStatus == 'selesai') &&
        !ScheduleStatusHelper.isRealisasiApproved(schedule.realisasiApprove)) {
      return _buildWarningCard(
        'Menunggu persetujuan realisasi kunjungan.',
        'Realisasi kunjungan Anda sedang dalam proses persetujuan.',
        AppTheme.getWarningColor(context),
      );
    }
    // Tampilkan warning untuk jadwal yang ditolak
    else if (lowerDraft.contains('rejected')) {
      return _buildWarningCard(
        'Jadwal ini telah ditolak.',
        schedule.alasanReject?.isNotEmpty == true
            ? 'Alasan: ${schedule.alasanReject}'
            : 'Silakan hubungi approver Anda untuk informasi lebih lanjut.',
        AppTheme.getErrorColor(context),
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
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.getPrimaryColor(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusBadge(widget.schedule, context),
            ],
          ),
        ),
      ],
    );
  }
}
