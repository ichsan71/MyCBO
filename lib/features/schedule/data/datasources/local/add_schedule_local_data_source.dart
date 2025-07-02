import 'package:test_cbo/features/schedule/data/models/product_model.dart';
import 'package:test_cbo/features/schedule/data/models/schedule_type_model.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic_base.dart';

abstract class AddScheduleLocalDataSource {
  /// Mendapatkan daftar dokter dan klinik dari cache lokal
  /// Throws [CacheException] jika tidak ada data
  Future<List<DoctorClinicBase>> getDoctorsAndClinics();

  /// Mendapatkan daftar tipe jadwal dari cache lokal
  /// Throws [CacheException] jika tidak ada data
  Future<List<ScheduleTypeModel>> getScheduleTypes();

  /// Mendapatkan daftar produk dari cache lokal
  /// Throws [CacheException] jika tidak ada data
  Future<List<ProductModel>> getProducts();

  /// Menyimpan data dokter ke cache lokal
  Future<void> cacheDoctors(List<DoctorClinicBase> doctors);

  /// Menyimpan data tipe jadwal ke cache lokal
  Future<void> cacheScheduleTypes(List<ScheduleTypeModel> scheduleTypes);

  /// Menyimpan data produk ke cache lokal
  Future<void> cacheProducts(List<ProductModel> products);

  /// Mendapatkan timestamp terakhir data dokter diperbarui
  Future<int> getLastDoctorsUpdate();

  /// Mendapatkan timestamp terakhir data tipe jadwal diperbarui
  Future<int> getLastScheduleTypesUpdate();

  /// Mendapatkan timestamp terakhir data produk diperbarui
  Future<int> getLastProductsUpdate();

  /// Memeriksa apakah data dokter perlu disinkronkan
  Future<bool> isDoctorsSyncNeeded();

  /// Memeriksa apakah data tipe jadwal perlu disinkronkan
  Future<bool> isScheduleTypesSyncNeeded();

  /// Memeriksa apakah data produk perlu disinkronkan
  Future<bool> isProductsSyncNeeded();
}
