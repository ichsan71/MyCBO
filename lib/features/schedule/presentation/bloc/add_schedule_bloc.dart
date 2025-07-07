import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:test_cbo/core/usecases/usecase.dart';
import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic_base.dart';
import 'package:test_cbo/features/schedule/domain/entities/product.dart';
import 'package:test_cbo/features/schedule/domain/entities/schedule_type.dart';
import 'package:test_cbo/features/schedule/domain/usecases/add_schedule.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_doctors.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_doctors_and_clinics.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_filtered_daily_schedule.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_products.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_schedule_types.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_event.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_state.dart';

class AddScheduleBloc extends Bloc<AddScheduleEvent, AddScheduleState> {
  final GetDoctorsAndClinics getDoctorsAndClinics;
  final GetScheduleTypes getScheduleTypes;
  final GetProducts getProducts;
  final GetDoctors getDoctors;
  final AddSchedule addSchedule;
  final GetFilteredDailySchedule getFilteredDailySchedule;

  static const String _tag = 'AddScheduleBloc';

  // Constant untuk batasan
  // TODO: Re-enable when suddenly limit validation is ready for deployment
  // static const int _maxSuddenlyPerDay = 4;

  List<DoctorClinicBase> _doctorsAndClinics = [];
  List<ScheduleType> _scheduleTypes = [];
  List<Product> _products = [];
  String _currentDate = '';
  // TODO: Re-enable when suddenly limit validation is ready for deployment
  // bool _isSuddenlyLimitReached = false;
  // int _suddenlyCount = 0;

  AddScheduleBloc({
    required this.getDoctorsAndClinics,
    required this.getScheduleTypes,
    required this.getProducts,
    required this.getDoctors,
    required this.addSchedule,
    required this.getFilteredDailySchedule,
  }) : super(const AddScheduleInitial()) {
    on<GetDoctorsAndClinicsEvent>(_onGetDoctorsAndClinics);
    on<GetScheduleTypesEvent>(_onGetScheduleTypes);
    on<GetProductsEvent>(_onGetProducts);
    on<SubmitScheduleEvent>(_onSubmitSchedule);
    // TODO: Re-enable when suddenly limit validation is ready for deployment
    // on<CheckDailyScheduleEvent>(_onCheckDailySchedule);
    // on<DateChangedEvent>(_onDateChanged);
  }

  Future<void> _onGetDoctorsAndClinics(
    GetDoctorsAndClinicsEvent event,
    Emitter<AddScheduleState> emit,
  ) async {
    try {
      final result = await getDoctorsAndClinics(
        Params(userId: int.parse(event.userId)),
      );

      await result.fold(
        (failure) async {
          Logger.error(_tag, 'Gagal mendapatkan dokter: ${failure.message}');
          emit(AddScheduleError(message: failure.message));
        },
        (doctorsAndClinics) async {
          Logger.success(
              _tag, 'Berhasil mendapatkan ${doctorsAndClinics.length} dokter');
          _doctorsAndClinics = doctorsAndClinics;
          emit(DoctorsAndClinicsLoaded(doctorsAndClinics: doctorsAndClinics));
          _checkFormDataLoaded(emit);
        },
      );
    } catch (e) {
      Logger.error(_tag, 'Error tidak tertangani: $e');
      emit(const AddScheduleError(
          message: 'Terjadi kesalahan saat mengambil data dokter'));
      _checkFormDataLoaded(emit);
    }
  }

  Future<void> _onGetScheduleTypes(
    GetScheduleTypesEvent event,
    Emitter<AddScheduleState> emit,
  ) async {
    try {
      final result = await getScheduleTypes(NoParams());

      await result.fold(
        (failure) async {
          Logger.error(
              _tag, 'Gagal mendapatkan tipe jadwal: ${failure.message}');
          emit(AddScheduleError(message: failure.message));
        },
        (scheduleTypes) async {
          Logger.success(
              _tag, 'Berhasil mendapatkan ${scheduleTypes.length} tipe jadwal');
          _scheduleTypes = scheduleTypes;
          emit(ScheduleTypesLoaded(scheduleTypes: scheduleTypes));
          _checkFormDataLoaded(emit);
        },
      );
    } catch (e) {
      Logger.error(_tag, 'Error tidak tertangani: $e');
      emit(const AddScheduleError(
          message: 'Terjadi kesalahan saat mengambil tipe jadwal'));
      _checkFormDataLoaded(emit);
    }
  }

