import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:test_cbo/core/presentation/widgets/app_bar_widget.dart';
import 'package:test_cbo/core/presentation/widgets/app_button.dart';
import 'package:test_cbo/core/presentation/widgets/app_card.dart';
import 'package:test_cbo/core/presentation/widgets/app_dropdown.dart';
import 'package:test_cbo/core/presentation/widgets/app_text_field.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_schedule_loading.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_state.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic.dart';
import 'package:test_cbo/features/schedule/domain/entities/product.dart';
import 'package:test_cbo/features/schedule/domain/entities/schedule_type.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_bloc.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_event.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_state.dart';
import 'package:test_cbo/core/di/injection_container.dart' as di;
import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/data/models/doctor_clinic_model.dart'
    as model;
import 'package:test_cbo/features/schedule/data/models/doctor_model.dart';
import 'package:test_cbo/features/schedule/data/models/responses/doctor_response.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic_base.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  static const String _tag = 'AddSchedulePage';

  // Form controllers
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Konstanta untuk validasi catatan
  static const int _minimumNoteCharacters = 10;
  static const int _maximumNoteCharacters = 500;
  String? _noteError;

  // Selected values
  ScheduleType? _selectedScheduleType;
  DoctorClinic? _selectedDoctor;
  String _selectedShift = 'pagi';
  final String _selectedJenis = 'suddenly';
  final List<Product> _selectedProducts = [];
  final List<int> _selectedProductDivisiIds = [];
  final List<int> _selectedProductSpesialisIds = [];

  // Lists for doctors
  final List<DoctorClinic> doctors = [];
  final List<DoctorClinic> filteredDoctors = [];

  // Tambahkan variabel untuk menyimpan nama-nama
  final List<String> _selectedProductNames = [];
  final List<String> _selectedDivisiNames = [];
  final List<String> _selectedSpesialisNames = [];

  // Pilihan tujuan (dokter atau klinik)
  String _selectedDestinationType = 'dokter'; // Default: dokter

  // Search controllers
  final TextEditingController _doctorSearchController = TextEditingController();
  final TextEditingController _productSearchController =
      TextEditingController();
  String _doctorSearchQuery = '';
  String _productSearchQuery = '';

  // Mapping ID spesialis ke nama spesialis
  final Map<int, String> _spesialisNames = {
    1: 'Umum',
    2: 'Kandungan',
    3: 'Anak',
    4: 'Spesialis Kulit',
    5: 'Penyakit Dalam',
    6: 'Jantung',
    7: 'Gigi',
    8: 'THT',
    9: 'Bedah',
    10: 'Mata',
    11: 'Lainnya',
  };

  // Fungsi untuk mendapatkan nama spesialis berdasarkan ID
  String _getSpesialisName(int spesialisId) {
    return _spesialisNames[spesialisId] ?? 'Spesialis $spesialisId';
  }

  void _onProductSelected(Product product) {
    setState(() {
      if (_selectedProducts.contains(product)) {
        // Hapus produk dan data terkait
        final index = _selectedProducts.indexOf(product);
        _selectedProducts.remove(product);
        _selectedProductNames.removeAt(index);

        // Tidak perlu menghapus divisi dan spesialis karena sudah diisi default
      } else {
        // Tambah produk dan data terkait
        _selectedProducts.add(product);
        _selectedProductNames.add(product.nama);
      }

      // Debug log
      Logger.debug(_tag,
          'Selected Products: ${_selectedProducts.map((p) => p.nama).toList()}');
      Logger.debug(_tag, 'Selected Product Names: $_selectedProductNames');
      Logger.debug(_tag, 'Selected Divisi IDs: $_selectedProductDivisiIds');
      Logger.debug(_tag, 'Selected Divisi Names: $_selectedDivisiNames');
      Logger.debug(
          _tag, 'Selected Spesialis IDs: $_selectedProductSpesialisIds');
      Logger.debug(_tag, 'Selected Spesialis Names: $_selectedSpesialisNames');
    });
  }

  @override
  void initState() {
    super.initState();
    _doctorSearchController.addListener(() {
      setState(() {
        _doctorSearchQuery = _doctorSearchController.text;
      });
    });
    _productSearchController.addListener(() {
      setState(() {
        _productSearchQuery = _productSearchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _noteController.dispose();
    _doctorSearchController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submitForm(int userId) {
    if (_formKey.currentState?.validate() ?? false) {
      // Validasi catatan
      if (_noteController.text.trim().isEmpty) {
        setState(() {
          _noteError = 'Catatan wajib diisi';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan isi catatan terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_noteController.text.trim().length < _minimumNoteCharacters) {
        setState(() {
          _noteError = 'Catatan minimal $_minimumNoteCharacters karakter';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan terlalu pendek'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_noteController.text.trim().length > _maximumNoteCharacters) {
        setState(() {
          _noteError = 'Catatan maksimal $_maximumNoteCharacters karakter';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan terlalu panjang'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedDoctor == null) {
        // Tampilkan pesan error jika dokter belum dipilih
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih dokter terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedScheduleType == null) {
        // Tampilkan pesan error jika tipe jadwal belum dipilih
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih tipe jadwal terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_tanggalController.text.isEmpty) {
        // Tampilkan pesan error jika tanggal belum dipilih
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih tanggal kunjungan'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Log debug informasi
      Logger.debug(_tag, 'Submitting form with data:');
      Logger.debug(_tag, '- Schedule Type: ${_selectedScheduleType?.nama}');
      Logger.debug(_tag, '- Doctor: ${_selectedDoctor?.nama}');
      Logger.debug(_tag, '- Date: ${_tanggalController.text}');
      Logger.debug(_tag, '- Shift: $_selectedShift');
      Logger.debug(_tag, '- Jenis: $_selectedJenis');
      Logger.debug(
          _tag, '- Products: ${_selectedProducts.map((p) => p.nama).toList()}');
      Logger.debug(_tag,
          '- Product IDs: ${_selectedProducts.map((p) => p.id).toList()}');
      Logger.debug(_tag, '- Divisi IDs: $_selectedProductDivisiIds');
      Logger.debug(_tag, '- Divisi Names: $_selectedDivisiNames');
      Logger.debug(_tag, '- Spesialis IDs: $_selectedProductSpesialisIds');
      Logger.debug(_tag, '- Spesialis Names: $_selectedSpesialisNames');
      Logger.debug(_tag, '- Notes: ${_noteController.text}');

      context.read<AddScheduleBloc>().add(
            SubmitScheduleEvent(
              typeSchedule: _selectedScheduleType!.id,
              tujuan: _selectedDestinationType,
              tglVisit: _tanggalController.text,
              product: _selectedProducts.map((p) => p.id).toList(),
              note: _noteController.text.trim(),
              idUser: userId,
              dokter: _selectedDoctor!.id!,
              klinik: _selectedDestinationType == 'klinik'
                  ? _selectedDoctor!.nama
                  : '',
              productForIdDivisi: _selectedProductDivisiIds,
              productForIdSpesialis: _selectedProductSpesialisIds,
              shift: _selectedShift,
              jenis: _selectedJenis,
              productNames: _selectedProductNames,
              divisiNames: _selectedDivisiNames,
              spesialisNames: _selectedSpesialisNames,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Tambah Jadwal',
        centerTitle: true,
        automaticallyImplyLeading: true,
        showShadow: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return BlocConsumer<AddScheduleBloc, AddScheduleState>(
              listener: (context, state) {
                if (state is AddScheduleSuccess) {
                  Navigator.pop(context, true);
                } else if (state is AddScheduleError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AddScheduleInitial) {
                  context.read<AddScheduleBloc>().add(
                        GetDoctorsAndClinicsEvent(
                          userId: authState.user.idUser,
                        ),
                      );
                  context.read<AddScheduleBloc>().add(GetScheduleTypesEvent());
                  context.read<AddScheduleBloc>().add(
                        GetProductsEvent(
                          userId: authState.user.idUser,
                        ),
                      );
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is AddScheduleLoading) {
                  return const ShimmerScheduleLoading();
                } else if (state is AddScheduleFormLoaded) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informasi Jadwal',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppDropdown<ScheduleType>(
                                  labelText: 'Tipe Jadwal',
                                  hintText: 'Pilih tipe jadwal',
                                  value: _selectedScheduleType,
                                  items: state.scheduleTypes
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type.nama),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedScheduleType = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Pilih tipe jadwal';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: _tanggalController,
                                  hintText: 'Pilih Tanggal',
                                  labelText: 'Tanggal',
                                  readOnly: true,
                                  onTap: () => _selectDate(context),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Pilih tanggal';
                                    }
                                    return null;
                                  },
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile(
                                        title: Text(
                                          'Pagi',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                          ),
                                        ),
                                        value: 'pagi',
                                        groupValue: _selectedShift,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedShift = value.toString();
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile(
                                        title: Text(
                                          'Sore',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                          ),
                                        ),
                                        value: 'sore',
                                        groupValue: _selectedShift,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedShift = value.toString();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tujuan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile(
                                        title: Text(
                                          'Dokter',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                          ),
                                        ),
                                        value: 'dokter',
                                        groupValue: _selectedDestinationType,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedDestinationType =
                                                value.toString();
                                            _selectedDoctor = null;
                                            _doctorSearchController.clear();
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile(
                                        title: Text(
                                          'Klinik',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                          ),
                                        ),
                                        value: 'klinik',
                                        groupValue: _selectedDestinationType,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedDestinationType =
                                                value.toString();
                                            _selectedDoctor = null;
                                            _doctorSearchController.clear();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: _doctorSearchController,
                                  hintText: _selectedDestinationType == 'dokter'
                                      ? 'Cari Dokter'
                                      : 'Cari Klinik',
                                  labelText:
                                      _selectedDestinationType == 'dokter'
                                          ? 'Cari Dokter'
                                          : 'Cari Klinik',
                                  onChanged: (value) {
                                    setState(() {
                                      _doctorSearchQuery = value.toLowerCase();
                                    });
                                  },
                                  suffixIcon: Icon(
                                    Icons.search,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_selectedDestinationType == 'dokter')
                                  _buildDoctorList(state.doctorsAndClinics)
                                else
                                  _buildClinicList(state.doctorsAndClinics),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Produk',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: _productSearchController,
                                  hintText: 'Cari Produk',
                                  labelText: 'Cari Produk',
                                  onChanged: (value) {
                                    setState(() {
                                      _productSearchQuery = value.toLowerCase();
                                    });
                                  },
                                  suffixIcon: Icon(
                                    Icons.search,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildProductList(state.products),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Catatan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: _noteController,
                                  hintText: 'Catatan Kunjungan',
                                  labelText: 'Catatan Kunjungan',
                                  maxLines: 4,
                                  errorText: _noteError,
                                  onChanged: (value) {
                                    setState(() {
                                      _noteError = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            text: 'Simpan',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (_selectedDoctor == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pilih dokter atau klinik'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                if (_selectedProducts.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Pilih minimal satu produk'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final note = _noteController.text;
                                if (note.length < _minimumNoteCharacters) {
                                  setState(() {
                                    _noteError =
                                        'Catatan minimal $_minimumNoteCharacters karakter';
                                  });
                                  return;
                                }

                                if (note.length > _maximumNoteCharacters) {
                                  setState(() {
                                    _noteError =
                                        'Catatan maksimal $_maximumNoteCharacters karakter';
                                  });
                                  return;
                                }

                                context.read<AddScheduleBloc>().add(
                                      SubmitScheduleEvent(
                                        typeSchedule: _selectedScheduleType!.id,
                                        tujuan: _selectedDestinationType,
                                        tglVisit: _tanggalController.text,
                                        product: _selectedProducts
                                            .map((p) => p.id)
                                            .toList(),
                                        note: note,
                                        idUser: authState.user.idUser,
                                        dokter: _selectedDoctor!.id,
                                        klinik:
                                            _selectedDestinationType == 'klinik'
                                                ? _selectedDoctor!.nama
                                                : '',
                                        productForIdDivisi:
                                            _selectedProductDivisiIds,
                                        productForIdSpesialis:
                                            _selectedProductSpesialisIds,
                                        shift: _selectedShift,
                                        jenis: _selectedJenis,
                                        productNames: _selectedProductNames,
                                        divisiNames: _selectedDivisiNames,
                                        spesialisNames: _selectedSpesialisNames,
                                      ),
                                    );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is AddScheduleError) {
                  return Center(
                    child: Text(state.message),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          }
          return const Center(
            child: Text('Silakan login terlebih dahulu'),
          );
        },
      ),
    );
  }

  Widget _buildDoctorList(List<DoctorClinic> doctors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredDoctors = doctors.where((doctor) {
      final searchQuery = _doctorSearchQuery.toLowerCase();
      return doctor.nama.toLowerCase().contains(searchQuery) ||
          (doctor.alamat ?? '').toLowerCase().contains(searchQuery);
    }).toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredDoctors.length,
        itemBuilder: (context, index) {
          final doctor = filteredDoctors[index];
          final isSelected = _selectedDoctor?.id == doctor.id;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context)
                      .primaryColor
                      .withOpacity(isDark ? 0.2 : 0.1)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? isDark
                        ? Colors.white
                        : Theme.of(context).primaryColor
                    : isDark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedDoctor = doctor;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withOpacity(isDark ? 0.2 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: isDark
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.nama,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (doctor.alamat != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                doctor.alamat!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: isDark
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClinicList(List<DoctorClinic> clinics) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredClinics = clinics.where((clinic) {
      final searchQuery = _doctorSearchQuery.toLowerCase();
      return clinic.nama.toLowerCase().contains(searchQuery) ||
          (clinic.alamat ?? '').toLowerCase().contains(searchQuery);
    }).toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredClinics.length,
        itemBuilder: (context, index) {
          final clinic = filteredClinics[index];
          final isSelected = _selectedDoctor?.id == clinic.id;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context)
                      .primaryColor
                      .withOpacity(isDark ? 0.2 : 0.1)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? isDark
                        ? Colors.white
                        : Theme.of(context).primaryColor
                    : isDark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedDoctor = clinic;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withOpacity(isDark ? 0.2 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_hospital,
                          color: isDark
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clinic.nama,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (clinic.alamat != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                clinic.alamat!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: isDark
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredProducts = products.where((product) {
      final searchQuery = _productSearchQuery.toLowerCase();
      return product.nama.toLowerCase().contains(searchQuery);
    }).toList();

    return Column(
      children: [
        // Selected Products Display
        if (_selectedProducts.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedProducts.map((product) {
              return Chip(
                label: Text(
                  product.nama,
                  style: TextStyle(
                    color:
                        isDark ? Colors.white : Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: Theme.of(context)
                    .primaryColor
                    .withOpacity(isDark ? 0.2 : 0.1),
                deleteIcon: Icon(
                  Icons.close,
                  size: 18,
                  color: isDark ? Colors.white : Theme.of(context).primaryColor,
                ),
                onDeleted: () => _onProductSelected(product),
                side: BorderSide(
                  color: isDark
                      ? Colors.white54
                      : Theme.of(context).primaryColor.withOpacity(0.5),
                  width: 1,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark ? Colors.white24 : Colors.grey[300],
          ),
          const SizedBox(height: 16),
        ],

        // Product List
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              final isSelected = _selectedProducts.contains(product);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context)
                          .primaryColor
                          .withOpacity(isDark ? 0.2 : 0.1)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? isDark
                            ? Colors.white
                            : Theme.of(context).primaryColor
                        : isDark
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onProductSelected(product),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(isDark ? 0.2 : 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.medical_services,
                              color: isDark
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.nama,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                if (product.kode != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kode: ${product.kode}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: isDark
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
