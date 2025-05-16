import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:image/image.dart' as img;
import '../../data/models/checkin_request_model.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_loading.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_form_loading.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_button_loading.dart';

class CheckinForm extends StatefulWidget {
  final int scheduleId;
  final int userId;
  final Function(CheckinRequestModel) onSubmit;

  const CheckinForm({
    Key? key,
    required this.scheduleId,
    required this.userId,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<CheckinForm> createState() => _CheckinFormState();
}

class _CheckinFormState extends State<CheckinForm> {
  final _noteController = TextEditingController();
  Position? _currentPosition;
  String? _currentAddress;
  XFile? _imageFile;
  String? _compressedImagePath;
  String? _imageTimestamp;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Request location permission
    final locationStatus = await Permission.location.request();
    if (locationStatus.isGranted) {
      _getCurrentLocation();
    }

    // Request camera permission
    await Permission.camera.request();
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      });
    } catch (e) {
      developer.log(
        'Error mendapatkan alamat: ${e.toString()}',
        name: 'CheckinForm',
        error: e,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layanan lokasi tidak aktif. Mohon aktifkan GPS.'),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Izin lokasi ditolak. Mohon berikan izin lokasi di pengaturan.'),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin lokasi ditolak secara permanen. Mohon berikan izin lokasi di pengaturan perangkat.',
            ),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
        await _getAddressFromLatLng(position);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan lokasi: ${e.toString()}'),
          ),
        );
      }
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
        name: 'CheckinForm',
      );

      return outputPath;
    } catch (e) {
      developer.log(
        'Error saat kompresi gambar: ${e.toString()}',
        name: 'CheckinForm',
        error: e,
      );
      return null;
    }
  }

  Future<void> _takePicture() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Ambil gambar dari kamera
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
    // Cek jika sedang loading, jangan submit lagi
    if (_isLoading) {
      return;
    }

    if (_currentPosition == null || _currentAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Mohon tunggu, sedang mendapatkan lokasi...')),
      );
      // Coba mendapatkan lokasi lagi
      _getCurrentLocation();
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
                    Text("Memproses check-in...",
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

      final request = CheckinRequestModel(
        idSchedule: widget.scheduleId,
        lokasi: _currentAddress!,
        note: _noteController.text,
        foto: imagePath,
      );

      developer.log(
        'Melakukan check-in untuk jadwal ${widget.scheduleId}',
        name: 'CheckinForm',
      );
      developer.log(
        'Alamat: $_currentAddress',
        name: 'CheckinForm',
      );
      developer.log(
        'Path foto: $imagePath',
        name: 'CheckinForm',
      );

      // Atur timeout untuk menghindari request yang berjalan terlalu lama
      final result = await Future.delayed(const Duration(seconds: 1), () {
        return widget.onSubmit(request);
      }).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Timeout saat melakukan check-in. Mohon coba lagi.');
      });

      if (mounted) {
        // Tutup dialog loading
        Navigator.of(context).pop();

        // Update status jadwal
        context.read<ScheduleBloc>().add(
              UpdateScheduleStatusEvent(
                scheduleId: widget.scheduleId,
                newStatus: 'Check-in',
                userId: widget.userId,
              ),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in berhasil!'),
            backgroundColor: Colors.green,
          ),
        );

        developer.log(
          'Check-in berhasil untuk jadwal ${widget.scheduleId}',
          name: 'CheckinForm',
        );

        Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      developer.log(
        'Error saat check-in: ${e.toString()}',
        name: 'CheckinForm',
        error: e,
      );

      if (mounted) {
        // Tutup dialog loading
        Navigator.of(context).pop();

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form title
          Center(
            child: Text(
              'Check-in Jadwal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Location section
          if (_currentPosition != null && _currentAddress != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Lokasi saat ini:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_currentAddress!),
                  const SizedBox(height: 4),
                  Text(
                    'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Long: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 24,
                    child: ShimmerLoading(
                      baseColor: Colors.orange.shade200,
                      highlightColor: Colors.orange.shade50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Sedang mendapatkan lokasi saat ini...',
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Foto section
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

          // Catatan section
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

          // Submit button
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              disabledBackgroundColor: Colors.blue.shade200,
            ),
            child: _isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShimmerButtonLoading(
                        width: 80,
                        height: 20,
                        baseColor: Colors.white70,
                        highlightColor: Colors.white,
                      ),
                      SizedBox(width: 16),
                      Text(
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
                      Icon(Icons.check_circle, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Check-in',
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
