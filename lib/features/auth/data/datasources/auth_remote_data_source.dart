import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<bool> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      if (kDebugMode) {
        print('Mencoba login dengan email: $email');
      }

      // Validasi input
      if (email.isEmpty) {
        throw AuthenticationException(
          message: 'Email tidak boleh kosong',
        );
      }

      if (password.isEmpty) {
        throw AuthenticationException(
          message: 'Password tidak boleh kosong',
        );
      }

      if (!email.contains('@')) {
        throw AuthenticationException(
          message: 'Format email tidak valid',
        );
      }

      final response = await dio.post(
        '${Constants.baseUrl}/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          validateStatus: (status) => true, // Handle all status codes
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (kDebugMode) {
        print('Status response: ${response.statusCode}');
        print('Response data: ${response.data}');
      }

      // Handle specific HTTP status codes
      switch (response.statusCode) {
        case 200:
          // Handle successful response
          Map<String, dynamic> responseData;
          if (response.data is String) {
            try {
              responseData = json.decode(response.data);
            } catch (e) {
              throw AuthenticationException(
                message: 'Format respons server tidak valid',
              );
            }
          } else if (response.data is Map<String, dynamic>) {
            responseData = response.data;
          } else {
            throw AuthenticationException(
              message: 'Format respons server tidak sesuai',
            );
          }

          if (responseData['status'] == true) {
            final token = responseData['token'];
            final userData = responseData['data'];

            if (token == null || userData == null) {
              throw AuthenticationException(
                message: 'Data login tidak lengkap dari server',
              );
            }

            try {
              final user = UserModel.fromJson(userData, token);
              await sharedPreferences.setString(Constants.tokenKey, token);
              await sharedPreferences.setString(
                Constants.userDataKey,
                json.encode(user.toJson()),
              );
              return user;
            } catch (e) {
              throw AuthenticationException(
                message: 'Gagal memproses data user: ${e.toString()}',
              );
            }
          } else {
            throw AuthenticationException(
              message: responseData['message'] ?? 'Login gagal, silakan coba lagi',
            );
          }

        case 401:
          throw AuthenticationException(
            message: 'Email atau password salah',
          );

        case 404:
          throw AuthenticationException(
            message: 'Akun tidak ditemukan',
          );

        case 422:
          throw AuthenticationException(
            message: 'Data yang dimasukkan tidak valid',
          );

        case 429:
          throw AuthenticationException(
            message: 'Terlalu banyak percobaan login. Silakan tunggu beberapa saat',
          );

        case 500:
          throw ServerException(
            message: 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi',
          );

        default:
          throw ServerException(
            message: 'Terjadi kesalahan tidak terduga (${response.statusCode})',
          );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DioException: ${e.message}');
        print('DioException response: ${e.response?.data}');
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw ServerException(
            message: 'Koneksi timeout. Periksa koneksi internet Anda',
          );

        case DioExceptionType.connectionError:
          throw ServerException(
            message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda',
          );

        case DioExceptionType.badResponse:
          final responseData = e.response?.data;
          if (responseData != null && responseData is Map<String, dynamic>) {
            throw AuthenticationException(
              message: responseData['message'] ?? 'Login gagal',
            );
          }
          throw ServerException(
            message: 'Respons server tidak valid',
          );

        default:
          throw ServerException(
            message: 'Terjadi kesalahan: ${e.message}',
          );
      }
    } catch (e) {
      if (kDebugMode) {
        print('General exception during login: $e');
      }
      if (e is AuthenticationException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Terjadi kesalahan tidak terduga: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> logout() async {
    try {
      if (kDebugMode) {
        print('Memulai proses logout...');
        print('1. Menghapus data dari SharedPreferences');
      }

      // Hapus data user dari SharedPreferences menggunakan konstanta
      await sharedPreferences.remove(Constants.tokenKey);
      await sharedPreferences.remove(Constants.userDataKey);

      if (kDebugMode) {
        print('2. Membersihkan database lokal');
      }

      // Bersihkan semua data lokal di SQLite
      await AppDatabase.instance.clearAllTables();

      if (kDebugMode) {
        print('Proses logout selesai');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saat logout: $e');
      }
      throw CacheException();
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final jsonString = sharedPreferences.getString(Constants.userDataKey);
      final token = sharedPreferences.getString(Constants.tokenKey);

      if (jsonString != null && token != null) {
        // Tambahkan try-catch untuk menangani error parsing JSON
        try {
          final Map<String, dynamic> userData = json.decode(jsonString);
          return UserModel.fromJson(userData, token);
        } catch (e) {
          throw AuthenticationException(message: 'Data user tidak valid');
        }
      } else {
        throw AuthenticationException(message: 'User tidak ditemukan');
      }
    } catch (e) {
      throw AuthenticationException(
          message: e is AuthenticationException
              ? e.message
              : 'User tidak ditemukan');
    }
  }
}
