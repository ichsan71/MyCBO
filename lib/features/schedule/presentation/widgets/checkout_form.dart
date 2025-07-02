import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:image/image.dart' as img;
import '../../data/models/checkout_request_model.dart';
import '../../domain/entities/schedule.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_button_loading.dart';

class CheckoutForm extends StatefulWidget {
  final Schedule schedule;
  final Function(CheckoutRequestModel) onSubmit;

  const CheckoutForm({
    Key? key,
    required this.schedule,
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
  final _statusOptions = ['Done', 'Reject'];
  String _selectedStatus = 'Done';
  String? _noteError;
  String? _imageError;

  // Constants for note validation
  static const int _minimumNoteCharacters = 200;
  static const int _maxNoteCharacters = 1000;

  @override
  void initState() {
    super.initState();
    // Add listener for text changes
    _noteController.addListener(() {
      setState(() {
        // Validate note length
        if (_noteController.text.length < _minimumNoteCharacters) {
          _noteError = 'Catatan minimal $_minimumNoteCharacters karakter';
        } else if (_noteController.text.length > _maxNoteCharacters) {
          _noteError = 'Catatan maksimal $_maxNoteCharacters karakter';
        } else {
          _noteError = null;
        }
      });

      // Save form data when text changes
      _saveFormData();
    });

    // Restore form data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = context.read<ScheduleBloc>().state;
      if (currentState is CheckOutFormData &&
          currentState.scheduleId == widget.schedule.id) {
        setState(() {
          _noteController.text = currentState.note;
          _selectedStatus = currentState.status;
          if (currentState.imagePath != null) {
            _imageFile = XFile(currentState.imagePath!);
            _imageTimestamp = currentState.imageTimestamp;
          }
        });
      }
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

  void _saveFormData() {
    if (!mounted) return;

    context.read<ScheduleBloc>().add(
          SaveCheckOutFormEvent(
            imagePath: _imageFile?.path,
            imageTimestamp: _imageTimestamp,
            note: _noteController.text,
            status: _selectedStatus,
            scheduleId: widget.schedule.id,
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
          _imageError = null;
        });

        // Save form data after taking picture
        _saveFormData();

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

  void _handleSubmit() {
    // Validate note
    if (_noteController.text.trim().length < _minimumNoteCharacters) {
      setState(() {
        _noteError = 'Catatan minimal $_minimumNoteCharacters karakter';
      });
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

    setState(() {
      _isLoading = true;
    });

    // Create the request model
    final request = CheckoutRequestModel(
      idSchedule: widget.schedule.id,
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
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is CheckOutSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check-out berhasil!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to schedule list page
          Navigator.of(context).popUntil((route) => route.isFirst);
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
      child: WillPopScope(
        onWillPop: () async {
          // Save form data before popping
          _saveFormData();
          return true;
        },
        child: Container(
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
                        Icon(Icons.check_circle_outline,
                            color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Status Check-out:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
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
                            horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue.shade200),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Foto section dengan error message
              if (_imageError != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _imageError!,
                          style: TextStyle(
                              color: Colors.red.shade700, fontSize: 12),
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
                                  File(
                                      _compressedImagePath ?? _imageFile!.path),
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
                              image: FileImage(File(
                                  _compressedImagePath ?? _imageFile!.path)),
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
              const SizedBox(height: 16),

              // Note section with character count
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _noteError != null
                        ? Colors.red.shade300
                        : Colors.blue.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note_alt_outlined,
                            color: _noteError != null
                                ? Colors.red.shade700
                                : Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Catatan:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${_noteController.text.length}/$_minimumNoteCharacters',
                          style: TextStyle(
                            color: _noteError != null
                                ? Colors.red.shade700
                                : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      maxLines: 5,
                      maxLength: _maxNoteCharacters,
                      decoration: InputDecoration(
                        hintText:
                            'Masukkan catatan minimal $_minimumNoteCharacters karakter',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _noteError != null
                                ? Colors.red.shade300
                                : Colors.blue.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _noteError != null
                                ? Colors.red.shade300
                                : Colors.blue.shade300,
                          ),
                        ),
                        errorText: _noteError,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  disabledBackgroundColor: Colors.blue.shade200,
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
                          Icon(Icons.check_circle,
                              size: 20, color: Colors.white),
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
        ),
      ),
    );
  }
}
