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
import '../../../../core/presentation/widgets/shimmer_form_loading.dart';

class ScheduleDetailPage extends StatelessWidget {
  final Schedule schedule;
  final int userId;

  const ScheduleDetailPage({
    Key? key,
    required this.schedule,
    required this.userId,
  }) : super(key: key);

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
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 100,
                  child: ShimmerFormLoading(
                    isDetailed: false,
                    hasImage: false,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Sedang mengirim data check-in...',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Dapatkan token dari AuthBloc
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('User tidak terautentikasi');
      }

      // Kompres gambar terlebih dahulu
      final File originalFile = File(request.foto);
      if (!await originalFile.exists()) {
        throw Exception('File foto tidak ditemukan');
      }

      // Log ukuran file asli
      final originalSize = await originalFile.length();
      Logger.info(
          'ScheduleDetailPage', 'Ukuran file asli: ${originalSize ~/ 1024} KB');

      // Kompres gambar dengan metode baru
      final compressedFilePath = await _compressImage(originalFile.path);
      File compressedFile;

      if (compressedFilePath != null) {
        compressedFile = File(compressedFilePath);
        final compressedSize = await compressedFile.length();
        Logger.info('ScheduleDetailPage',
            'Ukuran file setelah kompresi: ${compressedSize ~/ 1024} KB');
      } else {
        Logger.warning('ScheduleDetailPage',
            'Kompresi gambar gagal, menggunakan file asli');
        compressedFile = originalFile;
      }

      // Buat MultipartRequest
      final multipartRequest = http.MultipartRequest(
        'POST',
        Uri.parse('https://dev-bco.businesscorporateofficer.com/api/checkin'),
      );

