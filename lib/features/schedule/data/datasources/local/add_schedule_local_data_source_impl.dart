import 'package:flutter/foundation.dart';
import 'package:test_cbo/core/database/app_database.dart';
import 'package:test_cbo/core/error/exceptions.dart';
import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/data/datasources/local/add_schedule_local_data_source.dart';
import 'package:test_cbo/features/schedule/data/models/doctor_clinic_model.dart';
import 'package:test_cbo/features/schedule/data/models/product_model.dart';
import 'package:test_cbo/features/schedule/data/models/schedule_type_model.dart';

class AddScheduleLocalDataSourceImpl implements AddScheduleLocalDataSource {
  final AppDatabase database;

  // Konstanta untuk sinkronisasi
  static const int syncInterval = 6 * 60 * 60 * 1000; // 6 jam dalam milidetik
  static const String _tag = 'AddScheduleLocalDataSourceImpl';

  AddScheduleLocalDataSourceImpl({required this.database});

  @override
  Future<List<DoctorClinicModel>> getDoctorsAndClinics() async {
    try {
      Logger.info(_tag, 'Mengambil data dokter dari database lokal');
      final doctorsData = await database.getDoctors();

      if (doctorsData.isEmpty) {
        Logger.warning(_tag, 'Data dokter tidak ditemukan di database lokal');
        throw CacheException();
      }

      Logger.info(_tag,
          'Berhasil mengambil ${doctorsData.length} dokter dari database lokal');

      return doctorsData.map((json) {
        // Konversi dari format database ke model
        return DoctorClinicModel(
          id: json['id'] as int,
          nama: json['name'] as String,
          alamat: '',
          noTelp: '',
          email: '',
          spesialis: json['specialization'] as String? ?? '',
          tipeDokter: '',
          tipeKlinik: '',
          kodeRayon: '',
        );
      }).toList();
    } catch (e) {
      Logger.error(
          _tag, 'Error saat mengambil data dokter dari database lokal: $e');
      if (e is CacheException) rethrow;
      throw CacheException();
    }
  }

  @override
  Future<List<ScheduleTypeModel>> getScheduleTypes() async {
    try {
      Logger.info(_tag, 'Mengambil data tipe jadwal dari database lokal');
      final typesData = await database.getScheduleTypes();

      if (typesData.isEmpty) {
        Logger.warning(
            _tag, 'Data tipe jadwal tidak ditemukan di database lokal');
        throw CacheException();
      }

      Logger.info(_tag,
          'Berhasil mengambil ${typesData.length} tipe jadwal dari database lokal');

      return typesData.map((json) {
        // Konversi dari format database ke model
        return ScheduleTypeModel(
          id: json['id'] as int,
          nama: json['name'] as String,
          keterangan: '',
        );
      }).toList();
    } catch (e) {
      Logger.error(_tag,
          'Error saat mengambil data tipe jadwal dari database lokal: $e');
      if (e is CacheException) rethrow;
      throw CacheException();
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      Logger.info(_tag, 'Mengambil data produk dari database lokal');
      final productsData = await database.getProducts();

      if (productsData.isEmpty) {
        Logger.warning(_tag, 'Data produk tidak ditemukan di database lokal');
        throw CacheException();
      }

      Logger.info(_tag,
          'Berhasil mengambil ${productsData.length} produk dari database lokal');

      return productsData.map((json) {
        // Konversi dari format database ke model
        return ProductModel(
          idProduct: json['id'] as int,
          namaProduct: json['name'] as String,
          desc: '',
          kode: '',
          nama: json['name'] as String,
          keterangan: '',
          id: json['id'] as int,
        );
      }).toList();
    } catch (e) {
      Logger.error(
          _tag, 'Error saat mengambil data produk dari database lokal: $e');
      if (e is CacheException) rethrow;
      throw CacheException();
    }
  }

