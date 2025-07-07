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
import '../bloc/schedule_state.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_button_loading.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

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
  String? _locationError;
  String? _imageError;
  String? _noteError;

  // Add minimum character constant
  static const int _minimumNoteCharacters = 10;
  static const int _maxNoteCharacters = 200;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    // Add listener for text changes
    _noteController.addListener(() {
      setState(() {
        // This will trigger a rebuild to update the character count
      });
    });
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

      // Check if mock location is enabled
      bool isMockLocation = position.isMocked;

      if (isMockLocation) {
        if (mounted) {
          setState(() {
            _locationError =
                'Lokasi palsu terdeteksi, silahkan cek kembali lokasi anda';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Anda terdeteksi menggunakan lokasi palsu (Mock Location). Mohon nonaktifkan fitur Mock Location untuk melakukan check-in.',
              ),
              backgroundColor: AppTheme.getErrorColor(context),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _locationError = null;
        });
        await _getAddressFromLatLng(position);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = 'Gagal mendapatkan lokasi';
        });
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

  // Add note validation method
  bool _validateNote() {
    final noteLength = _noteController.text.trim().length;
    if (noteLength < _minimumNoteCharacters) {
      setState(() {
        _noteError = 'Catatan harus minimal $_minimumNoteCharacters karakter';
      });
      return false;
    }
    if (noteLength > _maxNoteCharacters) {
      setState(() {
        _noteError =
            'Catatan tidak boleh lebih dari $_maxNoteCharacters karakter';
      });
      return false;
    }
    setState(() {
      _noteError = null;
    });
    return true;
  }

  void _submitForm() async {
    if (_isLoading) return;

    // Check for mock location error
    if (_locationError ==
        'Lokasi palsu terdeteksi, silahkan cek kembali lokasi anda') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Tidak dapat melakukan check-in dengan lokasi palsu. Mohon nonaktifkan Mock Location.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate note first
    if (!_validateNote()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_noteError!),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Rest of the validation and submission logic
    if (_imageFile == null) {
      setState(() {
        _imageError = 'Silakan ambil foto terlebih dahulu';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan ambil foto terlebih dahulu')),
      );
      return;
    }

    if (_currentPosition == null) {
      setState(() {
        _locationError = 'Lokasi tidak ditemukan';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat mendapatkan lokasi. Silakan coba lagi.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create the request model
    final request = CheckinRequestModel(
      idSchedule: widget.scheduleId,
      userId: widget.userId,
      foto: _compressedImagePath ?? _imageFile!.path,
      lokasi: _currentAddress ?? 'Unknown Location',
      note: _noteController.text.trim(),
    );

    // Call the onSubmit callback
    widget.onSubmit(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is CheckInSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check-in berhasil!'),
              backgroundColor: Colors.green,
            ),
          );
          // Pop back to schedule page
          Navigator.of(context).pop();
        } else if (state is ScheduleError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          // Reset loading state
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Check-in',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Location section dengan error message
            if (_currentPosition != null && _currentAddress != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.getSuccessColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.getSuccessColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: AppTheme.getSuccessColor(context)),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Lokasi saat ini:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh,
                              color: AppTheme.getSuccessColor(context)),
                          onPressed: _getCurrentLocation,
                          tooltip: 'Perbarui lokasi',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_currentAddress!),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Long: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getSecondaryTextColor(context)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _locationError != null
                      ? AppTheme.getErrorColor(context).withOpacity(0.1)
                      : AppTheme.getWarningColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _locationError != null
                        ? AppTheme.getErrorColor(context)
                        : AppTheme.getWarningColor(context),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_off,
                          color: _locationError != null
                              ? AppTheme.getErrorColor(context)
                              : AppTheme.getWarningColor(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _locationError ??
                                'Sedang mendapatkan lokasi saat ini...',
                            style: TextStyle(
                              color: _locationError != null
                                  ? AppTheme.getErrorColor(context)
                                  : AppTheme.getWarningColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_locationError != null) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.getErrorColor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Foto section dengan error message
            if (_imageError != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.getErrorColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: AppTheme.getErrorColor(context), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _imageError!,
                        style: TextStyle(
                            color: AppTheme.getErrorColor(context),
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Foto section
            if (_imageFile != null) ...[
              GestureDetector(
                onTap: () {
                  // Show full screen image preview
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: const Text('Preview Foto'),
                          backgroundColor: Colors.black,
                        ),
                        body: Container(
                          color: Colors.black,
                          child: Center(
                            child: InteractiveViewer(
                              panEnabled: true,
                              boundaryMargin: const EdgeInsets.all(20),
                              minScale: 0.5,
                              maxScale: 4,
                              child: Image.file(
                                File(_compressedImagePath ?? _imageFile!.path),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(
                                File(_compressedImagePath ?? _imageFile!.path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_imageTimestamp != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Foto diambil pada: $_imageTimestamp',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
            ],

            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: Text(
                _imageFile == null ? 'Ambil Foto' : 'Ambil Ulang Foto',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.getPrimaryColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modified note input field with character count
            TextField(
              controller: _noteController,
              maxLength: _maxNoteCharacters,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Catatan',
                alignLabelWithHint: true,
                errorText: _noteError,
                counterText:
                    '${_noteController.text.length}/$_maxNoteCharacters',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.getPrimaryColor(context),
                disabledBackgroundColor:
                    AppTheme.getPrimaryColor(context).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShimmerButtonLoading(
                          width: 80,
                          height: 20,
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Memproses...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 20, color: Colors.white),
                        SizedBox(width: 8),
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
            ),
          ],
        ),
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