      // Tambahkan headers
      multipartRequest.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authState.user.token}',
      });

      // Tambahkan fields
      multipartRequest.fields['id_schedule'] = request.idSchedule.toString();
      multipartRequest.fields['lokasi'] = request.lokasi;
      multipartRequest.fields['note'] = request.note;

      // Tambahkan file foto yang telah dikompresi
      final imageStream = http.ByteStream(compressedFile.openRead());
      final length = await compressedFile.length();

      final multipartFile = http.MultipartFile(
        'foto',
        imageStream,
        length,
        filename: 'checkin_photo.jpg',
      );

      multipartRequest.files.add(multipartFile);

      // Kirim request dengan timeout
      Logger.info('ScheduleDetailPage', 'Mengirim request check-in...');

      // Set timeout 30 detik
      final streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout setelah 30 detik');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      Logger.info(
          'ScheduleDetailPage', 'Response status: ${response.statusCode}');
      Logger.info('ScheduleDetailPage', 'Response body: ${response.body}');

      // Hapus file kompresi temporer
      if (compressedFilePath != null &&
          compressedFile.path != originalFile.path) {
        try {
          await compressedFile.delete();
          Logger.info('ScheduleDetailPage', 'File kompresi temporer dihapus');
        } catch (e) {
          Logger.warning('ScheduleDetailPage',
              'Gagal menghapus file kompresi temporer: $e');
        }
      }

      // Tutup dialog loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        if (context.mounted) {
          // Update status jadwal melalui bloc
          final updateEvent = UpdateScheduleStatusEvent(
            scheduleId: schedule.id,
            newStatus: 'Check-in',
            userId: userId,
          );
          context.read<ScheduleBloc>().add(updateEvent);

          // Tampilkan pesan sukses
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check-in berhasil!'),
              backgroundColor: Colors.green,
            ),
          );

          // Tutup bottom sheet
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          // Coba parse error message dari response
          String errorMessage = 'Gagal melakukan check-in';
          try {
            final responseJson = json.decode(response.body);
            if (responseJson['message'] != null) {
              errorMessage = responseJson['message'];
            }
          } catch (e) {
            errorMessage = 'Status: ${response.statusCode}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on TimeoutException catch (e) {
      Logger.error('ScheduleDetailPage', 'Timeout during check-in: $e');

      // Tutup dialog loading
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Request timeout. Koneksi internet terlalu lambat atau server tidak merespon.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Logger.error('ScheduleDetailPage', 'Error during check-in: $e');

      // Tutup dialog loading
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCheckout(
      BuildContext context, CheckoutRequestModel request) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 100,
                  child: ShimmerFormLoading(
                    isDetailed: false,
                    hasImage: false,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Sedang mengirim data check-out...',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Dapatkan token dari AuthBloc
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('User tidak terautentikasi');
      }

      // Kompres gambar terlebih dahulu
      final File originalFile = File(request.foto);
      if (!await originalFile.exists()) {
        throw Exception('File foto tidak ditemukan');
      }

      // Log ukuran file asli
      final originalSize = await originalFile.length();
      Logger.info(
          'ScheduleDetailPage', 'Ukuran file asli: ${originalSize ~/ 1024} KB');

      // Kompres gambar dengan metode baru
      final compressedFilePath = await _compressImage(originalFile.path);
      File compressedFile;

      if (compressedFilePath != null) {
        compressedFile = File(compressedFilePath);
        final compressedSize = await compressedFile.length();
        Logger.info('ScheduleDetailPage',
            'Ukuran file setelah kompresi: ${compressedSize ~/ 1024} KB');
      } else {
        Logger.warning('ScheduleDetailPage',
            'Kompresi gambar gagal, menggunakan file asli');
        compressedFile = originalFile;
      }

      // Buat MultipartRequest
      final multipartRequest = http.MultipartRequest(
        'POST',
        Uri.parse('https://dev-bco.businesscorporateofficer.com/api/checkout'),
      );

      // Tambahkan headers
      multipartRequest.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authState.user.token}',
      });

      // Tambahkan fields
      multipartRequest.fields['id_schedule'] = request.idSchedule.toString();
      multipartRequest.fields['status'] = request.status;
      multipartRequest.fields['note'] = request.note;
      multipartRequest.fields['tgl_schedule_lanjutan'] =
          request.tglScheduleLanjutan;

      // Tambahkan file foto yang telah dikompresi
      final imageStream = http.ByteStream(compressedFile.openRead());
      final length = await compressedFile.length();

      final multipartFile = http.MultipartFile(
        'foto',
        imageStream,
        length,
        filename: 'checkout_photo.jpg',
      );

      multipartRequest.files.add(multipartFile);

      // Kirim request dengan timeout
      Logger.info('ScheduleDetailPage', 'Mengirim request check-out...');

      // Set timeout 30 detik
      final streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout setelah 30 detik');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      Logger.info(
          'ScheduleDetailPage', 'Response status: ${response.statusCode}');
      Logger.info('ScheduleDetailPage', 'Response body: ${response.body}');

      // Hapus file kompresi temporer
      if (compressedFilePath != null &&
          compressedFile.path != originalFile.path) {
        try {
          await compressedFile.delete();
          Logger.info('ScheduleDetailPage', 'File kompresi temporer dihapus');
        } catch (e) {
          Logger.warning('ScheduleDetailPage',
              'Gagal menghapus file kompresi temporer: $e');
        }
      }

      // Tutup dialog loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        if (context.mounted) {
          // Update status jadwal melalui bloc
          final updateEvent = UpdateScheduleStatusEvent(
            scheduleId: schedule.id,
            newStatus: request.status,
            userId: userId,
          );
          context.read<ScheduleBloc>().add(updateEvent);

          // Tampilkan pesan sukses
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check-out berhasil!'),
              backgroundColor: Colors.green,
            ),
          );

          // Tutup bottom sheet
          Navigator.pop(context);

          // Kembali ke halaman sebelumnya setelah delay singkat
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              Navigator.pop(context); // Kembali ke halaman jadwal
            }
          });
        }
      } else {
        if (context.mounted) {
          // Coba parse error message dari response
          String errorMessage = 'Gagal melakukan check-out';
          try {
            final responseJson = json.decode(response.body);
            if (responseJson['message'] != null) {
              errorMessage = responseJson['message'];
            }
          } catch (e) {
            errorMessage = 'Status: ${response.statusCode}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on TimeoutException catch (e) {
      Logger.error('ScheduleDetailPage', 'Timeout during check-out: $e');

      // Tutup dialog loading
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Request timeout. Koneksi internet terlalu lambat atau server tidak merespon.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Logger.error('ScheduleDetailPage', 'Error during check-out: $e');

      // Tutup dialog loading
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCheckinForm(BuildContext context) {
    final scheduleBloc = context.read<ScheduleBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) => BlocProvider<ScheduleBloc>.value(
        value: scheduleBloc,
        child: Builder(
          builder: (builderContext) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: CheckinForm(
                scheduleId: schedule.id,
                userId: userId,
                onSubmit: (request) => _handleCheckin(builderContext, request),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCheckoutForm(BuildContext context) {
    final scheduleBloc = context.read<ScheduleBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) => BlocProvider<ScheduleBloc>.value(
        value: scheduleBloc,
        child: Builder(
          builder: (builderContext) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: CheckoutForm(
                scheduleId: schedule.id,
                userId: userId,
                onSubmit: (request) => _handleCheckout(builderContext, request),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tambahkan logging untuk status dan draft
    Logger.info('ScheduleDetailPage', '=== DEBUG INFO ===');
    Logger.info(
        'ScheduleDetailPage', 'Status Check-in: ${schedule.statusCheckin}');
    Logger.info('ScheduleDetailPage',
        'Status Check-in (lowercase): ${schedule.statusCheckin.toLowerCase()}');
    Logger.info('ScheduleDetailPage', 'Draft: ${schedule.draft}');
    Logger.info('ScheduleDetailPage',
        'Draft (lowercase): ${schedule.draft.toLowerCase()}');
    Logger.info('ScheduleDetailPage',
        'Draft (lowercase & trim): ${schedule.draft.toLowerCase().trim()}');
    Logger.info('ScheduleDetailPage', 'Approved: ${schedule.approved}');
    Logger.info('ScheduleDetailPage', '================');

    final theme = Theme.of(context);
    final lowerDraft = schedule.draft.toLowerCase().trim();
    final lowerStatus = schedule.statusCheckin.toLowerCase().trim();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ScheduleBloc>(
          create: (_) => sl<ScheduleBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Detail Jadwal'),
            centerTitle: true,
            elevation: 0,
          ),
          body: BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, state) {
            if (state is ScheduleLoading) {
              return const ShimmerScheduleDetailLoading();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informasi Utama
                  _buildCard(
                    title: 'Informasi Jadwal',
                    icon: Icons.calendar_today,
                    iconColor: theme.colorScheme.primary,
                    children: [
                      _buildDetailRow(
                        label: 'Tipe Schedule',
                        value: schedule.tipeSchedule,
                        icon: Icons.label_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        label: 'Tanggal Visit',
                        value: schedule.tglVisit,
                        icon: Icons.event,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        label: 'Shift',
                        value: schedule.shift,
                        icon: Icons.access_time,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRowWithStatus(
                        label: 'Status',
                        value: schedule.statusCheckin,
                        status: schedule.statusCheckin,
                        draft: schedule.draft,
                        approved: schedule.approved,
                        icon: Icons.info_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Informasi Tujuan
                  _buildCard(
                    title: 'Informasi Tujuan',
                    icon: Icons.person,
                    iconColor: theme.colorScheme.secondary,
                    children: [
                      _buildDetailRow(
                        label: 'Tujuan',
                        value: schedule.tujuan,
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        label: 'Nama Tujuan',
                        value: schedule.namaTujuan,
                        icon: Icons.account_circle_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Informasi Produk
                  _buildCard(
                    title: 'Informasi Produk',
                    icon: Icons.shopping_bag,
                    iconColor: theme.colorScheme.tertiary,
                    children: [
                      _buildDetailRow(
                        label: 'Nama Produk',
                        value: schedule.namaProduct,
                        icon: Icons.medication_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        label: 'Divisi',
                        value: schedule.namaDivisi,
                        icon: Icons.category_outlined,
                      ),
                      if (schedule.namaSpesialis.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          label: 'Spesialis',
                          value: schedule.namaSpesialis,
                          icon: Icons.local_hospital_outlined,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Informasi Tambahan
                  _buildCard(
                    title: 'Catatan',
                    icon: Icons.note,
                    iconColor: theme.colorScheme.primary,
                    children: [
                      _buildDetailRow(
                        label: 'Catatan',
                        value: schedule.note.isNotEmpty
                            ? schedule.note
                            : 'Tidak ada catatan',
                        icon: Icons.comment_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRowWithStatus(
                        label: 'Status Approval',
                        value: schedule.approved == 1
                            ? 'Disetujui'
                            : lowerDraft.contains('rejected')
                                ? 'Ditolak'
                                : 'Belum Disetujui',
                        status: schedule.approved == 1
                            ? 'approved'
                            : lowerDraft.contains('rejected')
                                ? 'rejected'
                                : 'pending',
                        draft: schedule.draft,
                        approved: schedule.approved,
                        icon: Icons.verified_outlined,
                      ),
                      if (schedule.namaApprover != null &&
                          schedule.namaApprover!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          label: 'Nama Approver',
                          value: schedule.namaApprover!,
                          icon: Icons.person_outlined,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }),
          bottomNavigationBar: () {
            Logger.info(
                'ScheduleDetailPage', '=== BOTTOM NAVIGATION STATUS ===');
            Logger.info(
                'ScheduleDetailPage', 'Draft Raw Value: "${schedule.draft}"');
            Logger.info(
                'ScheduleDetailPage', 'Draft Length: ${schedule.draft.length}');
            Logger.info('ScheduleDetailPage', 'Draft Characters:');
            for (var i = 0; i < schedule.draft.length; i++) {
              Logger.info('ScheduleDetailPage',
                  'Char at $i: "${schedule.draft[i]}" (${schedule.draft.codeUnitAt(i)})');
            }
            Logger.info('ScheduleDetailPage', 'Lower Draft: "$lowerDraft"');
            Logger.info('ScheduleDetailPage',
                'Lower Draft Length: ${lowerDraft.length}');
            Logger.info('ScheduleDetailPage',
                'Status Raw: "${schedule.statusCheckin}"');
            Logger.info('ScheduleDetailPage', 'Lower Status: "$lowerStatus"');
            Logger.info('ScheduleDetailPage',
                'Is Draft Exactly "rejected"?: ${lowerDraft == "rejected"}');
            Logger.info('ScheduleDetailPage',
                'Draft Contains "rejected"?: ${lowerDraft.contains("rejected")}');
            Logger.info(
                'ScheduleDetailPage', '================================');

            // Tampilkan bottom bar dengan konten yang sesuai
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lowerDraft.contains('rejected'))
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: Colors.red.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Jadwal ditolak oleh supervisor',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (lowerStatus == 'belum checkin' &&
                      schedule.approved == 1)
                    ElevatedButton(
                      onPressed: () => _showCheckinForm(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Check-in',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (lowerStatus == 'belum checkin' &&
                      schedule.approved != 1)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Jadwal belum disetujui oleh approver',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (lowerStatus == 'check-in' ||
                      lowerStatus == 'belum checkout')
                    ElevatedButton(
                      onPressed: () {
                        Logger.info('ScheduleDetailPage',
                            'Status saat ini: ${schedule.statusCheckin}');
                        Logger.info(
                            'ScheduleDetailPage', 'Tombol check-out ditekan');
                        _showCheckoutForm(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.secondary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Check-out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }(),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
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
    // Tentukan warna berdasarkan status
    Color statusColor;
    if (status.toLowerCase().contains('approved') ||
        status.toLowerCase().contains('disetujui') ||
        (status.toLowerCase() == 'belum checkin' && approved == 1)) {
      statusColor = Colors.green;
    } else if (status.toLowerCase().contains('reject') ||
        status.toLowerCase().contains('ditolak') ||
        draft.toLowerCase().trim().contains('rejected')) {
      statusColor = Colors.red;
    } else if (status.toLowerCase().contains('check-in') ||
        status.toLowerCase().contains('checkin')) {
      statusColor = Colors.blue;
    } else if (status.toLowerCase().contains('selesai')) {
      statusColor = Colors.purple;
    } else {
      statusColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