  Future<void> _onGetProducts(
    GetProductsEvent event,
    Emitter<AddScheduleState> emit,
  ) async {
    try {
      final result = await getProducts(
        ProductParams(userId: int.parse(event.userId)),
      );

      await result.fold(
        (failure) async {
          Logger.error(_tag, 'Gagal mendapatkan produk: ${failure.message}');
          emit(AddScheduleError(message: failure.message));
        },
        (products) async {
          Logger.success(
              _tag, 'Berhasil mendapatkan ${products.length} produk');
          _products = products;
          emit(ProductsLoaded(products: products));
          _checkFormDataLoaded(emit);
        },
      );
    } catch (e) {
      Logger.error(_tag, 'Error tidak tertangani: $e');
      emit(const AddScheduleError(
          message: 'Terjadi kesalahan saat mengambil data produk'));
      _checkFormDataLoaded(emit);
    }
  }

  void _checkFormDataLoaded(Emitter<AddScheduleState> emit) {
    Logger.debug(_tag, 'Memeriksa apakah semua data form sudah dimuat');
    Logger.debug(_tag,
        'Dokter & Klinik: ${_doctorsAndClinics.length}, Tipe Jadwal: ${_scheduleTypes.length}, Produk: ${_products.length}');

    if (_doctorsAndClinics.isNotEmpty &&
        _scheduleTypes.isNotEmpty &&
        _products.isNotEmpty) {
      Logger.info(_tag, 'Semua data form telah dimuat');
      emit(AddScheduleFormLoaded(
        doctorsAndClinics: _doctorsAndClinics,
        scheduleTypes: _scheduleTypes,
        products: _products,
        isSuddenlyLimitReached:
            false, // Always false when suddenly limit is commented out
        suddenlyCount: 0, // Always 0 when suddenly limit is commented out
        selectedDate: _currentDate,
      ));
    } else {
      Logger.warning(_tag, 'Beberapa data form masih belum dimuat');
    }
  }

  // TODO: Re-enable when suddenly limit validation is ready for deployment
  // Future<void> _onCheckDailySchedule(
  //   CheckDailyScheduleEvent event,
  //   Emitter<AddScheduleState> emit,
  // ) async {
  //   _currentDate = event.date;

  //   emit(DailyScheduleValidationLoading(date: event.date));

  //   try {
  //     final result = await getFilteredDailySchedule(
  //       FilterDailyScheduleParams(
  //         userId: int.parse(event.userId),
  //         date: event.date,
  //       ),
  //     );

  //     await result.fold(
  //       (failure) async {
  //         Logger.error(
  //             _tag, 'Gagal mendapatkan jadwal harian: ${failure.message}');
  //         // _isSuddenlyLimitReached = false;
  //         // _suddenlyCount = 0;

  //         if (state is AddScheduleFormLoaded) {
  //           final currentState = state as AddScheduleFormLoaded;
  //           emit(currentState.copyWith(
  //             isSuddenlyLimitReached: false,
  //             suddenlyCount: 0,
  //             selectedDate: event.date,
  //           ));
  //         }
  //       },
  //       (schedules) async {
  //         Logger.success(
  //             _tag, 'Berhasil mendapatkan ${schedules.length} jadwal harian');

  //         // Hitung jumlah jadwal dengan jenis "suddenly"
  //         // final suddenlySchedules = schedules
  //         //     .where((schedule) => schedule.jenis == 'suddenly')
  //         //     .toList();
  //         // _suddenlyCount = suddenlySchedules.length;
  //         // _isSuddenlyLimitReached = _suddenlyCount >= _maxSuddenlyPerDay;

  //         Logger.info(_tag,
  //             'Jumlah jadwal suddenly: 0, limit tercapai: false (suddenly limit commented out)');

