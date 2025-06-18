import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/kpi_model.dart';
import '../../domain/entities/kpi_member.dart';
import 'package:flutter/foundation.dart';

abstract class KpiMemberRemoteDataSource {
  Future<List<KpiMember>> getKpiMemberData(String year, String month);
}

class KpiMemberRemoteDataSourceImpl implements KpiMemberRemoteDataSource {
  final Dio dio;
  final SharedPreferences sharedPreferences;
  static const String baseUrl = 'https://dev-bco.businesscorporateofficer.com/api';

  KpiMemberRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  @override
  Future<List<KpiMember>> getKpiMemberData(String year, String month) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      final userId = sharedPreferences.getString(Constants.userIdKey);

      if (token == null) {
        throw AuthenticationException(message: 'Token not found');
      }

      if (userId == null) {
        throw AuthenticationException(message: 'User ID not found');
      }

      debugPrint('KPI Member Repository: Fetching data from $baseUrl/my-kpi/$userId/$year/$month');

      final response = await dio.get(
        '$baseUrl/my-kpi/$userId/$year/$month',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('KPI Member Repository: Response status code: ${response.statusCode}');
      debugPrint('KPI Member Repository: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true && data['data_kpi_bawahan'] != null) {
          final List<dynamic> bawahanList = data['data_kpi_bawahan'];
          List<KpiMember> kpiMembers = [];

          for (var bawahan in bawahanList) {
            if (bawahan['grafik'] != null) {
              final List<dynamic> grafikList = bawahan['grafik'];
              final kpiGrafikList = grafikList.map((item) => KpiGrafik.fromJson(item)).toList();
              
              kpiMembers.add(KpiMember(
                kodeRayon: bawahan['kode_rayon'] ?? 'Unknown',
                grafik: kpiGrafikList,
              ));
            }
          }

          return kpiMembers;
        }
        return [];
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch KPI member data',
        );
      }
    } on DioException catch (e) {
      debugPrint('KPI Member Repository: DioException: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw AuthenticationException(message: 'Unauthorized');
      }
      throw ServerException(
        message: e.message ?? 'Failed to fetch KPI member data',
      );
    } catch (e) {
      debugPrint('KPI Member Repository: Error: $e');
      throw ServerException(
        message: e.toString(),
      );
    }
  }
} 