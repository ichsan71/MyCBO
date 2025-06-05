import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:test_cbo/core/presentation/widgets/app_button.dart';
import 'package:test_cbo/core/presentation/widgets/app_card.dart';
import 'package:test_cbo/core/presentation/widgets/app_dropdown.dart';
import 'package:test_cbo/core/presentation/widgets/app_text_field.dart';
import 'package:test_cbo/core/presentation/widgets/app_bar_widget.dart';
import 'package:test_cbo/core/di/injection_container.dart' as di;
import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_state.dart';
import 'package:test_cbo/features/schedule/data/models/doctor_clinic_model.dart'
    as model;
import 'package:test_cbo/features/schedule/data/models/doctor_model.dart';
import 'package:test_cbo/features/schedule/data/models/responses/doctor_response.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic_base.dart';
import 'package:test_cbo/features/schedule/domain/entities/product.dart';
import 'package:test_cbo/features/schedule/domain/entities/schedule_type.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_bloc.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_event.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_state.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_schedule_loading.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

class AddSchedulePage extends StatelessWidget {
  const AddSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AddScheduleBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<ScheduleBloc>(),
        ),
      ],
      child: const _AddScheduleView(),
    );
  }
}

class _AddScheduleView extends StatefulWidget {
  const _AddScheduleView();

