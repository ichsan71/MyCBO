import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:test_cbo/core/presentation/widgets/app_button.dart';
import 'package:test_cbo/core/presentation/widgets/app_card.dart';
import 'package:test_cbo/core/presentation/widgets/app_text_field.dart';
import 'package:test_cbo/core/presentation/widgets/app_bar_widget.dart';
import 'package:test_cbo/core/di/injection_container.dart' as di;
import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_state.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic_base.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_event.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_state.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_schedule_loading.dart';
import 'package:test_cbo/core/presentation/widgets/success_message.dart';
import '../../data/models/edit_schedule_data_model.dart';
import '../../data/models/update_schedule_request_model.dart';
import '../../data/models/edit/edit_schedule_product_model.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

class EditSchedulePage extends StatelessWidget {
  final int scheduleId;

  const EditSchedulePage({Key? key, required this.scheduleId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScheduleBloc>(
      create: (context) => di.sl<ScheduleBloc>()
        ..add(GetEditScheduleDataEvent(scheduleId: scheduleId)),
      child: _EditScheduleView(scheduleId: scheduleId),
    );
  }
}

class _EditScheduleView extends StatefulWidget {
  final int scheduleId;

  const _EditScheduleView({Key? key, required this.scheduleId})
      : super(key: key);

  @override
  _EditScheduleViewState createState() => _EditScheduleViewState();
}

class _EditScheduleViewState extends State<_EditScheduleView> {
  final _formKey = GlobalKey<FormState>();
  static const String _tag = 'EditSchedulePage';

  // Form validation constants
  static const int _minimumNoteCharacters = 10;
  static const int _maximumNoteCharacters = 200;
  String? _noteError;

  // Form controllers
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _doctorSearchController = TextEditingController();
  final TextEditingController _productSearchController =
      TextEditingController();

  // Selected values
  int? _selectedTypeScheduleId;
  DoctorClinicBase? _selectedDoctor;
  String _selectedShift = 'pagi';
  List<String> _selectedProductIds = [];
  List<int> _selectedDivisiIds = [];
  List<int> _selectedSpesialisIds = [];
  String _selectedDestinationType = 'dokter';

  // Search queries
  String _doctorSearchQuery = '';
  String _productSearchQuery = '';

  // Data lists
  List<DoctorClinicBase> _filteredDoctors = [];
  List<EditScheduleProductModel> _selectedProducts = [];

  // Add memory cache for filtered data
  final ValueNotifier<List<DoctorClinicBase>> _filteredDoctorsNotifier =
      ValueNotifier<List<DoctorClinicBase>>([]);
  final ValueNotifier<List<EditScheduleProductModel>>
      _filteredProductsNotifier =
      ValueNotifier<List<EditScheduleProductModel>>([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEditData();
    });
  }

  void _loadEditData() {
    if (!mounted) return;
    context
        .read<ScheduleBloc>()
        .add(GetEditScheduleDataEvent(scheduleId: widget.scheduleId));
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _noteController.dispose();
    _doctorSearchController.dispose();
    _productSearchController.dispose();
    _filteredDoctorsNotifier.dispose();
    _filteredProductsNotifier.dispose();
    super.dispose();
  }

  // Helper function to format date for display (MM/dd/yyyy)
  String _formatDateForDisplay(String date) {
    try {
      DateTime parsedDate;
      // Try to parse the date from various formats
      if (date.contains('-')) {
        // If date is in YYYY-MM-DD format
        parsedDate = DateTime.parse(date);
      } else if (date.contains('/')) {
        // If date is in MM/dd/yyyy format
        final parts = date.split('/');
        if (parts.length == 3) {
          parsedDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[0]), // month
            int.parse(parts[1]), // day
          );
        } else {
          throw const FormatException('Invalid date format');
        }
      } else {
        throw const FormatException('Unsupported date format');
      }
      
