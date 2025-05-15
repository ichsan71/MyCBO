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
      final response = await dio.post(
        '${Constants.baseUrl}/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Memastikan data respons berupa Map<String, dynamic>
        Map<String, dynamic> responseData;

        if (response.data is String) {
          // Jika respons berupa string, coba parse sebagai JSON
          try {
            responseData = json.decode(response.data);
          } catch (e) {
            throw AuthenticationException(
                message: 'Format respons tidak valid');
          }
        } else if (response.data is Map<String, dynamic>) {
          // Jika sudah berupa Map, gunakan langsung
          responseData = response.data;
        } else {
          // Jika format lain, lempar exception
          throw AuthenticationException(
              message: 'Format respons tidak didukung');
        }

        if (responseData['status'] == true) {
          final token = responseData['token'];
          final userData = responseData['data'];

          // Buat UserModel dari data dan token
          final user = UserModel.fromJson(userData, token);

          // Simpan token dan data user ke SharedPreferences menggunakan konstanta
          await sharedPreferences.setString(Constants.tokenKey, token);
          await sharedPreferences.setString(
              Constants.userDataKey, json.encode(user.toJson()));

          return user;
        } else {
          throw AuthenticationException(
            message: responseData['message'] ?? 'Login gagal',
          );
        }
      } else {
        throw AuthenticationException(
          message: response.data['message'] ?? 'Login gagal',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw AuthenticationException(
          message: e.response?.data?['message'] ?? 'Login gagal',
        );
      }
      throw ServerException(
          message: e.message ?? 'Terjadi kesalahan pada server');
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
