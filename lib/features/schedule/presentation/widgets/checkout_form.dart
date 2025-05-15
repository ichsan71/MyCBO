import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:image/image.dart' as img;
import '../../data/models/checkout_request_model.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_form_loading.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_button_loading.dart';

class CheckoutForm extends StatefulWidget {
  final int scheduleId;
  final int userId;
  final Function(CheckoutRequestModel) onSubmit;

  const CheckoutForm({
    Key? key,
    required this.scheduleId,
    required this.userId,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<CheckoutForm> {
  final _noteController = TextEditingController();
  XFile? _imageFile;
  String? _compressedImagePath;
  String? _imageTimestamp;
  bool _isLoading = false;
  DateTime? _selectedDate;
  final _statusOptions = ['Selesai', 'Ditolak'];
  String _selectedStatus = 'Selesai';

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
        width: 800, // Tentukan lebar maksimum
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

      developer.log(
        'Ukuran file asli: ${originalSize ~/ 1024} KB, ukuran setelah kompresi: ${compressedSize ~/ 1024} KB',
        name: 'CheckoutForm',
      );

      return outputPath;
    } catch (e) {
      developer.log(
        'Error saat kompresi gambar: ${e.toString()}',
        name: 'CheckoutForm',
        error: e,
      );
      return null;
    }
  }

  Future<void> _takePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
      );

      if (image != null) {
        final now = DateTime.now();
        setState(() {
          _imageFile = image;
          _imageTimestamp = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);
          _compressedImagePath =
              null; // Reset compressed path jika gambar baru diambil
        });

        // Kompres gambar secara asinkronus
        final compressedImagePath = await _compressImage(image.path);
        if (compressedImagePath != null) {
          setState(() {
            _compressedImagePath = compressedImagePath;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengambil foto. Silakan coba lagi.'),
        ),
      );
    }
  }

  void _submitForm() async {
    if (_isLoading) {
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan ambil foto terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Tampilkan dialog loading
    if (mounted) {
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
                      height: 80,
                      child: ShimmerFormLoading(
                        isDetailed: false,
                        hasImage: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Memproses check-out...",
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            );
          });
    }

    try {
      // Gunakan path gambar yang sudah dikompresi jika tersedia
      final imagePath = _compressedImagePath ?? _imageFile!.path;

      final request = CheckoutRequestModel(
        idSchedule: widget.scheduleId,
        status: _selectedStatus,
        note: _noteController.text,
        tglScheduleLanjutan: '',
        foto: imagePath,
      );

      developer.log(
        'Melakukan check-out untuk jadwal ${widget.scheduleId}',
        name: 'CheckoutForm',
      );
      developer.log(
        'Status: $_selectedStatus',
        name: 'CheckoutForm',
      );
      developer.log(
        'Path foto: $imagePath',
        name: 'CheckoutForm',
      );

      // Atur timeout untuk menghindari request yang berjalan terlalu lama
      await Future.delayed(const Duration(seconds: 1), () {
        return widget.onSubmit(request);
      }).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Timeout saat melakukan check-out. Mohon coba lagi.');
      });

      if (mounted) {
        // Tutup dialog loading
        Navigator.pop(context);

        // Update status jadwal
        context.read<ScheduleBloc>().add(
              UpdateScheduleStatusEvent(
                scheduleId: widget.scheduleId,
                newStatus: _selectedStatus,
                userId: widget.userId,
              ),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out berhasil!'),
            backgroundColor: Colors.green,
          ),
        );

        // Tutup form
        Navigator.pop(context);

        // Kembali ke halaman sebelumnya setelah delay singkat
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.pop(context); // Kembali ke halaman jadwal
          }
        });
      }
    } catch (e) {
      developer.log(
        'Error saat check-out: ${e.toString()}',
        name: 'CheckoutForm',
        error: e,
      );

      if (mounted) {
        // Tutup dialog loading
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              'Check-out Jadwal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    const Text(
                      'Status Kunjungan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _imageFile != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_compressedImagePath ?? _imageFile!.path),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Diambil pada: $_imageTimestamp',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _takePicture,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ambil Ulang Foto'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                )
              : OutlinedButton.icon(
                  onPressed: _takePicture,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Ambil Foto'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              border: OutlineInputBorder(),
              hintText: 'Tambahkan catatan jika diperlukan',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              disabledBackgroundColor: Colors.blue.shade200,
            ),
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ShimmerButtonLoading(
                        width: 80,
                        height: 20,
                        baseColor: Colors.white70,
                        highlightColor: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Memproses...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Check-out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    // Hapus file gambar sementara jika ada
    if (_compressedImagePath != null) {
      File(_compressedImagePath!).delete().ignore();
    }
    super.dispose();
  }
}