  @override
  Future<void> cacheDoctors(List<DoctorClinicModel> doctors) async {
    try {
      Logger.info(_tag, 'Menyimpan ${doctors.length} dokter ke database lokal');

      final List<Map<String, dynamic>> doctorsToInsert = doctors.map((doctor) {
        return {
          'id': doctor.id,
          'name': doctor.nama,
          'specialization': doctor.spesialis,
        };
      }).toList();

      await database.insertDoctors(doctorsToInsert);
      Logger.success(_tag, 'Dokter berhasil disimpan ke database lokal');
    } catch (e) {
      Logger.error(_tag, 'Error saat menyimpan dokter ke database lokal: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      Logger.info(
          _tag, 'Menyimpan ${products.length} produk ke database lokal');

      final List<Map<String, dynamic>> productsToInsert =
          products.map((product) {
        return {
          'id': product.idProduct,
          'name': product.namaProduct,
          'division_id': 0, // Default value, sesuaikan jika ada data tambahan
          'specialist_id': 0, // Default value, sesuaikan jika ada data tambahan
        };
      }).toList();

      await database.insertProducts(productsToInsert);
      Logger.success(_tag, 'Produk berhasil disimpan ke database lokal');
    } catch (e) {
      Logger.error(_tag, 'Error saat menyimpan produk ke database lokal: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> cacheScheduleTypes(List<ScheduleTypeModel> scheduleTypes) async {
    try {
      Logger.info(_tag,
          'Menyimpan ${scheduleTypes.length} tipe jadwal ke database lokal');

      final List<Map<String, dynamic>> typesToInsert =
          scheduleTypes.map((type) {
        return {
          'id': type.id,
          'name': type.nama,
        };
      }).toList();

      await database.insertScheduleTypes(typesToInsert);
      Logger.success(_tag, 'Tipe jadwal berhasil disimpan ke database lokal');
    } catch (e) {
      Logger.error(
          _tag, 'Error saat menyimpan tipe jadwal ke database lokal: $e');
      throw CacheException();
    }
  }

  @override
  Future<int> getLastDoctorsUpdate() async {
    try {
      return await database.getLastUpdated('doctors');
    } catch (e) {
      Logger.error(_tag, 'Error saat mengambil last update dokter: $e');
      return 0;
    }
  }

  @override
  Future<int> getLastProductsUpdate() async {
    try {
      return await database.getLastUpdated('products');
    } catch (e) {
      Logger.error(_tag, 'Error saat mengambil last update produk: $e');
      return 0;
    }
  }

  @override
  Future<int> getLastScheduleTypesUpdate() async {
    try {
      return await database.getLastUpdated('schedule_types');
    } catch (e) {
      Logger.error(_tag, 'Error saat mengambil last update tipe jadwal: $e');
      return 0;
    }
  }

  @override
  Future<bool> isDoctorsSyncNeeded() async {
    final lastUpdate = await getLastDoctorsUpdate();
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - lastUpdate;

    if (kDebugMode) {
      print(
          'Last doctors update: ${DateTime.fromMillisecondsSinceEpoch(lastUpdate)}');
      print('Time difference: ${Duration(milliseconds: diff).inHours} hours');
    }

    // Cek apakah sudah lewat interval sinkronisasi atau belum ada data
    return lastUpdate == 0 || diff > syncInterval;
  }

  @override
  Future<bool> isProductsSyncNeeded() async {
    final lastUpdate = await getLastProductsUpdate();
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - lastUpdate;

    if (kDebugMode) {
      print(
          'Last products update: ${DateTime.fromMillisecondsSinceEpoch(lastUpdate)}');
      print('Time difference: ${Duration(milliseconds: diff).inHours} hours');
    }

    // Cek apakah sudah lewat interval sinkronisasi atau belum ada data
    return lastUpdate == 0 || diff > syncInterval;
  }

  @override
  Future<bool> isScheduleTypesSyncNeeded() async {
    final lastUpdate = await getLastScheduleTypesUpdate();
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - lastUpdate;

    if (kDebugMode) {
      print(
          'Last schedule types update: ${DateTime.fromMillisecondsSinceEpoch(lastUpdate)}');
      print('Time difference: ${Duration(milliseconds: diff).inHours} hours');
    }

    // Cek apakah sudah lewat interval sinkronisasi atau belum ada data
    return lastUpdate == 0 || diff > syncInterval;
  }
}