  //         if (state is AddScheduleFormLoaded) {
  //           final currentState = state as AddScheduleFormLoaded;
  //           emit(currentState.copyWith(
  //             isSuddenlyLimitReached: false,
  //             suddenlyCount: 0,
  //             selectedDate: event.date,
  //           ));
  //         } else if (_doctorsAndClinics.isNotEmpty &&
  //             _scheduleTypes.isNotEmpty &&
  //             _products.isNotEmpty) {
  //           emit(AddScheduleFormLoaded(
  //             doctorsAndClinics: _doctorsAndClinics,
  //             scheduleTypes: _scheduleTypes,
  //             products: _products,
  //             isSuddenlyLimitReached: false,
  //             suddenlyCount: 0,
  //             selectedDate: event.date,
  //           ));
  //         }
  //       },
  //     );
  //   } catch (e) {
  //     Logger.error(_tag, 'Error saat memeriksa jadwal harian: $e');
  //     // _isSuddenlyLimitReached = false;
  //     // _suddenlyCount = 0;

  //     if (state is AddScheduleFormLoaded) {
  //       final currentState = state as AddScheduleFormLoaded;
  //       emit(currentState.copyWith(
  //         isSuddenlyLimitReached: false,
  //         suddenlyCount: 0,
  //         selectedDate: event.date,
  //       ));
  //     }
  //   }
  // }

  // Future<void> _onDateChanged(
  //   DateChangedEvent event,
  //   Emitter<AddScheduleState> emit,
  // ) async {
  //   await _onCheckDailySchedule(
  //     CheckDailyScheduleEvent(
  //       userId: event.userId,
  //       date: event.date,
  //     ),
  //     emit,
  //   );
  // }

  Future<void> _onSubmitSchedule(
    SubmitScheduleEvent event,
    Emitter<AddScheduleState> emit,
  ) async {
    try {
      // Validate required fields
      if (event.typeSchedule.isEmpty ||
          event.tujuan.isEmpty ||
          event.tglVisit.isEmpty ||
          event.product.isEmpty ||
          event.idUser.isEmpty ||
          event.dokter.isEmpty) {
        throw const FormatException('Semua field wajib harus diisi');
      }

      // Parse and format the date
      final inputFormat = DateFormat('dd/MM/yyyy');
      final outputFormat = DateFormat('yyyy-MM-dd');
      final date = inputFormat.parse(event.tglVisit);
      final formattedDate = outputFormat.format(date);

      // Log the request data
      Logger.debug(_tag, '''
Data yang akan dikirim:
- Type Schedule: ${event.typeSchedule}
- Tujuan: ${event.tujuan}
- Tanggal Visit: $formattedDate (original: ${event.tglVisit})
- Product: ${event.product}
- Note: ${event.note}
- ID User: ${event.idUser}
- Dokter: ${event.dokter}
- Klinik: ${event.klinik}
- Product For ID Divisi: ${event.productForIdDivisi}
- Product For ID Spesialis: ${event.productForIdSpesialis}
- Shift: ${event.shift}
- Jenis: ${event.jenis}
''');

      final result = await addSchedule(AddScheduleParams(
        typeSchedule: int.parse(event.typeSchedule),
        tujuan: event.tujuan,
        tglVisit: formattedDate,
        product: event.product.map((p) => int.parse(p)).toList(),
        note: event.note,
        idUser: int.parse(event.idUser),
        dokter: int.parse(event.dokter),
        klinik: event.klinik,
        productForIdDivisi:
            event.productForIdDivisi.map((id) => int.parse(id)).toList(),
        productForIdSpesialis:
            event.productForIdSpesialis.map((id) => int.parse(id)).toList(),
        shift: event.shift,
        jenis: event.jenis,
        productNames: event.productNames,
        divisiNames: event.divisiNames,
        spesialisNames: event.spesialisNames,
      ));

      await result.fold(
        (failure) async {
          Logger.error(_tag, 'Gagal menambahkan jadwal: ${failure.message}');
          emit(AddScheduleError(message: failure.message));
        },
        (success) async {
          Logger.success(_tag, 'Berhasil menambahkan jadwal');
          emit(const AddScheduleSuccess());
        },
      );
    } on FormatException catch (e) {
      Logger.error(_tag, 'Format error: ${e.message}');
      emit(AddScheduleError(message: e.message));
    } catch (e) {
      Logger.error(_tag, 'Error tidak tertangani: $e');
      emit(const AddScheduleError(
          message: 'Terjadi kesalahan saat menambahkan jadwal'));
    }
  }
}
