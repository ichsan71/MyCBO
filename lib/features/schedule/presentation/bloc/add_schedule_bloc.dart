import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cbo/core/usecases/usecase.dart';
import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/data/models/responses/doctor_response.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic.dart';
import 'package:test_cbo/features/schedule/domain/entities/product.dart';
import 'package:test_cbo/features/schedule/domain/entities/schedule_type.dart';
import 'package:test_cbo/features/schedule/domain/usecases/add_schedule.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_doctors.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_doctors_and_clinics.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_products.dart';
import 'package:test_cbo/features/schedule/domain/usecases/get_schedule_types.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_event.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_state.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/core/error/exceptions.dart';

class AddScheduleBloc extends Bloc<AddScheduleEvent, AddScheduleState> {
  final GetDoctorsAndClinics getDoctorsAndClinics;
  final GetScheduleTypes getScheduleTypes;
  final GetProducts getProducts;
  final GetDoctors getDoctors;
  final AddSchedule addSchedule;

  static const String _tag = 'AddScheduleBloc';

  List<DoctorClinic> _doctorsAndClinics = [];
  List<ScheduleType> _scheduleTypes = [];
  List<Product> _products = [];
  DoctorResponse? _doctorResponse;

  AddScheduleBloc({
    required this.getDoctorsAndClinics,
    required this.getScheduleTypes,
    required this.getProducts,
    required this.getDoctors,
    required this.addSchedule,
  }) : super(AddScheduleInitial()) {
    on<GetDoctorsAndClinicsEvent>(_onGetDoctorsAndClinics);
    on<GetScheduleTypesEvent>(_onGetScheduleTypes);
    on<GetProductsEvent>(_onGetProducts);
    on<GetDoctorsEvent>(_onGetDoctors);
    on<SubmitScheduleEvent>(_onSubmitSchedule);
  }

  Future<void> _onGetDoctorsAndClinics(
    GetDoctorsAndClinicsEvent event,
    Emitter<AddScheduleState> emit,
  ) async {
    Logger.info(_tag,
        'Memulai GetDoctorsAndClinicsEvent dengan userId: ${event.userId}');
    emit(AddScheduleLoading());

    try {
      final result = await getDoctorsAndClinics(Params(userId: event.userId));
      result.fold(
        (failure) {
          Logger.error(_tag,
              'Gagal mendapatkan dokter dan klinik: ${failure.toString()}');
          if (failure is ServerFailure) {
            emit(AddScheduleError(message: failure.message));
          } else if (failure is NetworkFailure) {
            emit(AddScheduleError(message: failure.message));
          } else {
            emit(const AddScheduleError(
                message:
                    'Terjadi kesalahan saat mengambil data dokter dan klinik'));
          }
        },
        (doctorsAndClinics) {
          Logger.success(_tag,
              'Berhasil mendapatkan ${doctorsAndClinics.length} dokter dan klinik');
          _doctorsAndClinics = doctorsAndClinics;
          emit(DoctorsAndClinicsLoaded(doctorsAndClinics: doctorsAndClinics));
          _checkFormDataLoaded(emit);
        },
      );
    } catch (e) {
      Logger.error(
          _tag, 'Error tidak tertangani di _onGetDoctorsAndClinics', e);
      emit(AddScheduleError(message: 'Terjadi kesalahan tidak terduga: $e'));
    }
  }

  Future<void> _onGetScheduleTypes(
    GetScheduleTypesEvent event,
    Emitter<AddScheduleState> emit,
  ) async {
    Logger.info(_tag, 'Memulai GetScheduleTypesEvent');
    emit(AddScheduleLoading());

    try {
      final result = await getScheduleTypes(NoParams());
      result.fold(
        (failure) {
          Logger.error(
              _tag, 'Gagal mendapatkan tipe jadwal: ${failure.toString()}');
          if (failure is ServerFailure) {
            emit(AddScheduleError(message: failure.message));
          } else if (failure is NetworkFailure) {
            emit(AddScheduleError(message: failure.message));
          } else {
            emit(const AddScheduleError(
                message: 'Terjadi kesalahan saat mengambil data tipe jadwal'));
          }
        },
        (scheduleTypes) {
          Logger.success(
              _tag, 'Berhasil mendapatkan ${scheduleTypes.length} tipe jadwal');
          _scheduleTypes = scheduleTypes;
          emit(ScheduleTypesLoaded(scheduleTypes: scheduleTypes));
          _checkFormDataLoaded(emit);
        },
      );
    } catch (e) {
      Logger.error(_tag, 'Error tidak tertangani di _onGetScheduleTypes', e);
      emit(AddScheduleError(message: 'Terjadi kesalahan tidak terduga: $e'));
    }
  }

