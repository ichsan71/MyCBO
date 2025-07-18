import 'dart:io';
import 'dart:async';
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
import 'package:test_cbo/core/presentation/theme/app_theme.dart';
import 'package:test_cbo/core/services/photo_storage_service.dart';
import 'package:test_cbo/core/di/injection_container.dart' as di;

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
  late PhotoStorageService _photoStorageService;
  bool _isRestoringData = false;
  Timer? _saveNoteTimer;

  // Constants for note validation
  static const int _minimumNoteCharacters = 100;
  static const int _maxNoteCharacters = 200;

  @override
  void initState() {
    super.initState();
    _photoStorageService = di.sl<PhotoStorageService>();

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

      // Save note changes to persistent storage with debouncing
      _saveNoteChanges();
    });

    // Restore persistent photo data first, then bloc form data
    _restorePhotoData();
  }

  /// Restore saved photo data if exists
  Future<void> _restorePhotoData() async {
    try {
      setState(() {
        _isRestoringData = true;
      });

      final photoData = await _photoStorageService.getPhotoData(
          widget.schedule.id, 'checkout');

      if (photoData != null && mounted) {
        // Check if photo file still exists
        final file = File(photoData.photoPath);
        if (await file.exists()) {
          setState(() {
            _imageFile = XFile(photoData.photoPath);
            _compressedImagePath = photoData.photoPath;
            _imageTimestamp = photoData.timestamp;
            if (photoData.note != null) {
              _noteController.text = photoData.note!;
            }
            if (photoData.status != null) {
              _selectedStatus = photoData.status!;
            }
          });

          developer.log(
            'Restored check-out photo data for schedule ${widget.schedule.id}',
            name: 'CheckoutForm',
          );
        } else {
          // Photo file doesn't exist, clean up metadata
          await _photoStorageService.deletePhotoData(widget.schedule.id);
          developer.log(
            'Photo file not found, cleaned up metadata for schedule ${widget.schedule.id}',
            name: 'CheckoutForm',
          );
        }
      }

      // After restoring persistent data, restore bloc form data if available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentState = context.read<ScheduleBloc>().state;
        if (currentState is CheckOutFormData &&
            currentState.scheduleId == widget.schedule.id) {
          setState(() {
            // Only override if persistent data doesn't exist
            if (_imageFile == null && currentState.imagePath != null) {
              _imageFile = XFile(currentState.imagePath!);
              _imageTimestamp = currentState.imageTimestamp;
            }
            if (_noteController.text.isEmpty) {
              _noteController.text = currentState.note;
            }
            _selectedStatus = currentState.status;
          });
        }
      });
    } catch (e) {
      developer.log(
        'Error restoring photo data: ${e.toString()}',
        name: 'CheckoutForm',
        error: e,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRestoringData = false;
        });
      }
    }
  }

  /// Save note changes to persistent storage with debouncing
  void _saveNoteChanges() {
    // Cancel previous timer
    _saveNoteTimer?.cancel();

    // Set new timer with 1 second delay
    _saveNoteTimer = Timer(const Duration(seconds: 1), () async {
      try {
        // Only save if photo exists
        if (_imageFile != null) {
          await _photoStorageService.savePhoto(
            scheduleId: widget.schedule.id,
            originalPhotoPath: _compressedImagePath ?? _imageFile!.path,
            type: 'checkout',
            timestamp: _imageTimestamp ??
                DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
            note: _noteController.text.trim(),
            status: _selectedStatus,
          );
        }
      } catch (e) {
        developer.log(
          'Error saving note changes: ${e.toString()}',
          name: 'CheckoutForm',
          error: e,
        );
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _saveNoteTimer?.cancel();

    // Note: Don't delete persistent photos here as they should remain
    // until successful check-out or auto cleanup
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
        final timestamp = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);

        setState(() {
          _imageFile = image;
          _imageTimestamp = timestamp;
          _compressedImagePath = null; // Reset compressed path
          _imageError = null;
        });

        // Save form data after taking picture
        _saveFormData();

        // Kompres gambar secara asinkronus
        final compressedImagePath = await _compressImage(image.path);
        final finalImagePath = compressedImagePath ?? image.path;

        // Simpan foto dengan PhotoStorageService
        final savedPhotoPath = await _photoStorageService.savePhoto(
          scheduleId: widget.schedule.id,
          originalPhotoPath: finalImagePath,
          type: 'checkout',
          timestamp: timestamp,
          note: _noteController.text.trim(),
          status: _selectedStatus,
        );

        if (savedPhotoPath != null && mounted) {
          setState(() {
            _compressedImagePath = savedPhotoPath;
            _imageFile = XFile(savedPhotoPath);
          });

          developer.log(
            'Photo saved to persistent storage: $savedPhotoPath',
            name: 'CheckoutForm',
          );
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
    if (_isLoading) return;

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
          // Success handling is now done in parent widget (ScheduleDetailPage)
          // Delete photo data after successful check-out
          _photoStorageService.deletePhotoData(widget.schedule.id);
          developer.log(
            'Deleted photo data after successful check-out for schedule ${widget.schedule.id}',
            name: 'CheckoutForm',
          );

          // Reset loading state only
          setState(() {
            _isLoading = false;
          });
        } else if (state is ScheduleError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.getErrorColor(context),
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

              // Show restore loading indicator
              if (_isRestoringData) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppTheme.getPrimaryColor(context)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.getPrimaryColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Memulihkan data foto...'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Status dropdown
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.getPrimaryColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: AppTheme.getPrimaryColor(context)),
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
                        fillColor: AppTheme.getCardBackgroundColor(context),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: AppTheme.getBorderColor(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: AppTheme.getBorderColor(context)),
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

                          // Save status changes to persistent storage
                          _saveNoteChanges();
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
