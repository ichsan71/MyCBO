import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:image/image.dart' as img;
import '../../data/models/checkout_request_model.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_button_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final _statusOptions = ['Selesai', 'Ditolak'];
  String _selectedStatus = 'Selesai';
  String? _noteError;

  // Constants for note validation
  static const int _minimumNoteCharacters = 100;
  static const int _maxNoteCharacters = 200;

  @override
  void initState() {
    super.initState();
    // Add listener for text changes
    _noteController.addListener(() {
      setState(() {
        // This will trigger a rebuild to update the character count
      });
    });
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

  // Validasi untuk catatan
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
    if (_isLoading) {
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

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan ambil foto terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create the request model
    final request = CheckoutRequestModel(
      idSchedule: widget.scheduleId,
      foto: _compressedImagePath ?? _imageFile!.path,
      status: _selectedStatus,
      note: _noteController.text.trim(),
      tglScheduleLanjutan: '',
    );

    // Call the onSubmit callback
    widget.onSubmit(request);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Check-out',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Status dropdown
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _statusOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
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
          const SizedBox(height: 16),

          // Modified note input field with character count
          TextField(
            controller: _noteController,
            maxLength: _maxNoteCharacters,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Catatan',
              alignLabelWithHint: true,
              errorText: _noteError,
              counterText: '${_noteController.text.length}/$_maxNoteCharacters',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Photo section
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
                  color: Colors.grey[600],
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
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
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
              backgroundColor: Colors.green,
              disabledBackgroundColor: Colors.green.shade200,
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
                        baseColor: Colors.white70,
                        highlightColor: Colors.white,
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
  }
}
