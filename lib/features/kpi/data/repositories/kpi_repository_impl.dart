import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/features/kpi/data/models/kpi_model.dart';
import 'package:test_cbo/features/kpi/domain/repositories/kpi_repository.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';

class KpiRepositoryImpl implements KpiRepository {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  KpiRepositoryImpl({
    required this.client,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, KpiResponse>> getKpiData(
      String userId, String year, String month) async {
    try {
      final token = sharedPreferences.getString('token');
      if (token == null) {
        debugPrint('KPI Repository: Token not found in SharedPreferences');
        return const Left(ServerFailure());
      }

      final url =
          'https://dev-bco.businesscorporateofficer.com/api/my-kpi/$userId/$year/$month';
      debugPrint('KPI Repository: Fetching data from $url');

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint(
          'KPI Repository: Response status code: ${response.statusCode}');
      debugPrint('KPI Repository: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('KPI Repository - Parsed data:');
        if (jsonData['data'] != null) {
          final List<dynamic> dataList = jsonData['data'];
          for (var data in dataList) {
            if (data['grafik'] != null) {
              final List<dynamic> grafikList = data['grafik'];
              debugPrint('Grafik items count: ${grafikList.length}');
              for (var grafik in grafikList) {
                debugPrint('Label: ${grafik['label']}');
              }
            }
          }
        }
        return Right(KpiResponse.fromJson(jsonData));
      } else {
        return const Left(ServerFailure());
      }
    } on SocketException catch (e) {
      // Log detail for developer
      print('KPI Repository: SocketException: $e');
      throw Exception(
          'Tidak dapat terhubung ke server. Silakan cek koneksi Anda.');
    } on TimeoutException catch (e) {
      print('KPI Repository: TimeoutException: $e');
      throw Exception(
          'Permintaan ke server melebihi waktu tunggu. Silakan coba lagi.');
    } catch (e) {
      print('KPI Repository: Error fetching data: $e');
      throw Exception(
          'Terjadi kesalahan saat mengambil data KPI. Silakan coba lagi.');
    }
  }
}