  Future<void> _onGetProducts(
    GetProductsEvent event,
    Emitter<AddScheduleState> emit,
  ) async {
    try {
      Logger.info(_tag, 'Memulai GetProductsEvent');
      emit(AddScheduleLoading());

      final result = await getProducts(ProductParams(userId: event.userId));

      result.fold(
        (failure) {
          Logger.error(_tag, 'Gagal memuat produk - $failure');

          // Jika gagal mendapatkan produk, tetap gunakan produk sebelumnya jika ada
          if (_products.isNotEmpty) {
            Logger.warning(
                _tag, 'Menggunakan ${_products.length} produk dari cache');
            emit(ProductsLoaded(products: _products));
            _checkFormDataLoaded(emit);
          } else {
            emit(AddScheduleError(message: failure.toString()));
          }
        },
        (products) {
          if (products.isNotEmpty) {
            Logger.success(_tag, 'Berhasil memuat ${products.length} produk');

            // Simpan produk di variabel _products
            _products = products;

            // Emit state dengan produk baru
            emit(ProductsLoaded(products: products));

            // Check jika semua form data sudah dimuat
            _checkFormDataLoaded(emit);
          } else {
            Logger.warning(_tag, 'Tidak ada produk ditemukan');
            emit(const AddScheduleError(message: 'Tidak ada produk tersedia'));
          }
        },
      );
    } catch (e) {
      Logger.error(_tag, 'Error dalam GetProductsEvent', e);
      emit(AddScheduleError(message: e.toString()));
    }
  }

  Future<void> _onGetDoctors(
    GetDoctorsEvent event,
    Emitter<AddScheduleState> emit,
  ) async {
    Logger.info(_tag, 'Memulai GetDoctorsEvent');
    emit(AddScheduleLoading());

    try {
      final result = await getDoctors(NoParams());
      result.fold(
        (failure) {
          Logger.error(_tag, 'Gagal mendapatkan dokter: ${failure.toString()}');
          if (failure is ServerFailure) {
            emit(AddScheduleError(message: failure.message));
          } else if (failure is NetworkFailure) {
            emit(AddScheduleError(message: failure.message));
          } else {
            emit(const AddScheduleError(
                message: 'Terjadi kesalahan saat mengambil data dokter'));
          }

          // Tetap panggil _checkFormDataLoaded untuk membuat UI dapat ditampilkan
          _checkFormDataLoaded(emit);
        },
        (doctorResponse) {
          Logger.success(_tag,
              'Berhasil mendapatkan ${doctorResponse.dokter.length} dokter');
          _doctorResponse = doctorResponse;
          emit(DoctorsLoaded(doctorResponse: doctorResponse));

          // Panggil _checkFormDataLoaded untuk update UI
          _checkFormDataLoaded(emit);
        },
      );
    } catch (e) {
      Logger.error(_tag, 'Error tidak tertangani di _onGetDoctors', e);
      emit(AddScheduleError(message: 'Terjadi kesalahan tidak terduga: $e'));

      // Tetap panggil _checkFormDataLoaded meskipun terjadi error
      _checkFormDataLoaded(emit);
    }
  }

