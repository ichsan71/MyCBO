import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member_kpi_model.dart';
import '../../../../core/utils/constants.dart';

abstract class MemberKpiRemoteDataSource {
  Future<List<MemberKpiModel>> fetchMemberKpiRanking({
    required int bcoId,
    required String year,
    required String month,
  });
}

class MemberKpiRemoteDataSourceImpl implements MemberKpiRemoteDataSource {
  final Dio dio;
  MemberKpiRemoteDataSourceImpl(this.dio);

  @override
  Future<List<MemberKpiModel>> fetchMemberKpiRanking({
    required int bcoId,
    required String year,
    required String month,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constants.tokenKey) ?? '';
    if (token.isEmpty) {
      throw Exception(
          'Barrier token tidak ditemukan di SharedPreferences. Pastikan sudah login dan token tersimpan.');
    }
    print('[DEBUG] Barrier token: $token');
    final url =
        'https://dev-bco.businesscorporateofficer.com/api/my-kpi/$bcoId/$year/$month';
    final response = await dio.get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode == 200 && response.data['status'] == true) {
      final List<dynamic> data = response.data['data_kpi_bawahan'] ?? [];
      return data.map((e) => MemberKpiModel.fromJson(e)).toList();
    } else {
      throw Exception(
          response.data['message'] ?? 'Gagal mengambil data anggota');
    }
  }
}
