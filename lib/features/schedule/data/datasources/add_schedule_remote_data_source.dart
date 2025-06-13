import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cbo/core/error/exceptions.dart';
import 'package:test_cbo/core/utils/constants.dart';
import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/data/models/doctor_clinic_model.dart';
import 'package:test_cbo/features/schedule/data/models/doctor_model.dart';
import 'package:test_cbo/features/schedule/data/models/product_model.dart';
import 'package:test_cbo/features/schedule/data/models/responses/doctor_response.dart';
import 'package:test_cbo/features/schedule/data/models/responses/schedule_type_response.dart';
import 'package:test_cbo/features/schedule/data/models/schedule_type_model.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic_base.dart';
import 'package:test_cbo/core/presentation/widgets/custom_snackbar.dart';

abstract class AddScheduleRemoteDataSource {
  Future<List<DoctorClinicBase>> getDoctorsAndClinics(int userId);
  Future<List<ScheduleTypeModel>> getScheduleTypes();
  Future<List<ProductModel>> getProducts(int userId);
  Future<DoctorResponse> getDoctors();
  Future<bool> addSchedule({
    required int typeSchedule,
    required String tujuan,
    required String tglVisit,
    required List<int> product,
    required String note,
    required int idUser,
    required int dokter,
    required String klinik,
    required List<int> productForIdDivisi,
    required List<int> productForIdSpesialis,
    required String shift,
    required String jenis,
    required List<String> productNames,
    required List<String> divisiNames,
    required List<String> spesialisNames,
  });
}

class AddScheduleRemoteDataSourceImpl implements AddScheduleRemoteDataSource {
  final Dio dio;
  final SharedPreferences sharedPreferences;
  static const String _tag = 'AddScheduleRemoteDataSource';

  AddScheduleRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  @override
  Future<List<DoctorClinicBase>> getDoctorsAndClinics(int userId) async {
    try {
      Logger.info(_tag,
          '🔄 DataSource: Memulai request ke API dokter dan klinik dengan userId: $userId');

      // Ambil token dan data user
      final token = sharedPreferences.getString(Constants.tokenKey);
      final userDataString = sharedPreferences.getString(Constants.userDataKey);

      if (token == null) {
        throw ServerException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      if (userDataString == null) {
        throw ServerException(
            message: 'Data pengguna tidak ditemukan. Silakan login kembali.');
      }

      // Parse user data untuk validasi
      final userData = json.decode(userDataString);
      final storedUserId = userData['id_user'];

      if (storedUserId != userId) {
        Logger.warning(
            _tag, '⚠️ DataSource: User ID tidak sesuai dengan data tersimpan');
        throw ServerException(
            message: 'ID pengguna tidak valid. Silakan login kembali.');
      }

      // Gunakan URL yang sudah terbukti bekerja
      final String url = '${Constants.baseUrl}/dokter-dan-klinik/get/$userId';
      Logger.info(_tag, '🔄 DataSource: Mencoba mengambil dokter dari: $url');

      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      );

      final response = await dio.get(url, options: options);

      if (response.statusCode == 200) {
        Logger.info(_tag, '✅ DataSource: Berhasil mendapatkan response');
        final responseData = response.data;

        // Log raw response data
        Logger.debug(_tag, '🔍 Raw response type: ${responseData.runtimeType}');
        Logger.debug(_tag, '🔍 Raw response data: $responseData');

        try {
          List<DoctorClinicModel> doctors = [];

          if (responseData is Map<String, dynamic>) {
            Logger.debug(_tag, '🔍 Response is Map');

            // Check for nested doctor data first
            if (responseData.containsKey('dokter')) {
              Logger.debug(_tag, '🔍 Found "dokter" key in response');
              final doctorData = responseData['dokter'];
              Logger.debug(
                  _tag, '🔍 Doctor data type: ${doctorData.runtimeType}');

              if (doctorData is List) {
                Logger.debug(_tag,
                    '🔍 Found nested doctor list with ${doctorData.length} items');

                // Log each doctor data before parsing
                for (var item in doctorData) {
                  Logger.debug(_tag, '🔍 Processing doctor item:');
                  Logger.debug(_tag, '  - Raw data: $item');
                  Logger.debug(_tag, '  - Type: ${item.runtimeType}');
                  if (item is Map) {
                    Logger.debug(_tag, '  - Keys: ${item.keys.toList()}');
                    Logger.debug(_tag, '  - id_dokter: ${item['id_dokter']}');
                    Logger.debug(
                        _tag, '  - nama_dokter: ${item['nama_dokter']}');
                    Logger.debug(_tag, '  - spesialis: ${item['spesialis']}');
                    Logger.debug(
                        _tag, '  - nama_spesialis: ${item['nama_spesialis']}');
                  }

                  try {
                    final doctor = DoctorClinicModel.fromJson(item);
                    Logger.debug(_tag, '✅ Successfully parsed doctor:');
                    Logger.debug(_tag, '  - ID: ${doctor.id}');
                    Logger.debug(_tag, '  - Nama: ${doctor.nama}');
                    Logger.debug(_tag, '  - Spesialis: ${doctor.spesialis}');
                    doctors.add(doctor);
                  } catch (e, stackTrace) {
                    Logger.error(_tag, '❌ Error parsing individual doctor: $e');
                    Logger.error(_tag, '❌ Stack trace: $stackTrace');
                    Logger.error(_tag, '❌ Doctor data that failed: $item');
                    continue;
                  }
                }
              } else {
                Logger.warning(_tag,
                    '⚠️ Doctor data is not a List: ${doctorData.runtimeType}');
              }
            }
          }

          if (doctors.isNotEmpty) {
            Logger.info(
                _tag, '✅ DataSource: Berhasil parse ${doctors.length} dokter');
            Logger.info(_tag,
                '✅ DataSource: Contoh dokter pertama: ${doctors.first.nama}');
            return doctors;
          }

          Logger.warning(_tag, '⚠️ No doctors parsed from response');
          throw ServerException(message: 'Tidak ada data dokter yang tersedia');
        } catch (e, stackTrace) {
          Logger.error(_tag, '❌ DataSource: Error parsing doctor data: $e');
          Logger.error(_tag, '❌ Stack trace: $stackTrace');
          throw ServerException(message: 'Format data dokter tidak valid: $e');
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      } else {
        throw ServerException(
            message:
                'Gagal mengambil data dokter. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      Logger.error(_tag, '❌ DataSource: DioError: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }
      throw ServerException(
          message:
              'Terjadi kesalahan saat mengambil data dokter: ${e.message}');
    } catch (e) {
      Logger.error(_tag, '❌ DataSource: Error dalam getDoctorsAndClinics: $e');
      if (e is ServerException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(
          message: 'Terjadi kesalahan saat mengambil data dokter');
    }
  }

  @override
  Future<List<ScheduleTypeModel>> getScheduleTypes() async {
    try {
      Logger.info(_tag, '🔄 DataSource: Memulai request ke API tipe jadwal');

      // Ambil token dari SharedPreferences
      final token = sharedPreferences.getString(Constants.tokenKey);
      Logger.info(_tag,
          '🔄 DataSource: Token tersedia: ${token != null ? 'Ya' : 'Tidak'}');

      if (token == null) {
        Logger.warning(
            _tag, '❌ DataSource: Token tidak ditemukan di SharedPreferences');
        throw ServerException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      // Coba beberapa kemungkinan URL endpoint
      final List<String> possibleUrls = [
        '${Constants.baseUrl}/tipe-schedule/get',
        '${Constants.baseUrl}/tipe-schedule',
        '${Constants.baseUrl}/schedule-type',
        '${Constants.baseUrl}/schedule-type/get',
        '${Constants.baseUrl}/tipe-schedule/list',
        '${Constants.baseUrl}/schedule/types',
        '${Constants.baseUrl}/types/schedule',
      ];

      Response? response;

      // Coba setiap URL secara berurutan sampai berhasil
      for (final url in possibleUrls) {
        try {
          Logger.info(
              _tag, '🔄 DataSource: Mencoba request ke API tipe jadwal: $url');

          response = await dio.get(
            url,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

          if (response.statusCode == 200) {
            Logger.info(_tag, '✅ DataSource: Berhasil menggunakan URL: $url');
            break;
          }
        } catch (e) {
          Logger.warning(_tag, '⚠️ DataSource: URL $url tidak berhasil: $e');
          continue;
        }
      }

      if (response == null || response.statusCode != 200) {
        throw ServerException(
            message: 'Gagal mengambil data tipe jadwal dari semua endpoint');
      }

      Logger.info(_tag,
          '🔄 DataSource: Tipe jadwal API Response Status: ${response.statusCode}');
      Logger.info(
          _tag, '🔄 DataSource: Response Type: ${response.data.runtimeType}');

      // Log raw response data
      try {
        if (response.data is Map) {
          Logger.info(_tag,
              '🔄 DataSource: Response is Map with keys: ${(response.data as Map).keys.toList()}');

          if (response.data.containsKey('data')) {
            Logger.info(_tag,
                '🔄 DataSource: Data type: ${response.data['data'].runtimeType}');
            if (response.data['data'] is List) {
              Logger.info(_tag,
                  '🔄 DataSource: Data length: ${(response.data['data'] as List).length}');
            }
          }
        } else if (response.data is String) {
          final truncatedData = response.data.toString().length > 200
              ? '${response.data.toString().substring(0, 200)}...'
              : response.data.toString();
          Logger.info(
              _tag, '🔄 DataSource: Response is String: $truncatedData');
        } else {
          Logger.info(_tag,
              '🔄 DataSource: Response type is: ${response.data.runtimeType}');
        }
      } catch (e) {
        Logger.error(_tag, '❌ DataSource: Error while logging response: $e');
      }

      if (response.statusCode == 401) {
        Logger.warning(
            _tag, '❌ DataSource: Autentikasi gagal (401 Unauthorized)');
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      if (response.statusCode == 200) {
        Logger.info(_tag,
            '✅ DataSource: Berhasil mendapatkan response dengan status 200');
        final responseData = response.data;
        try {
          final scheduleTypeResponse =
              ScheduleTypeResponse.fromJson(responseData);
          Logger.info(_tag,
              '✅ DataSource: Jumlah tipe jadwal: ${scheduleTypeResponse.data.length}');
          return scheduleTypeResponse.data;
        } catch (e) {
          Logger.error(
              _tag, '❌ DataSource: Error parsing schedule type response: $e');
          // Kembalikan data dummy jika parsing gagal
          return [
            const ScheduleTypeModel(id: 1, nama: 'DETAILING', keterangan: ''),
            const ScheduleTypeModel(id: 2, nama: 'FOLLOW UP', keterangan: ''),
            const ScheduleTypeModel(id: 3, nama: 'ENTERTAINT', keterangan: ''),
            const ScheduleTypeModel(id: 4, nama: 'SERVICE', keterangan: ''),
            const ScheduleTypeModel(id: 5, nama: 'JOIN VISIT', keterangan: ''),
            const ScheduleTypeModel(id: 6, nama: 'REMINDING', keterangan: ''),
          ];
        }
      } else {
        Logger.warning(_tag,
            '❌ DataSource: Status code bukan 200: ${response.statusCode}');
        throw ServerException(message: 'Gagal memuat data tipe jadwal');
      }
    } catch (e) {
      Logger.error(_tag, '❌ DataSource: Error saat mengambil tipe jadwal: $e');
      if (e is ServerException || e is UnauthorizedException) {
        rethrow;
      }
      // Return dummy data instead of throwing exception
      Logger.warning(_tag,
          '❌ DataSource: Mengembalikan data dummy untuk tipe jadwal karena error');
      return [
        const ScheduleTypeModel(id: 1, nama: 'DETAILING', keterangan: ''),
        const ScheduleTypeModel(id: 2, nama: 'FOLLOW UP', keterangan: ''),
        const ScheduleTypeModel(id: 3, nama: 'ENTERTAINT', keterangan: ''),
        const ScheduleTypeModel(id: 4, nama: 'SERVICE', keterangan: ''),
        const ScheduleTypeModel(id: 5, nama: 'JOIN VISIT', keterangan: ''),
        const ScheduleTypeModel(id: 6, nama: 'REMINDING', keterangan: ''),
      ];
    }
  }

  @override
  Future<List<ProductModel>> getProducts(int userId) async {
    try {
      Logger.info(_tag,
          '🔄 DataSource: Memulai request ke API product dengan userId: $userId');

      final token = sharedPreferences.getString(Constants.tokenKey);
      final userDataString = sharedPreferences.getString(Constants.userDataKey);

      if (token == null) {
        throw ServerException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      if (userDataString == null) {
        throw ServerException(
            message: 'Data pengguna tidak ditemukan. Silakan login kembali.');
      }

      // Parse user data untuk validasi
      final userData = json.decode(userDataString);
      final storedUserId = userData['id_user'];

      if (storedUserId != userId) {
        Logger.warning(
            _tag, '⚠️ DataSource: User ID tidak sesuai dengan data tersimpan');
        throw ServerException(
            message: 'ID pengguna tidak valid. Silakan login kembali.');
      }

      // Menggunakan URL yang benar untuk product, coba pakai pattern yang sama dengan dokter-dan-klinik
      final String url = '${Constants.baseUrl}/product/get/$userId';
      Logger.info(_tag, '🔄 DataSource: Mencoba mengambil produk dari: $url');

      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      );

      final response = await dio.get(url, options: options);

      Logger.info(
          _tag, '🔄 DataSource: Response status code: ${response.statusCode}');
      Logger.info(
          _tag, '🔄 DataSource: Response type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        Logger.info(_tag, '✅ DataSource: Berhasil mendapatkan data dari $url');
        Logger.info(_tag,
            '🔄 DataSource: Tipe response data: ${responseData.runtimeType}');
        Logger.info(_tag,
            '🔄 DataSource: Keys dalam response: ${responseData is Map ? (responseData).keys.toList() : "Bukan Map"}');

        try {
          List<ProductModel> products = [];

          if (responseData is Map<String, dynamic>) {
            // Coba berbagai kemungkinan struktur response
            dynamic productData;

            if (responseData.containsKey('data')) {
              productData = responseData['data'];
              Logger.info(
                  _tag, '✅ DataSource: Menggunakan data dari key "data"');
            } else if (responseData.containsKey('products')) {
              productData = responseData['products'];
              Logger.info(
                  _tag, '✅ DataSource: Menggunakan data dari key "products"');
            } else if (responseData.containsKey('result')) {
              productData = responseData['result'];
              Logger.info(
                  _tag, '✅ DataSource: Menggunakan data dari key "result"');
            } else {
              productData = responseData;
              Logger.info(_tag,
                  '✅ DataSource: Menggunakan data langsung dari response');
            }

            if (productData is List) {
              Logger.info(_tag,
                  '✅ DataSource: Data produk adalah List dengan ${productData.length} item');
              products = productData
                  .map((item) => ProductModel.fromJson(item))
                  .toList();
            } else if (productData is Map<String, dynamic>) {
              Logger.info(_tag,
                  '✅ DataSource: Data produk adalah Map, mencoba parse sebagai item tunggal');
              products = [ProductModel.fromJson(productData)];
            } else {
              Logger.warning(_tag,
                  '❌ DataSource: Format data produk tidak valid: ${productData.runtimeType}');
              throw ServerException(
                  message: 'Format data produk tidak didukung');
            }
          } else if (responseData is List) {
            Logger.info(_tag,
                '✅ DataSource: Response langsung berupa List dengan ${responseData.length} item');
            products = responseData
                .map((item) => ProductModel.fromJson(item))
                .toList();
          } else {
            Logger.warning(_tag,
                '❌ DataSource: Format response tidak didukung: ${responseData.runtimeType}');
            throw ServerException(message: 'Format response tidak didukung');
          }

          if (products.isNotEmpty) {
            Logger.info(
                _tag, '✅ DataSource: Berhasil parse ${products.length} produk');
            Logger.info(_tag,
                '✅ DataSource: Contoh produk pertama: ${products.first.namaProduct}');
            return products;
          }

          Logger.warning(
              _tag, '❌ DataSource: Tidak ada produk yang dapat di-parse');
          throw ServerException(message: 'Tidak ada data produk yang tersedia');
        } catch (e) {
          Logger.error(_tag, '❌ DataSource: Error parsing product data: $e');
          throw ServerException(message: 'Format data produk tidak valid: $e');
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      } else {
        throw ServerException(
            message:
                'Gagal mengambil data produk. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      Logger.error(
          _tag, '❌ DataSource: DioError dalam getProducts: ${e.message}');

      // Log response data jika ada
      if (e.response != null) {
        Logger.error(_tag,
            '❌ DataSource: Error response status: ${e.response?.statusCode}');
        Logger.error(
            _tag, '❌ DataSource: Error response data: ${e.response?.data}');
      }

      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      throw ServerException(
          message:
              'Terjadi kesalahan saat mengambil data produk: ${e.message}');
    } catch (e) {
      Logger.error(
          _tag, '❌ DataSource: Error tidak terduga dalam getProducts: $e');
      throw ServerException(
          message:
              'Terjadi kesalahan tidak terduga saat mengambil data produk: $e');
    }
  }

  @override
  Future<DoctorResponse> getDoctors() async {
    try {
      Logger.info(_tag, '🔄 DataSource: Memulai request ke API dokter');

      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw ServerException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      // List endpoint yang akan dicoba
      final endpoints = [
        '/dokter-dan-klinik/get',
        '/dokter/get',
        '/dokter/list',
        '/dokter-klinik/get',
      ];

      Response? successResponse;
      Map<String, dynamic> errorDetails = {};

      // Mencoba setiap endpoint sampai berhasil
      for (final endpoint in endpoints) {
        try {
          Logger.info(_tag, '🔄 DataSource: Mencoba endpoint: $endpoint');
          final url = '${Constants.baseUrl}$endpoint';
          Logger.info(_tag, '🔄 DataSource: Full URL: $url');

          final response = await dio.get(
            url,
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              validateStatus: (status) => true, // Accept all status codes
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

          Logger.info(_tag, '📝 DataSource: Response dari $endpoint:');
          Logger.info(_tag, '  - Status Code: ${response.statusCode}');
          Logger.info(_tag, '  - Headers: ${response.headers}');
          Logger.info(_tag, '  - Data Type: ${response.data.runtimeType}');

          if (response.statusCode == 200) {
            Logger.success(_tag, '✅ DataSource: Endpoint $endpoint berhasil');
            successResponse = response;
            break;
          } else {
            errorDetails[endpoint] = {
              'statusCode': response.statusCode,
              'data': response.data,
              'headers': response.headers.map,
            };
            Logger.warning(_tag,
                '⚠️ DataSource: Endpoint $endpoint gagal dengan status ${response.statusCode}');
          }
        } catch (e) {
          errorDetails[endpoint] = {
            'error': e.toString(),
            'type': e.runtimeType.toString(),
          };
          Logger.error(_tag, '❌ DataSource: Error pada endpoint $endpoint: $e');
          continue;
        }
      }

      // Jika tidak ada response yang sukses
      if (successResponse == null) {
        final errorMessage =
            StringBuffer('Gagal mengambil data dokter dari semua endpoint:\n');
        errorDetails.forEach((endpoint, details) {
          errorMessage.writeln('- $endpoint: ${details.toString()}');
        });
        Logger.error(_tag, errorMessage.toString());
        throw ServerException(message: errorMessage.toString());
      }

      final responseData = successResponse.data;
      Logger.debug(_tag, '🔍 Response data: $responseData');

      try {
        if (responseData is Map<String, dynamic>) {
          final dokterList = responseData['dokter'] ?? [];

          if (dokterList is! List) {
            Logger.error(
                _tag, '❌ DataSource: Data dokter bukan List: $dokterList');
            throw ServerException(message: 'Format data dokter tidak valid');
          }

          final doctors = dokterList
              .map((item) {
                try {
                  return DoctorClinicModel.fromJson(item);
                } catch (e) {
                  Logger.warning(
                      _tag, '⚠️ DataSource: Error parsing dokter: $e');
                  Logger.warning(
                      _tag, '⚠️ DataSource: Data dokter yang error: $item');
                  return null;
                }
              })
              .where((d) => d != null)
              .cast<DoctorClinicModel>()
              .toList();

          if (doctors.isNotEmpty) {
            Logger.success(
                _tag, '✅ DataSource: Berhasil parse ${doctors.length} dokter');
            return DoctorResponse(dokter: doctors, klinik: []);
          } else {
            Logger.warning(
                _tag, '⚠️ DataSource: Tidak ada dokter yang berhasil di-parse');
            return DoctorResponse(dokter: [], klinik: []);
          }
        } else {
          Logger.error(_tag,
              '❌ DataSource: Format response tidak sesuai: ${responseData.runtimeType}');
          throw ServerException(message: 'Format response tidak sesuai');
        }
      } catch (e) {
        Logger.error(_tag, '❌ DataSource: Error parsing response: $e');
        throw ServerException(message: 'Format data dokter tidak valid: $e');
      }
    } catch (e) {
      Logger.error(
          _tag, '❌ DataSource: Error tidak terduga dalam getDoctors: $e');
      rethrow;
    }
  }

  @override
  Future<bool> addSchedule({
    required int typeSchedule,
    required String tujuan,
    required String tglVisit,
    required List<int> product,
    required String note,
    required int idUser,
    required int dokter,
    required String klinik,
    required List<int> productForIdDivisi,
    required List<int> productForIdSpesialis,
    required String shift,
    required String jenis,
    required List<String> productNames,
    required List<String> divisiNames,
    required List<String> spesialisNames,
  }) async {
    try {
      Logger.debug(_tag, 'Data yang akan dikirim ke API:');
      Logger.divider();
      Logger.debug(_tag, 'Type Schedule: $typeSchedule');
      Logger.debug(_tag, 'Tujuan: $tujuan');
      Logger.debug(_tag, 'Tanggal Visit: $tglVisit');
      Logger.debug(_tag, 'Product IDs: $product');
      Logger.debug(_tag, 'Product Names: $productNames');
      Logger.debug(_tag, 'Divisi IDs: $productForIdDivisi');
      Logger.debug(_tag, 'Divisi Names: $divisiNames');
      Logger.debug(_tag, 'Spesialis IDs: $productForIdSpesialis');
      Logger.debug(_tag, 'Spesialis Names: $spesialisNames');
      Logger.debug(_tag, 'Note: $note');
      Logger.debug(_tag, 'User ID: $idUser');
      Logger.debug(_tag, 'Dokter ID: $dokter');
      Logger.debug(_tag, 'Klinik: $klinik');
      Logger.debug(_tag, 'Shift: $shift');
      Logger.debug(_tag, 'Jenis: $jenis');
      Logger.divider();

      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw ServerException(
            message: 'Sesi login telah berakhir. Silakan login kembali.');
      }

      // Konversi ID ke format yang diharapkan API (array string)
      final productJson = product.map((id) => id.toString()).toList();
      final divisiJson = productForIdDivisi.map((id) => id.toString()).toList();
      final spesialisJson =
          productForIdSpesialis.map((id) => id.toString()).toList();

      final formData = FormData.fromMap({
        'type-schedule': typeSchedule.toString(),
        'tujuan': tujuan,
        'tgl-visit': tglVisit,
        'product': jsonEncode(productJson),
        'note': note,
        'id-user': idUser.toString(),
        'dokter': dokter.toString(),
        'klinik': klinik,
        'product_for_id_divisi': jsonEncode(divisiJson),
        'product_for_id_spesialis': jsonEncode(spesialisJson),
        'shift': shift,
        'jenis': jenis,
        'nama_product': jsonEncode(productNames),
        'nama_divisi': divisiNames.join(', '),
        'nama_spesialis': spesialisNames.join(', '),
      });

      // Tambahkan log untuk memeriksa data yang dikirim
      Logger.debug(_tag, '''
Data yang akan dikirim dalam FormData:
${formData.fields.map((field) => '${field.key}: ${field.value}').join('\n')}
''');

      Logger.network(_tag, 'Mengirim request',
          url: '${Constants.baseUrl}/schedule/add',
          method: 'POST',
          data: formData.fields
              .map((field) => '${field.key}: ${field.value}')
              .join(', '));

      final response = await dio.post(
        '${Constants.baseUrl}/schedule/add',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      Logger.network(_tag, 'Response diterima',
          response: 'Status: ${response.statusCode}, Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final bool status = responseData['status'] as bool? ?? false;
        Logger.success(_tag, 'Status penambahan jadwal: $status');
        if (status) {
          return true;
        }
      }

      final errorMessage = response.data['desc'] ?? 'Gagal menambahkan jadwal';
      Logger.error(_tag, 'Error: $errorMessage');
      throw ServerException(message: errorMessage);
    } catch (e) {
      Logger.error(_tag, 'Exception caught: ${e.runtimeType}', e);

      if (e is DioException) {
        Logger.network(_tag, 'DioException details',
            url: '${e.requestOptions.uri}',
            method: e.requestOptions.method,
            data: '${e.requestOptions.data}',
            response:
                'Status: ${e.response?.statusCode}, Data: ${e.response?.data}');

        final errorMessage = e.response?.data?['desc'] ??
            e.response?.statusMessage ??
            'Gagal menambahkan jadwal';
        throw ServerException(message: errorMessage);
      }

      throw ServerException(
          message: 'Terjadi kesalahan saat menambahkan jadwal: $e');
    }
  }
}