  void _checkFormDataLoaded(Emitter<AddScheduleState> emit) {
    Logger.debug(_tag, 'Memeriksa apakah semua data form sudah dimuat');
    Logger.debug(_tag,
        'Dokter & Klinik: ${_doctorsAndClinics.length}, Tipe Jadwal: ${_scheduleTypes.length}, Produk: ${_products.length}, Dokter API: ${_doctorResponse?.dokter.length ?? 0}');

    // Emit state dengan data yang tersedia, meskipun tidak semua data berhasil dimuat
    // Ini memungkinkan UI untuk menampilkan data yang berhasil dimuat
    emit(AddScheduleFormLoaded(
      doctorsAndClinics: _doctorsAndClinics,
      scheduleTypes: _scheduleTypes,
      products: _products,
      doctorResponse: _doctorResponse,
    ));

    if (_doctorsAndClinics.isEmpty) {
      Logger.warning(_tag, 'Data dokter dan klinik kosong');
    }

    if (_scheduleTypes.isEmpty) {
      Logger.warning(_tag, 'Data tipe jadwal kosong');
    }

    if (_doctorResponse == null || _doctorResponse!.dokter.isEmpty) {
      Logger.warning(_tag, 'Data dokter API kosong');
    }

    if (_doctorsAndClinics.isNotEmpty &&
        _scheduleTypes.isNotEmpty &&
        _products.isNotEmpty) {
      Logger.success(_tag, 'Semua data form berhasil dimuat');
    } else {
      Logger.warning(_tag,
          'Beberapa data form belum dimuat, tetapi UI akan menampilkan data yang tersedia');
    }
  }

  Future<void> _onSubmitSchedule(
    SubmitScheduleEvent event,
    Emitter<AddScheduleState> emit,
  ) async {
    try {
      Logger.info(_tag, 'Memulai pengiriman data jadwal');
      Logger.divider();
      Logger.debug(_tag, 'Type Schedule: ${event.typeSchedule}');
      Logger.debug(_tag, 'Tujuan: ${event.tujuan}');
      Logger.debug(_tag, 'Tanggal Visit: ${event.tglVisit}');
      Logger.debug(_tag, 'Products: ${event.product}');
      Logger.debug(_tag, 'Product Names: ${event.productNames}');
      Logger.debug(_tag, 'Divisi IDs: ${event.productForIdDivisi}');
      Logger.debug(_tag, 'Divisi Names: ${event.divisiNames}');
      Logger.debug(_tag, 'Spesialis IDs: ${event.productForIdSpesialis}');
      Logger.debug(_tag, 'Spesialis Names: ${event.spesialisNames}');
      Logger.debug(_tag, 'Note: ${event.note}');
      Logger.debug(_tag, 'User ID: ${event.idUser}');
      Logger.debug(_tag, 'Dokter: ${event.dokter}');
      Logger.debug(_tag, 'Klinik: ${event.klinik}');
      Logger.debug(_tag, 'Shift: ${event.shift}');
      Logger.debug(_tag, 'Jenis: ${event.jenis}');
      Logger.divider();

      // Validasi data sebelum dikirim
      if (event.product.isEmpty) {
        throw ServerException(message: 'Produk harus dipilih');
      }

      if (event.productNames.isEmpty) {
        throw ServerException(message: 'Nama produk tidak boleh kosong');
      }

      if (event.productForIdDivisi.isEmpty || event.divisiNames.isEmpty) {
        throw ServerException(message: 'Data divisi tidak lengkap');
      }

      if (event.productForIdSpesialis.isEmpty || event.spesialisNames.isEmpty) {
        throw ServerException(message: 'Data spesialis tidak lengkap');
      }

      emit(AddScheduleLoading());

      final result = await addSchedule(AddScheduleParams(
        typeSchedule: event.typeSchedule,
        tujuan: event.tujuan,
        tglVisit: event.tglVisit,
        product: event.product,
        note: event.note,
        idUser: event.idUser,
        dokter: event.dokter,
        klinik: event.klinik,
        productForIdDivisi: event.productForIdDivisi,
        productForIdSpesialis: event.productForIdSpesialis,
        shift: event.shift,
        jenis: event.jenis,
        productNames: event.productNames,
        divisiNames: event.divisiNames,
        spesialisNames: event.spesialisNames,
      ));

      result.fold(
        (failure) {
          Logger.error(_tag, 'Submit Schedule Error: ${failure.toString()}');
          emit(AddScheduleError(message: failure.toString()));
        },
        (success) {
          Logger.success(_tag, 'Jadwal berhasil ditambahkan');
          emit(AddScheduleSuccess());
        },
      );
    } catch (e) {
      Logger.error(_tag, 'Unexpected error in submit schedule', e);
      emit(AddScheduleError(message: e.toString()));
    }
  }
}
