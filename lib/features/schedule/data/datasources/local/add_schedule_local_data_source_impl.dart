import 'package:flutter/foundation.dart';
import 'package:test_cbo/core/database/app_database.dart';
import 'package:test_cbo/core/error/exceptions.dart';
import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/data/datasources/local/add_schedule_local_data_source.dart';
import 'package:test_cbo/features/schedule/data/models/doctor_clinic_model.dart';
import 'package:test_cbo/features/schedule/data/models/product_model.dart';
import 'package:test_cbo/features/schedule/data/models/schedule_type_model.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic_base.dart';

class AddScheduleLocalDataSourceImpl implements AddScheduleLocalDataSource {
  final AppDatabase database;

  // Konstanta untuk sinkronisasi
  static const int syncInterval = 6 * 60 * 60 * 1000; // 6 jam dalam milidetik
  static const String _tag = 'AddScheduleLocalDataSourceImpl';

  AddScheduleLocalDataSourceImpl({required this.database});

  @override
  Future<List<DoctorClinicBase>> getDoctorsAndClinics() async {
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
          alamat: json['address'] as String? ?? '',
          noTelp: json['phone'] as String? ?? '',
          email: json['email'] as String? ?? '',
          spesialis: json['specialization'] as String? ?? '',
          tipeDokter: json['doctor_type'] as String? ?? '',
          tipeKlinik: json['clinic_type'] as String? ?? '',
          kodeRayon: json['rayon_code'] as String? ?? '',
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
        // Handle backward compatibility - check if new fields exist
        final divisionIdJson = json['division_id_json']?.toString();
        final specialistIdJson = json['specialist_id_json']?.toString();
        
        // Buat fake JSON untuk ProductModel.fromJson agar fallback mechanism berjalan
        final fakeJson = {
          'id': json['id'],
          'nama': json['name'] as String,
          'nama_product': json['name'] as String,
          'id_divisi_sales': divisionIdJson, // Dari database (bisa null untuk data lama)
          'id_spesialis': specialistIdJson, // Dari database (bisa null untuk data lama)
          'keterangan': json['description'] ?? '',
          'desc': json['description'] ?? '',
          'kode': json['code'] ?? json['product_code'], // Ambil dari database jika ada (bisa null)
        };

        Logger.debug(_tag,
            'Creating ProductModel from local cache for: ${json['name']}');
        Logger.debug(_tag, '  division_id_json: $divisionIdJson');
        Logger.debug(
            _tag, '  specialist_id_json: $specialistIdJson');

        // Gunakan fromJson untuk memicu fallback mechanism
        return ProductModel.fromJson(fakeJson);
      }).toList();
    } catch (e) {
      Logger.error(
          _tag, 'Error saat mengambil data produk dari database lokal: $e');
      if (e is CacheException) rethrow;
      throw CacheException();
    }
  }

  @override
  Future<void> cacheDoctors(List<DoctorClinicBase> doctors) async {
    try {
      Logger.info(_tag, 'Menyimpan ${doctors.length} dokter ke database lokal');

      final List<Map<String, dynamic>> doctorsToInsert = doctors.map((doctor) {
        return {
          'id': doctor.id,
          'name': doctor.nama,
          'address': doctor.alamat,
          'phone': doctor.noTelp,
          'email': doctor.email,
          'specialization': doctor.spesialis,
          'doctor_type': doctor.tipeDokter,
          'clinic_type': doctor.tipeKlinik,
          'rayon_code': doctor.kodeRayon,
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
        // Simpan division dan specialist data sebagai JSON string
        Logger.debug(_tag, 'Caching product: ${product.nama}');
        Logger.debug(_tag, '  idDivisiSales: ${product.idDivisiSales}');
        Logger.debug(_tag, '  idSpesialis: ${product.idSpesialis}');
        
        return {
          'id': product.idProduct,
          'name': product.namaProduct,
          'code': product.kode, // Store product code (can be null)
          'description': product.keterangan, // Store product description (non-null)
          'division_id': 0, // Keep for backward compatibility
          'specialist_id': 0, // Keep for backward compatibility
          'division_id_json': product.idDivisiSales, // Store original JSON string
          'specialist_id_json': product.idSpesialis, // Store original JSON string
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

    // Check if this is the first time after schema upgrade
    final needsSchemaRefresh = await _needsSchemaRefresh();
    if (needsSchemaRefresh) {
      Logger.info(_tag, 'Schema upgrade detected, forcing products sync');
      return true;
    }

    // Cek apakah sudah lewat interval sinkronisasi atau belum ada data
    return lastUpdate == 0 || diff > syncInterval;
  }

  Future<bool> _needsSchemaRefresh() async {
    try {
      final productsData = await database.getProducts();
      if (productsData.isEmpty) return true;
      
      // Check if any product has the new fields (from both v2 and v3 schema updates)
      final hasNewFields = productsData.any((product) => 
        product.containsKey('division_id_json') || 
        product.containsKey('specialist_id_json') ||
        product.containsKey('code') ||
        product.containsKey('description'));
      
      // If no products have new fields, force refresh
      return !hasNewFields;
    } catch (e) {
      Logger.error(_tag, 'Error checking schema refresh need: $e');
      return true; // Force refresh on error
    }
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