      // Format the date as MM/dd/yyyy
      return DateFormat('MM/dd/yyyy').format(parsedDate);
    } catch (e) {
      Logger.error(_tag, 'Error formatting date: $e');
      return date;
    }
  }

  // Helper function to validate date format
  bool _isValidDateFormat(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) return false;
      
      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;
      if (year < 2000 || year > 2100) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        // Format the date as MM/dd/yyyy
        _tanggalController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  void _populateFields(EditScheduleDataModel data) {
    Logger.info(_tag, 'Starting to populate fields...');

    // Initialize filtered lists immediately
    _filteredDoctorsNotifier.value = List<DoctorClinicBase>.from(data.doctors);
    _filteredProductsNotifier.value =
        List<EditScheduleProductModel>.from(data.products);

    setState(() {
      // Populate schedule data
      final scheduleData = data.schedule;

      // Debug log for type schedule data
      Logger.info(
          _tag, 'Current type schedule from API: ${scheduleData.tipeSchedule}');
      Logger.info(_tag, 'Available type schedules:');
      for (var type in data.typeSchedules) {
        Logger.info(_tag, '- Type ID: ${type.id}, Name: ${type.name}');
      }

      // Set type schedule by matching ID from type_schedule with data_type_schedule
      try {
        final typeScheduleId = int.tryParse(scheduleData.tipeSchedule);
        Logger.info(_tag, 'Parsed type schedule ID: $typeScheduleId');

        if (typeScheduleId != null) {
          _selectedTypeScheduleId = typeScheduleId;
          final matchingTypeSchedule = data.typeSchedules.firstWhere(
            (type) => type.id == typeScheduleId,
            orElse: () {
              Logger.warning(_tag,
                  'No matching type schedule found for ID: $typeScheduleId');
              return data.typeSchedules.first;
            },
          );
          Logger.info(_tag,
              'Found matching type schedule: ${matchingTypeSchedule.name}');
        } else if (data.typeSchedules.isNotEmpty) {
          _selectedTypeScheduleId = data.typeSchedules.first.id;
          Logger.info(_tag,
              'Using first type schedule as default: ${data.typeSchedules.first.name}');
        } else {
          Logger.warning(_tag, 'No type schedules available');
        }
      } catch (e) {
        Logger.error(_tag, 'Error setting type schedule: $e');
      }

      // Debug log for doctor data
      Logger.info(_tag, 'Current doctor ID from API: ${scheduleData.idTujuan}');
      Logger.info(_tag, 'Available doctors:');
      for (var doctor in data.doctors) {
        Logger.info(_tag,
            '- Doctor ID: ${doctor.id}, Name: ${doctor.nama}, Specialist: ${doctor.spesialis}');
      }

      // Set destination type and find doctor using id_tujuan
      try {
        _selectedDestinationType = scheduleData.tujuan.toLowerCase();
        final doctorId = scheduleData.idTujuan;

        Logger.info(_tag, 'Looking for doctor with ID: $doctorId');
        Logger.info(_tag, 'Total available doctors: ${data.doctors.length}');

        if (doctorId != 0 && data.doctors.isNotEmpty) {
          // Find the doctor in the doctors list using id_tujuan
          _selectedDoctor = data.doctors.firstWhere(
            (doctor) => doctor.id == doctorId,
            orElse: () {
              Logger.warning(_tag,
                  'Doctor with ID $doctorId not found, using first available doctor');
              return data.doctors.first;
            },
          );

          if (_selectedDoctor != null) {
            _doctorSearchController.text = _selectedDoctor!.nama;
            Logger.info(_tag,
                'Selected doctor: ${_selectedDoctor!.nama} (ID: ${_selectedDoctor!.id})');
          }
        } else {
          Logger.warning(_tag,
              'No valid doctor ID found in schedule data or no doctors available');
          if (data.doctors.isNotEmpty) {
            _selectedDoctor = data.doctors.first;
            _doctorSearchController.text = _selectedDoctor!.nama;
            Logger.info(_tag,
                'Using first available doctor: ${_selectedDoctor!.nama} (ID: ${_selectedDoctor!.id})');
          }
        }

        // Store all doctors for filtering
        _filteredDoctors = List<DoctorClinicBase>.from(data.doctors);
        Logger.info(
            _tag, 'Stored ${_filteredDoctors.length} doctors for filtering');
      } catch (e) {
        Logger.error(_tag, 'Error processing doctor data: $e');
        _filteredDoctors = [];
      }

      // Set date
      try {
        final dateTime = DateTime.parse(scheduleData.tglVisit);
        _tanggalController.text = DateFormat('MM/dd/yyyy').format(dateTime);
      } catch (e) {
        Logger.error(_tag, 'Error parsing date: $e');
        _tanggalController.text = scheduleData.tglVisit;
      }

      // Set shift (only pagi and sore)
      _selectedShift = scheduleData.shift.toLowerCase();
      if (!['pagi', 'sore'].contains(_selectedShift)) {
        _selectedShift = 'pagi';
      }

      // Set note
      _noteController.text = scheduleData.note;

      // Initialize selected products from product IDs in schedule data
      _selectedProductIds = [];
      _selectedProducts = [];
      if (scheduleData.product != null && scheduleData.product!.isNotEmpty) {
        try {
          // Parse the product string which is in format ["164"]
          final productString = scheduleData.product!
              .toString()
              .replaceAll('"', '')
              .replaceAll('[', '')
              .replaceAll(']', '');
          final productIds = productString
              .split(',')
              .map((id) => id.trim())
              .where((id) => id.isNotEmpty)
              .toList();

          for (var productId in productIds) {
            try {
              final productData = data.products.firstWhere(
                (p) => p.idProduct.toString() == productId,
                orElse: () => const EditScheduleProductModel(
                  idProduct: 0,
                  namaProduct: '',
                  idDivisiSales: [],
                  idSpesialis: [],
                ),
              );
              if (productData.idProduct != 0) {
                _selectedProductIds.add(productId);
                _selectedProducts.add(productData);
              }
            } catch (e) {
              Logger.error(
                  _tag, 'Error finding product with ID $productId: $e');
            }
          }
        } catch (e) {
          Logger.error(_tag, 'Error parsing product IDs: $e');
        }
      }

      // Set divisi and spesialis IDs from selected products
      _selectedDivisiIds = [];
      _selectedSpesialisIds = [];
      for (var product in _selectedProducts) {
        _selectedDivisiIds.addAll(
          product.idDivisiSales.map((id) => int.parse(id)).toList(),
        );
        _selectedSpesialisIds.addAll(
          product.idSpesialis.map((id) => int.parse(id)).toList(),
        );
      }

      Logger.info(_tag, 'Fields populated successfully');
      Logger.info(_tag, 'Selected type schedule: $_selectedTypeScheduleId');
      Logger.info(_tag, 'Selected doctor: ${_selectedDoctor?.nama}');
      Logger.info(_tag, 'Selected products: ${_selectedProducts.length}');
      Logger.info(_tag, 'Selected divisi IDs: $_selectedDivisiIds');
      Logger.info(_tag, 'Selected spesialis IDs: $_selectedSpesialisIds');
    });
  }

  Future<void> _submitForm(int userId) async {
    if (!_formKey.currentState!.validate()) return;

    if (_noteController.text.trim().length < _minimumNoteCharacters) {
      setState(() {
        _noteError = 'Catatan minimal $_minimumNoteCharacters karakter';
      });
      return;
    }

    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu produk'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final state = context.read<ScheduleBloc>().state;
    if (state is! EditScheduleLoaded) return;

    final theme = Theme.of(context);

    // Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: theme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Konfirmasi Perubahan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Detail perubahan yang akan disimpan:',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // Detail perubahan
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                          'Tipe Jadwal',
                          state.editScheduleData.typeSchedules
                              .firstWhere(
                                  (type) => type.id == _selectedTypeScheduleId)
                              .name),
                      const SizedBox(height: 8),
                      _buildDetailRow('Dokter', _selectedDoctor?.nama ?? '-'),
                      const SizedBox(height: 8),
                      _buildDetailRow('Tanggal', _tanggalController.text),
                      const SizedBox(height: 8),
                      _buildDetailRow('Shift', _selectedShift.toUpperCase()),
                      const SizedBox(height: 8),
                      _buildDetailRow('Jumlah Produk',
                          '${_selectedProducts.length} produk'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: theme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(color: theme.primaryColor),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Ya, Simpan'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      try {
        // Log data before creating request model
        Logger.info(_tag, 'Creating request model with data:');
        Logger.info(_tag, 'Schedule ID: ${widget.scheduleId}');
        Logger.info(_tag, 'Type Schedule ID: $_selectedTypeScheduleId');
        Logger.info(_tag, 'Destination Type: $_selectedDestinationType');
        Logger.info(_tag, 'Visit Date: ${_tanggalController.text}');
        Logger.info(_tag, 'Selected Products: $_selectedProductIds');
        Logger.info(_tag, 'Note: ${_noteController.text.trim()}');
        Logger.info(_tag, 'User ID: $userId');
        Logger.info(_tag, 'Selected Division IDs: $_selectedDivisiIds');
        Logger.info(_tag, 'Selected Specialist IDs: $_selectedSpesialisIds');
        Logger.info(_tag, 'Shift: $_selectedShift');
        Logger.info(_tag, 'Doctor ID: ${_selectedDoctor?.id}');

        final requestModel = UpdateScheduleRequestModel(
          id: widget.scheduleId,
          typeSchedule: _selectedTypeScheduleId!,
          tujuan: _selectedDestinationType,
          tglVisit: _tanggalController.text,
          product: _selectedProductIds,
          note: _noteController.text.trim(),
          idUser: userId,
          productForIdDivisi: _selectedDivisiIds,
          productForIdSpesialis: _selectedSpesialisIds,
          shift: _selectedShift,
          jenis: 'suddenly',
          dokter: _selectedDoctor?.id ?? 0,
          klinik: '',
        );

        Logger.info(_tag, 'Request model created successfully');
        Logger.info(_tag, 'Request model data: ${requestModel.toJson()}');

        context
            .read<ScheduleBloc>()
            .add(UpdateScheduleEvent(requestModel: requestModel));
      } catch (e, stackTrace) {
        Logger.error(_tag, 'Error creating request model: $e');
        Logger.error(_tag, 'Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Optimize search functions
  void _filterDoctors(String query) {
    if (!mounted) return;

    _filteredDoctorsNotifier.value = _filteredDoctorsNotifier.value
        .where(
            (doctor) => doctor.nama.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void _filterProducts(String query) {
    if (!mounted) return;

    _filteredProductsNotifier.value = _filteredProductsNotifier.value
        .where((product) =>
            product.namaProduct.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Use const where possible for static widgets
  static const _spacer16 = SizedBox(height: 16);
  static const _spacer8 = SizedBox(height: 8);
  static const _spacer24 = SizedBox(height: 24);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const AppBarWidget(title: 'Edit Jadwal'),
      restorationId: 'edit_schedule_page_${widget.scheduleId}',
      body: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return BlocConsumer<ScheduleBloc, ScheduleState>(
              listenWhen: (previous, current) => previous != current,
              buildWhen: (previous, current) => previous != current,
              listener: (context, state) {
                if (state is ScheduleUpdated) {
                  if (mounted) {
                    SuccessMessage.show(
                      context: context,
                      message: 'Jadwal berhasil diperbarui',
                      onDismissed: () {
                        if (mounted) {
                          // Navigasi ke DashboardPage dengan tab jadwal aktif
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/dashboard',
                            (route) => false,
                            arguments: 1, // Index 1 untuk tab jadwal
                          );
                        }
                      },
                    );
                  }
                } else if (state is ScheduleUpdateError) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } else if (state is EditScheduleLoaded) {
                  _populateFields(state.editScheduleData);
                }
              },
              builder: (context, state) {
                if (state is EditScheduleLoaded) {
                  return SingleChildScrollView(
                    key: ValueKey('edit_schedule_${widget.scheduleId}'),
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppCard(
                            elevation: 2,
                            backgroundColor: AppTheme.scheduleCardColor,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppTheme.scheduleIconColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Informasi Jadwal',
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.scheduleHeaderColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _spacer16,

                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tipe Jadwal',
                                  style: theme.textTheme.titleMedium,
                                ),
                                _spacer8,
                                _buildTypeScheduleDropdown(
                                    state.editScheduleData),
                              ],
                            ),
                          ),
                          _spacer16,

                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal',
                                  style: theme.textTheme.titleMedium,
                                ),
                                _spacer8,
                                _buildDateField(),
                              ],
                            ),
                          ),
                          _spacer16,

                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shift',
                                  style: theme.textTheme.titleMedium,
                                ),
                                _spacer8,
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Pagi'),
                                        value: 'pagi',
                                        groupValue: _selectedShift,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedShift = value!;
                                          });
                                        },
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Sore'),
                                        value: 'sore',
                                        groupValue: _selectedShift,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedShift = value!;
                                          });
                                        },
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _spacer24,

                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                color: Colors.teal,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tujuan',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          _spacer16,

                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Dokter'),
                                        value: 'dokter',
                                        groupValue: _selectedDestinationType,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedDestinationType = value!;
                                          });
                                        },
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Klinik'),
                                        value: 'klinik',
                                        groupValue: _selectedDestinationType,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedDestinationType = value!;
                                          });
                                        },
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _spacer16,

                          if (_selectedDestinationType == 'dokter') ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Pilih Dokter',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            _spacer16,
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppTextField(
                                    controller: _doctorSearchController,
                                    hintText: 'Cari dokter...',
                                    prefixIcon: const Icon(Icons.search),
                                    onChanged: (value) {
                                      setState(() {
                                        _doctorSearchQuery =
                                            value.toLowerCase();
                                        _filterDoctors(_doctorSearchQuery);
                                      });
                                    },
                                  ),
                                  _spacer16,

                                  Text(
                                    'Pilih Dokter (${_filteredDoctors.length} dokter ditemukan)',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  _spacer8,

                                  _buildDoctorList(_filteredDoctors),
                                ],
                              ),
                            ),
                          ],
                          _spacer24,

                          Row(
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.purple,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Produk',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          _spacer16,

                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_selectedProducts.isNotEmpty) ...[
                                  Text(
                                    'Produk Terpilih',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  _spacer8,
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _selectedProducts.map((product) {
                                      return Chip(
                                        label: Text(
                                          product.namaProduct,
                                          style: TextStyle(
                                            color:
                                                AppTheme.scheduleHighlightColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        backgroundColor:
                                            AppTheme.scheduleSelectedItemColor,
                                        deleteIcon: Icon(
                                          Icons.close,
                                          size: 18,
                                          color:
                                              AppTheme.scheduleHighlightColor,
                                        ),
                                        onDeleted: () =>
                                            _removeProduct(product),
                                        side: BorderSide(
                                          color: AppTheme.scheduleHighlightColor
                                              .withValues(
                                            alpha: 25.0,
                                            red: AppTheme
                                                .scheduleHighlightColor.red
                                                .toDouble(),
                                            green: AppTheme
                                                .scheduleHighlightColor.green
                                                .toDouble(),
                                            blue: AppTheme
                                                .scheduleHighlightColor.blue
                                                .toDouble(),
                                          ),
                                          width: 1,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  _spacer16,
                                  const Divider(),
                                  _spacer16,
                                ],

                                AppTextField(
                                  controller: _productSearchController,
                                  hintText: 'Cari Produk',
                                  prefixIcon: const Icon(Icons.search),
                                  onChanged: (value) {
                                    setState(() {
                                      _productSearchQuery = value;
                                      _filterProducts(_productSearchQuery);
                                    });
                                  },
                                ),
                                _spacer16,

                                Container(
                                  constraints:
                                      const BoxConstraints(maxHeight: 300),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          theme.colorScheme.outline.withValues(
                                        alpha: 51.0,
                                        red: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .red
                                            .toDouble(),
                                        green: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .green
                                            .toDouble(),
                                        blue: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .blue
                                            .toDouble(),
                                      ),
                                    ),
                                  ),
                                  child: ValueListenableBuilder<
                                      List<EditScheduleProductModel>>(
                                    valueListenable: _filteredProductsNotifier,
                                    builder: (context, filteredProducts, _) {
                                      return ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: filteredProducts.length,
                                        separatorBuilder: (context, index) =>
                                            Divider(
                                          height: 1,
                                          color: theme.colorScheme.outline
                                              .withValues(
                                            alpha: 25.0,
                                            red: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .red
                                                .toDouble(),
                                            green: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .green
                                                .toDouble(),
                                            blue: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .blue
                                                .toDouble(),
                                          ),
                                        ),
                                        itemBuilder: (context, index) {
                                          final product =
                                              filteredProducts[index];
                                          final isSelected =
                                              _selectedProducts.any((p) =>
                                                  p.idProduct ==
                                                  product.idProduct);

                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (isSelected) {
                                                  _removeProduct(product);
                                                } else {
                                                  if (!_selectedProducts.any(
                                                      (p) =>
                                                          p.idProduct ==
                                                          product.idProduct)) {
                                                    _selectedProducts
                                                        .add(product);
                                                    _selectedProductIds.add(
                                                        product.idProduct
                                                            .toString());
                                                    _selectedDivisiIds.addAll(
                                                        product.idDivisiSales
                                                            .map((id) =>
                                                                int.parse(id))
                                                            .toList());
                                                    _selectedSpesialisIds
                                                        .addAll(product
                                                            .idSpesialis
                                                            .map((id) =>
                                                                int.parse(id))
                                                            .toList());
                                                  }
                                                }
                                              });
                                            },
                                            child: Container(
                                              color: isSelected
                                                  ? AppTheme
                                                      .scheduleSelectedItemColor
                                                  : AppTheme.scheduleCardColor,
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? AppTheme
                                                              .scheduleHighlightColor
                                                              .withValues(
                                                              alpha: 25.0,
                                                              red: AppTheme
                                                                  .scheduleHighlightColor
                                                                  .red
                                                                  .toDouble(),
                                                              green: AppTheme
                                                                  .scheduleHighlightColor
                                                                  .green
                                                                  .toDouble(),
                                                              blue: AppTheme
                                                                  .scheduleHighlightColor
                                                                  .blue
                                                                  .toDouble(),
                                                            )
                                                          : AppTheme
                                                              .scheduleBackgroundColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .medical_services_outlined,
                                                      color: isSelected
                                                          ? AppTheme
                                                              .scheduleHighlightColor
                                                          : AppTheme
                                                              .scheduleIconColor,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          product.namaProduct,
                                                          style: theme.textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: isSelected
                                                                ? AppTheme
                                                                    .scheduleHighlightColor
                                                                : AppTheme
                                                                    .scheduleTextColor,
                                                          ),
                                                        ),
                                                        if (product.desc
                                                                ?.isNotEmpty ??
                                                            false) ...[
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            product.desc!,
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                              color: AppTheme
                                                                  .scheduleSubtextColor,
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: AppTheme
                                                          .scheduleHighlightColor,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _spacer24,

                          Row(
                            children: [
                              const Icon(
                                Icons.note_outlined,
                                color: Colors.blue,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Catatan',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' *',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          _spacer16,

                          AppCard(
                            child: AppTextField(
                              controller: _noteController,
                              hintText:
                                  'Tulis catatan kunjungan (minimal 50 karakter)',
                              maxLines: 4,
                              onChanged: (value) {
                                setState(() {
                                  if (value.trim().isEmpty) {
                                    _noteError = 'Catatan wajib diisi';
                                  } else if (value.trim().length <
                                      _minimumNoteCharacters) {
                                    _noteError =
                                        'Catatan minimal $_minimumNoteCharacters karakter';
                                  } else if (value.trim().length >
                                      _maximumNoteCharacters) {
                                    _noteError =
                                        'Catatan maksimal $_maximumNoteCharacters karakter';
                                  } else {
                                    _noteError = null;
                                  }
                                });
                              },
                              errorText: _noteError,
                              helperText:
                                  'Minimal $_minimumNoteCharacters karakter',
                            ),
                          ),
                          _spacer24,

                          AppButton(
                            text: 'Simpan',
                            onPressed: () => _submitForm(authState.user.idUser),
                            isLoading: state is ScheduleUpdating,
                            type: AppButtonType.primary,
                            isFullWidth: true,
                          ),
                          _spacer24,
                        ],
                      ),
                    ),
                  );
                }
                return const ShimmerScheduleLoading();
              },
            );
          }
          return const Center(child: Text('Silakan login terlebih dahulu'));
        },
      ),
    );
  }

  Widget _buildTypeScheduleDropdown(EditScheduleDataModel data) {
    return DropdownButtonFormField<int>(
      value: _selectedTypeScheduleId,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Pilih Tipe Jadwal',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: data.typeSchedules.map((type) {
        return DropdownMenuItem<int>(
          value: type.id,
          child: Text(type.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedTypeScheduleId = value;
          });
        }
      },
      validator: (value) => value == null ? 'Pilih tipe jadwal' : null,
    );
  }

  void _removeProduct(EditScheduleProductModel product) {
    setState(() {
      _selectedProducts.remove(product);
      _selectedProductIds.remove(product.idProduct.toString());

      // Remove divisi and spesialis IDs for this product
      final divisiIds =
          product.idDivisiSales.map((id) => int.parse(id)).toList();
      final spesialisIds =
          product.idSpesialis.map((id) => int.parse(id)).toList();

      _selectedDivisiIds.removeWhere((id) => divisiIds.contains(id));
      _selectedSpesialisIds.removeWhere((id) => spesialisIds.contains(id));
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorList(List<DoctorClinicBase> doctors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(
              alpha: isDark ? 51.0 : 25.0,
              red: Theme.of(context).primaryColor.red.toDouble(),
              green: Theme.of(context).primaryColor.green.toDouble(),
              blue: Theme.of(context).primaryColor.blue.toDouble(),
            ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 51.0,
                red: Theme.of(context).colorScheme.outline.red.toDouble(),
                green: Theme.of(context).colorScheme.outline.green.toDouble(),
                blue: Theme.of(context).colorScheme.outline.blue.toDouble(),
              ),
        ),
      ),
      child: ValueListenableBuilder<List<DoctorClinicBase>>(
        valueListenable: _filteredDoctorsNotifier,
        builder: (context, filteredDoctors, _) {
          return ListView.separated(
            shrinkWrap: true,
            itemCount: filteredDoctors.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outline.withValues(
                    alpha: 25.0,
                    red: Theme.of(context).colorScheme.outline.red.toDouble(),
                    green:
                        Theme.of(context).colorScheme.outline.green.toDouble(),
                    blue: Theme.of(context).colorScheme.outline.blue.toDouble(),
                  ),
            ),
            itemBuilder: (context, index) {
              final doctor = filteredDoctors[index];
              final isSelected = _selectedDoctor?.id == doctor.id;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDoctor = doctor;
                    _doctorSearchController.text = doctor.nama;
                  });
                },
                child: Container(
                  color: isSelected
                      ? AppTheme.scheduleSelectedItemColor
                      : AppTheme.scheduleCardColor,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.scheduleHighlightColor.withValues(
                                  alpha: 25.0,
                                  red: AppTheme.scheduleHighlightColor.red
                                      .toDouble(),
                                  green: AppTheme.scheduleHighlightColor.green
                                      .toDouble(),
                                  blue: AppTheme.scheduleHighlightColor.blue
                                      .toDouble(),
                                )
                              : AppTheme.scheduleBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: isSelected
                              ? AppTheme.scheduleHighlightColor
                              : AppTheme.scheduleIconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          doctor.nama,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: isSelected
                                        ? AppTheme.scheduleHighlightColor
                                        : AppTheme.scheduleTextColor,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDateField() {
    return AppTextField(
      controller: _tanggalController,
      hintText: 'Pilih tanggal visit',
      labelText: 'Tanggal Visit',
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Tanggal visit harus diisi';
        }
        if (!_isValidDateFormat(value)) {
          return 'Format tanggal tidak valid (MM/dd/yyyy)';
        }
        return null;
      },
      suffixIcon: const Icon(Icons.calendar_today),
    );
  }
}
