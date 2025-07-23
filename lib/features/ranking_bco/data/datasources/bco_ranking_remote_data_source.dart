import 'package:dio/dio.dart';
import '../models/bco_ranking_model.dart';

abstract class BcoRankingRemoteDataSource {
  Future<List<BcoRankingModel>> fetchBcoRanking({
    required String token,
    required String year,
    required String month,
  });
}

class BcoRankingRemoteDataSourceImpl implements BcoRankingRemoteDataSource {
  final Dio dio;
  BcoRankingRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BcoRankingModel>> fetchBcoRanking({
    required String token,
    required String year,
    required String month,
  }) async {
    final url =
        'https://dev-bco.businesscorporateofficer.com/api/rangking-kpi/bco/BCO/$month/$year';
    final response = await dio.get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode == 200 && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => BcoRankingModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch BCO ranking');
    }
  }
}