  @override
  State<_AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<_AddScheduleView> {
  final _formKey = GlobalKey<FormState>();
  static const String _tag = 'AddSchedulePage';

  // Form controllers
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Konstanta untuk validasi catatan
  static const int _minimumNoteCharacters = 10;
  static const int _maximumNoteCharacters = 200;
  String? _noteError;

  // Selected values
  ScheduleType? _selectedScheduleType;
  DoctorClinicBase? _selectedDoctor;
  String _selectedShift = 'pagi';
  final String _selectedJenis = 'suddenly';
  final List<Product> _selectedProducts = [];
  final List<int> _selectedProductDivisiIds = [];
  final List<int> _selectedProductSpesialisIds = [];

  // Lists for doctors
  final List<DoctorClinicBase> doctors = [];
  final List<DoctorClinicBase> filteredDoctors = [];

  // Tambahkan variabel untuk menyimpan nama-nama
  final List<String> _selectedProductNames = [];
  final List<String> _selectedDivisiNames = [];
  final List<String> _selectedSpesialisNames = [];

  // Pilihan tujuan (dokter atau klinik)
  String _selectedDestinationType = 'dokter'; // Default: dokter

  // Search controllers
  final TextEditingController _productSearchController =
      TextEditingController();
  String _productSearchQuery = '';
  final TextEditingController _doctorSearchController = TextEditingController();
  String _doctorSearchQuery = '';

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

    // Pastikan data dimuat dengan segera saat widget dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _noteController.dispose();
    _productSearchController.dispose();
    _doctorSearchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      Logger.info(_tag, 'Memuat data untuk user ID: ${authState.user.idUser}');

      final bloc = context.read<AddScheduleBloc>();

      // Muat semua data secara bersamaan
      bloc.add(GetDoctorsAndClinicsEvent(userId: authState.user.idUser));
      bloc.add(GetProductsEvent(userId: authState.user.idUser));
      bloc.add(GetScheduleTypesEvent());
      bloc.add(GetDoctorsEvent());

      // Menambahkan data dummy untuk divisi dan spesialis saat produk dipilih
      _selectedProductDivisiIds.addAll([22, 23]);
      _selectedDivisiNames.addAll(['Divisi A', 'Divisi B']);

      _selectedProductSpesialisIds.addAll([18, 24]);
      _selectedSpesialisNames.addAll(['Spesialis X', 'Spesialis Y']);

      // Set timeout untuk memastikan produk selalu tersedia
      Future.delayed(const Duration(seconds: 5), () {
        // Cek apakah state masih loading atau belum ada produk
        if (bloc.state is AddScheduleLoading ||
            (bloc.state is AddScheduleFormLoaded &&
                (bloc.state as AddScheduleFormLoaded).products.isEmpty)) {
          Logger.warning(
              _tag, 'Timeout loading produk, menggunakan data dummy');

          if (mounted) {
            // Jangan gunakan emit, gunakan add untuk event
            bloc.add(GetProductsEvent(userId: authState.user.idUser));
          }
        }
      });
    }
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
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
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
              klinik: _selectedDoctor!.tipeKlinik ?? '',
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

    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Tambah Jadwal',
        elevation: 0,
        backgroundColor: null,
      ),
      body: BlocConsumer<AddScheduleBloc, AddScheduleState>(
        listener: (context, state) {
          if (state is AddScheduleSuccess) {
            // Tampilkan pesan sukses
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Jadwal berhasil ditambahkan'),
                backgroundColor: Colors.green,
              ),
            );

            // Kembali ke halaman jadwal dengan membawa data refresh = true
            Navigator.pop(context, true);
          } else if (state is AddScheduleError) {
            // Tampilkan pesan error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AddScheduleLoading) {
            return const ShimmerScheduleLoading();
          }

          // Build form if products and doctors are loaded
          if (state is AddScheduleFormLoaded ||
              state is ProductsLoaded ||
              state is DoctorsAndClinicsLoaded ||
              state is DoctorsLoaded ||
              state is ScheduleTypesLoaded) {
            List<Product> products = [];
            List<DoctorClinicBase> doctors = [];
            List<ScheduleType> scheduleTypes = [];
            DoctorResponse? doctorResponse;

            if (state is AddScheduleFormLoaded) {
              products = state.products;
              // Convert DoctorClinic to DoctorClinicBase
              doctors.addAll(
                  state.doctorsAndClinics.map((doctor) => DoctorClinicBase(
                        id: doctor.id,
                        nama: doctor.nama,
                        spesialis: doctor.spesialis,
                        alamat: doctor.alamat,
                        noTelp: doctor.noTelp,
                        email: doctor.email,
                        tipeDokter: doctor.tipeDokter,
                        tipeKlinik: doctor.tipeKlinik,
                        kodeRayon: doctor.kodeRayon,
                      )));
              scheduleTypes = state.scheduleTypes;
              doctorResponse = state.doctorResponse;
            } else if (state is ProductsLoaded) {
              products = state.products;
            } else if (state is DoctorsAndClinicsLoaded) {
              // Convert DoctorClinic to DoctorClinicBase
              doctors.addAll(
                  state.doctorsAndClinics.map((doctor) => DoctorClinicBase(
                        id: doctor.id,
                        nama: doctor.nama,
                        spesialis: doctor.spesialis,
                        alamat: doctor.alamat,
                        noTelp: doctor.noTelp,
                        email: doctor.email,
                        tipeDokter: doctor.tipeDokter,
                        tipeKlinik: doctor.tipeKlinik,
                        kodeRayon: doctor.kodeRayon,
                      )));
            } else if (state is DoctorsLoaded) {
              doctorResponse = state.doctorResponse;
            } else if (state is ScheduleTypesLoaded) {
              scheduleTypes = state.scheduleTypes;
            }

            // Filter doctors by search query
            final filteredDoctors = doctors.where((doctor) {
              // Filter dokter yang valid (tidak kosong atau null)
              if (doctor == null) return false;
              return doctor.id > 0 &&
                  doctor.nama.trim().isNotEmpty &&
                  doctor.nama
                      .toLowerCase()
                      .contains(_doctorSearchQuery.toLowerCase());
            }).toList();

            // Log dokter dari API untuk debugging
            if (doctorResponse != null && doctorResponse.dokter.isNotEmpty) {
              Logger.info(_tag, 'Dokter dari API:');
              for (var doctor in doctorResponse.dokter) {
                Logger.info(_tag,
                    '- ID: ${doctor.id}, Nama: ${doctor.nama}, Spesialis: ${doctor.spesialis} (${_getSpesialisName(doctor.spesialis)})');
              }

              // Konversi DoctorModel ke DoctorClinicBase untuk ditampilkan di ListView
              for (var doctor in doctorResponse.dokter) {
                // Skip dokter jika id atau nama kosong
                if (doctor.id <= 0 || doctor.nama.isEmpty) {
                  Logger.warning(_tag,
                      'Melewati dokter dengan data tidak valid: ${doctor.id} - ${doctor.nama}');
                  continue;
                }

                // Buat DoctorClinicBase dari DoctorModel
                final doctorClinic = DoctorClinicBase(
                  id: doctor.id,
                  nama: doctor.nama,
                  spesialis: _getSpesialisName(doctor.spesialis),
                );

                // Tambahkan ke daftar dokter untuk ditampilkan
                if (!doctors.any((d) => d.id == doctor.id)) {
                  doctors.add(doctorClinic);
                }
              }

              // Filter ulang setelah menambahkan dokter dari API
              filteredDoctors.clear();
              filteredDoctors.addAll(doctors.where((doctor) {
                if (doctor == null) return false;
                return doctor.id > 0 &&
                    doctor.nama.isNotEmpty &&
                    doctor.nama
                        .toLowerCase()
                        .contains(_doctorSearchQuery.toLowerCase());
              }).toList());
            }

            // Gabungkan dokter dari kedua sumber data jika tersedia
            List<DropdownMenuItem<DoctorClinicBase>> doctorItems = [];

            // Tambahkan item dari DoctorClinic
            doctorItems.addAll(filteredDoctors
                .map((doctor) => DropdownMenuItem<DoctorClinicBase>(
                      value: doctor,
                      child: Text(doctor.nama),
                    ))
                .toList());

            // Tambahkan dokter dari API jika tersedia
            if (doctorResponse != null && doctorResponse.dokter.isNotEmpty) {
              doctorItems.addAll(doctorResponse.dokter
                  .where((doctor) => doctor.id > 0 && doctor.nama.isNotEmpty)
                  .map((doctor) {
                final doctorClinic = DoctorClinicBase(
                  id: doctor.id,
                  nama: doctor.nama,
                  spesialis: _getSpesialisName(doctor.spesialis),
                );
                return DropdownMenuItem<DoctorClinicBase>(
                  value: doctorClinic,
                  child: Text(doctor.nama),
                );
              }).toList());
            }

            // Filter products by search query
            final filteredProducts = products.where((product) {
              return product.nama
                  .toLowerCase()
                  .contains(_productSearchQuery.toLowerCase());
            }).toList();

            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Form Header
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
                                const Divider(height: 30),

                                // Jadwal Type Dropdown
                                if (scheduleTypes.isNotEmpty)
                                  AppDropdown<ScheduleType>(
                                    hintText: 'Pilih Tipe Jadwal',
                                    labelText: 'Tipe Jadwal',
                                    value: _selectedScheduleType,
                                    items: scheduleTypes
                                        .map((type) =>
                                            DropdownMenuItem<ScheduleType>(
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
                                        return 'Tipe jadwal harus dipilih';
                                      }
                                      return null;
                                    },
                                  ),
                                const SizedBox(height: 16),

                                // Date Picker
                                AppTextField(
                                  controller: _tanggalController,
                                  hintText: 'Pilih Tanggal',
                                  labelText: 'Tanggal',
                                  readOnly: true,
                                  onTap: () => _selectDate(context),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Tanggal harus diisi';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Shift Selection
                                Text(
                                  'Shift',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  children: [
                                    RadioListTile<String>(
                                      title: const Text('Pagi'),
                                      value: 'pagi',
                                      groupValue: _selectedShift,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedShift = value!;
                                        });
                                      },
                                    ),
                                    RadioListTile<String>(
                                      title: const Text('Sore'),
                                      value: 'sore',
                                      groupValue: _selectedShift,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedShift = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Doctor Selection
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
                                      Icons.person,
                                      color: AppTheme.scheduleIconColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Tujuan',
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.scheduleHeaderColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 30),

                                // Destination Type Selection
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RadioListTile<String>(
                                      title: const Text('Dokter'),
                                      value: 'dokter',
                                      groupValue: _selectedDestinationType,
                                      contentPadding: EdgeInsets.zero,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedDestinationType = value!;
                                          _selectedDoctor = null;
                                        });
                                      },
                                    ),
                                    RadioListTile<String>(
                                      title: const Text('Klinik'),
                                      value: 'klinik',
                                      groupValue: _selectedDestinationType,
                                      contentPadding: EdgeInsets.zero,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedDestinationType = value!;
                                          _selectedDoctor = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                if (_selectedDestinationType == 'dokter') ...[
                                  // Doctor Selection (when destination is doctor)
                                  AppCard(
                                    elevation: 2,
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: theme.colorScheme.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Pilih Dokter',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: _doctorSearchController,
                                          decoration: InputDecoration(
                                            hintText: 'Cari dokter...',
                                            prefixIcon:
                                                const Icon(Icons.search),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _doctorSearchQuery = value;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        // Tampilan daftar dokter dalam bentuk list
                                        if (filteredDoctors.isEmpty)
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300]!
                                                  .withAlpha(
                                                      (0.3 * 255).round()),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.black.withAlpha(
                                                    (0.03 * 255).round()),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.info,
                                                  color: Colors.black.withAlpha(
                                                      (0.03 * 255).round()),
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    doctors.isEmpty
                                                        ? 'Tidak ada data dokter yang tersedia. Harap pastikan koneksi internet Anda stabil dan coba lagi.'
                                                        : 'Tidak ada dokter yang sesuai dengan pencarian.',
                                                    style: TextStyle(
                                                      color: Colors.black
                                                          .withAlpha(
                                                              (0.03 * 255)
                                                                  .round()),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Pilih Dokter (${filteredDoctors.length} dokter ditemukan)',
                                                style:
                                                    theme.textTheme.bodyMedium,
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxHeight: 300),
                                                decoration: BoxDecoration(
                                                  color: theme.primaryColor
                                                      .withAlpha(
                                                          (0.1 * 255).round()),
                                                  border: Border.all(
                                                    color: Colors.grey[400]!
                                                        .withAlpha((0.5 * 255)
                                                            .round()),
                                                    width: 1.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withAlpha(
                                                              (0.05 * 255)
                                                                  .round()),
                                                      blurRadius: 5,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: ListView.separated(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        filteredDoctors.length,
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            Divider(
                                                      height: 1,
                                                      thickness: 1,
                                                      color: Colors.grey[400]!
                                                          .withAlpha((0.5 * 255)
                                                              .round()),
                                                    ),
                                                    itemBuilder:
                                                        (context, index) {
                                                      final doctor =
                                                          filteredDoctors[
                                                              index];
                                                      final isSelected =
                                                          _selectedDoctor ==
                                                              doctor;

                                                      return InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedDoctor =
                                                                doctor;
                                                          });
                                                          Logger.debug(_tag,
                                                              'Dokter dipilih: ${doctor.nama}');
                                                        },
                                                        child: Container(
                                                          color: isSelected
                                                              ? AppTheme
                                                                  .scheduleSelectedItemColor
                                                              : AppTheme
                                                                  .scheduleCardColor,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical: 12,
                                                            horizontal: 16,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              CircleAvatar(
                                                                backgroundColor: isSelected
                                                                    ? AppTheme
                                                                        .scheduleHighlightColor
                                                                        .withOpacity(
                                                                            0.1)
                                                                    : AppTheme
                                                                        .scheduleBackgroundColor,
                                                                child: Icon(
                                                                  Icons.person,
                                                                  color: isSelected
                                                                      ? AppTheme
                                                                          .scheduleHighlightColor
                                                                      : AppTheme
                                                                          .scheduleIconColor,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 16),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      doctor
                                                                          .nama!,
                                                                      style: theme
                                                                          .textTheme
                                                                          .titleMedium
                                                                          ?.copyWith(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: isSelected
                                                                            ? AppTheme.scheduleHighlightColor
                                                                            : AppTheme.scheduleTextColor,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              if (isSelected)
                                                                Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: AppTheme
                                                                      .scheduleHighlightColor,
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  // Klinik placeholder: future implementation
                                  const Center(
                                    child: Text(
                                        'Fitur pemilihan klinik akan segera hadir'),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Product Selection
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
                                      Icons.shopping_bag,
                                      color: AppTheme.scheduleIconColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Produk',
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.scheduleHeaderColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 30),

                                // Product Search
                                AppTextField(
                                  controller: _productSearchController,
                                  hintText: 'Cari Produk',
                                  prefixIcon: const Icon(Icons.search),
                                  onChanged: (value) {
                                    setState(() {
                                      _productSearchQuery = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Selected Products
                                if (_selectedProducts.isNotEmpty) ...[
                                  Text(
                                    'Produk Terpilih',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _selectedProducts
                                        .map(
                                          (product) => Chip(
                                            label: Text(product.nama),
                                            deleteIcon: Icon(
                                              Icons.close,
                                              size: 18,
                                              color: AppTheme
                                                  .scheduleHighlightColor,
                                            ),
                                            onDeleted: () =>
                                                _onProductSelected(product),
                                            backgroundColor: AppTheme
                                                .scheduleSelectedItemColor,
                                            labelStyle: TextStyle(
                                                color: AppTheme
                                                    .scheduleHighlightColor,
                                                fontWeight: FontWeight.w500),
                                            side: BorderSide(
                                              color: AppTheme
                                                  .scheduleHighlightColor
                                                  .withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Product List
                                if (filteredProducts.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300]!
                                          .withAlpha((0.3 * 255).round()),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.black
                                            .withAlpha((0.03 * 255).round()),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info,
                                          color: Colors.black
                                              .withAlpha((0.03 * 255).round()),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            products.isEmpty
                                                ? 'Tidak ada data produk yang tersedia. Harap pastikan koneksi internet Anda stabil dan coba lagi.'
                                                : 'Tidak ada produk yang sesuai dengan pencarian.',
                                            style: TextStyle(
                                              color: Colors.black.withAlpha(
                                                  (0.03 * 255).round()),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 300),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor
                                          .withAlpha((0.1 * 255).round()),
                                      border: Border.all(
                                        color: Colors.grey[400]!
                                            .withAlpha((0.5 * 255).round()),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withAlpha((0.05 * 255).round()),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: filteredProducts.length,
                                        separatorBuilder: (context, index) =>
                                            Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Colors.grey[400]!
                                              .withAlpha((0.5 * 255).round()),
                                        ),
                                        itemBuilder: (context, index) {
                                          final product =
                                              filteredProducts[index];
                                          final isSelected = _selectedProducts
                                              .contains(product);

                                          return InkWell(
                                            onTap: () =>
                                                _onProductSelected(product),
                                            child: Container(
                                              color: isSelected
                                                  ? AppTheme
                                                      .scheduleSelectedItemColor
                                                  : AppTheme.scheduleCardColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                                horizontal: 16,
                                              ),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor: isSelected
                                                        ? AppTheme
                                                            .scheduleHighlightColor
                                                            .withOpacity(0.1)
                                                        : AppTheme
                                                            .scheduleBackgroundColor,
                                                    child: Icon(
                                                      Icons.medical_services,
                                                      color: isSelected
                                                          ? AppTheme
                                                              .scheduleHighlightColor
                                                          : AppTheme
                                                              .scheduleIconColor,
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
                                                          product.nama,
                                                          style: theme.textTheme
                                                              .titleMedium
                                                              ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: isSelected
                                                                ? AppTheme
                                                                    .scheduleHighlightColor
                                                                : AppTheme
                                                                    .scheduleTextColor,
                                                          ),
                                                        ),
                                                        if (product.keterangan
                                                            .isNotEmpty)
                                                          Text(
                                                            product.keterangan,
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                              color: AppTheme
                                                                  .scheduleSubtextColor,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
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
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Notes
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
                                      Icons.note,
                                      color: AppTheme.scheduleIconColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Catatan',
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.scheduleHeaderColor,
                                      ),
                                    ),
                                    const Text(
                                      ' *',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 30),
                                AppTextField(
                                  controller: _noteController,
                                  hintText:
                                      'Tulis catatan kunjungan (minimal $_minimumNoteCharacters karakter)',
                                  maxLines: 5,
                                  keyboardType: TextInputType.multiline,
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
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Catatan wajib diisi';
                                    }
                                    if (value.trim().length <
                                        _minimumNoteCharacters) {
                                      return 'Catatan minimal $_minimumNoteCharacters karakter';
                                    }
                                    if (value.trim().length >
                                        _maximumNoteCharacters) {
                                      return 'Catatan maksimal $_maximumNoteCharacters karakter';
                                    }
                                    return null;
                                  },
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.all(16),
                                  suffixIcon: _noteController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            setState(() {
                                              _noteController.clear();
                                              _noteError =
                                                  'Catatan wajib diisi';
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                if (_noteError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline,
                                            color: Colors.red.shade700,
                                            size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          _noteError!,
                                          style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Tambahkan counter karakter
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Karakter: ${_noteController.text.length}/$_maximumNoteCharacters',
                                    style: TextStyle(
                                      color: _noteController.text.length >
                                              _maximumNoteCharacters
                                          ? Colors.red.shade700
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: AppButton(
                              text: 'Simpan Jadwal',
                              onPressed: () =>
                                  _submitForm(authState.user.idUser),
                              isFullWidth: true,
                              isLoading: state is AddScheduleLoading,
                              type: AppButtonType.primary,
                              prefixIcon: const Icon(Icons.add, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const Center(
                    child:
                        Text('Anda harus login untuk mengakses halaman ini'));
              },
            );
          }

          return const Center(child: Text('Gagal memuat data jadwal'));
        },
      ),
    );
  }
}
