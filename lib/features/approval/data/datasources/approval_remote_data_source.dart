import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cbo/core/error/exceptions.dart';
import 'package:test_cbo/core/utils/constants.dart';
import 'package:test_cbo/core/utils/logger.dart';
import '../../domain/entities/approval_filter.dart';
import '../models/approval_model.dart';
import '../models/approval_response_model.dart';
import '../models/monthly_approval_model.dart';

abstract class ApprovalRemoteDataSource {
  /// Mengambil daftar persetujuan dadakan
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<ApprovalModel>> getApprovals(int userId);

  /// Mengambil daftar persetujuan bulanan
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<MonthlyApprovalModel>> getMonthlyApprovals(int userId);

  /// Memfilter daftar persetujuan
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<ApprovalModel>> filterApprovals(ApprovalFilter filter);

  /// Mengirim persetujuan dadakan (setuju atau tolak)
  /// Throws [ServerException] jika terjadi error pada server
  Future<ApprovalResponseModel> sendApproval(
    int scheduleId,
    int userId, {
    required bool isApproved,
    String? joinScheduleId,
  });

  /// Mengirim persetujuan bulanan
  /// Throws [ServerException] jika terjadi error pada server
  Future<String> sendMonthlyApproval({
    required List<int> scheduleIds,
    required List<String> scheduleJoinVisitIds,
    required int userId,
    required int userAtasanId,
    bool isRejected = false,
    String? comment,
  });

  /// Menyetujui permintaan
  /// Throws [ServerException] jika terjadi error pada server
  Future<void> approveRequest(int approvalId, String notes);

  /// Menolak permintaan
  /// Throws [ServerException] jika terjadi error pada server
  Future<void> rejectRequest(
      String idSchedule, String idRejecter, String comment);

  /// Mengambil detail persetujuan
  /// Throws [ServerException] jika terjadi error pada server
  Future<ApprovalModel> getApprovalDetail(int approvalId);

  /// Mengambil daftar rencana yang ditolak
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<RejectedSchedule>> getRejectedSchedules(int userId);
}

class ApprovalRemoteDataSourceImpl implements ApprovalRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;
  final String baseUrl;
  static const String _tag = 'ApprovalRemoteDataSource';

  ApprovalRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
    String? baseUrl,
  }) : baseUrl = baseUrl ?? Constants.baseUrl;

  @override
  Future<List<ApprovalModel>> getApprovals(int userId) async {
    Logger.info('ApprovalRemoteDataSource',
        'Mengambil data approval untuk user_id: $userId');

    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw ServerException(message: 'Token tidak ditemukan');
    }

    final url = Uri.parse('${Constants.baseUrl}/list-approval-dadakan/$userId');

    Logger.info('ApprovalRemoteDataSource', 'URL: $url');

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      Logger.info(
          'ApprovalRemoteDataSource', 'Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Logger.info(
            'ApprovalRemoteDataSource', 'Response Body: ${response.body}');
        Logger.info('ApprovalRemoteDataSource',
            'Response Structure: (status, message, data)');
        return (responseData['data'] as List)
            .map((json) => ApprovalModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(message: 'Gagal mengambil data approval');
      }
    } catch (e) {
      throw ServerException(message: 'Error: $e');
    }
  }

  @override
  Future<List<MonthlyApprovalModel>> getMonthlyApprovals(int userId) async {
    Logger.info('ApprovalRemoteDataSource',
        'Mengambil data approval bulanan untuk user_id: $userId');

    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw ServerException(message: 'Token tidak ditemukan');
    }

    final url = Uri.parse('${Constants.baseUrl}/list-approval/$userId');

    Logger.info('ApprovalRemoteDataSource', 'URL: $url');

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      Logger.info(
          'ApprovalRemoteDataSource', 'Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Logger.info(
            'ApprovalRemoteDataSource', 'Response Body: ${response.body}');
        Logger.info('ApprovalRemoteDataSource',
            'Response Structure: (status, message, data)');
        return (responseData['data'] as List)
            .map((json) => MonthlyApprovalModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(message: 'Gagal mengambil data approval bulanan');
      }
    } catch (e) {
      throw ServerException(message: 'Error: $e');
    }
  }

  @override
  Future<List<ApprovalModel>> filterApprovals(ApprovalFilter filter) async {
    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw ServerException(message: 'Token tidak ditemukan');
    }

    final queryParams = {
      if (filter.searchQuery != null) 'search': filter.searchQuery!,
      if (filter.month != null) 'month': filter.month.toString(),
      if (filter.year != null) 'year': filter.year.toString(),
      if (filter.status != null) 'status': filter.status.toString(),
      if (filter.userId != null) 'user_id': filter.userId.toString(),
    };

    final url = Uri.parse('${Constants.baseUrl}/api/filter-approval').replace(
      queryParameters: queryParams,
    );

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return (responseData['data'] as List)
            .map((json) => ApprovalModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(message: 'Gagal memfilter data approval');
      }
    } catch (e) {
      throw ServerException(message: 'Error: $e');
    }
  }

  @override
  Future<ApprovalResponseModel> sendApproval(
    int scheduleId,
    int userId, {
    required bool isApproved,
    String? joinScheduleId,
  }) async {
    Logger.info('ApprovalRemoteDataSource',
        'Mengirim persetujuan untuk schedule_id: $scheduleId');

    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw ServerException(message: 'Token tidak ditemukan');
    }

    final url = Uri.parse(
        '${Constants.baseUrl}/api/approve-schedule/$scheduleId/${isApproved ? 1 : 0}');

    final body = {
      'user_id': userId.toString(),
      if (joinScheduleId != null) 'join_schedule_id': joinScheduleId,
    };

    Logger.info('ApprovalRemoteDataSource',
        'URL request: ${url.toString()}\nBody: $body');

    try {
      final response = await client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      Logger.info('ApprovalRemoteDataSource',
          'Status response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Logger.info(
            'ApprovalRemoteDataSource', 'Response data: ${response.body}');
        return ApprovalResponseModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw ServerException(
            message: errorData['message'] ?? 'Gagal mengirim persetujuan');
      }
    } catch (e) {
      Logger.error(
          'ApprovalRemoteDataSource', 'Error saat mengirim persetujuan: $e');
      throw ServerException(message: 'Gagal mengirim persetujuan: $e');
    }
  }

  @override
  Future<void> approveRequest(int approvalId, String notes) async {
    Logger.info(_tag, 'Menyetujui permintaan dengan ID: $approvalId');

    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw ServerException(message: 'Token tidak ditemukan');
    }

    final userDataString = sharedPreferences.getString(Constants.userDataKey);
    if (userDataString == null) {
      throw UnauthorizedException(message: 'Data user tidak ditemukan');
    }

    final userData = json.decode(userDataString);
    final userId = userData['id_user'] as int;

    final url =
        Uri.parse('${Constants.baseUrl}/approved-suddenly/$approvalId/$userId');
    Logger.info(_tag, 'URL: $url');

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      Logger.info(_tag, 'Status Code: ${response.statusCode}');
      Logger.info(_tag, 'Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true || responseData['status'] == 200) {
          return;
        }
        throw ServerException(
            message: responseData['message'] ?? 'Gagal menyetujui permintaan');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message: 'Gagal menyetujui permintaan: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'approveRequest', e.toString());
      throw ServerException(message: 'Error: $e');
    }
  }

  @override
  Future<void> rejectRequest(
    String idSchedule,
    String idRejecter,
    String comment,
  ) async {
    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw ServerException(message: 'Token tidak ditemukan');
    }

    final url = Uri.parse('${Constants.baseUrl}/api/reject-request');

    try {
      final response = await client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_schedule': idSchedule,
          'id_rejecter': idRejecter,
          'comment': comment,
        }),
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Gagal menolak permintaan');
      }
    } catch (e) {
      throw ServerException(message: 'Error: $e');
    }
  }

  @override
  Future<ApprovalModel> getApprovalDetail(int approvalId) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final userDataString = sharedPreferences.getString(Constants.userDataKey);
      if (userDataString == null) {
        throw UnauthorizedException(message: 'Data user tidak ditemukan');
      }

      final userData = json.decode(userDataString);
      final userId = userData['id_user'] as int;

      final uri = Uri.parse(Constants.baseUrl).replace(
        path:
            '${Uri.parse(Constants.baseUrl).path}/list-approval-dadakan/$userId',
      );

      Logger.info(_tag, 'URL: $uri');

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Logger.info(_tag, 'Status Code: ${response.statusCode}');
      Logger.info(_tag, 'Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (!jsonResponse.containsKey('data')) {
          throw ServerException(
              message: 'Format response tidak valid: data tidak ditemukan');
        }

        return ApprovalModel.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message: 'Gagal memuat detail persetujuan: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'getApprovalDetail', e.toString());
      rethrow;
    }
  }

  @override
  Future<List<RejectedSchedule>> getRejectedSchedules(int userId) async {
    final token = sharedPreferences.getString(Constants.tokenKey);
    final uri = Uri.parse(
        'https://dev-bco.businesscorporateofficer.com/api/list-rejected-schedule/$userId');
    final response = await client.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data']['data'];
      return data.map((e) => RejectedSchedule.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load rejected schedules');
    }
  }

  @override
  Future<String> sendMonthlyApproval({
    required List<int> scheduleIds,
    required List<String> scheduleJoinVisitIds,
    required int userId,
    required int userAtasanId,
    bool isRejected = false,
    String? comment,
  }) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final uri = Uri.parse(Constants.baseUrl).replace(
        path: '${Uri.parse(Constants.baseUrl).path}/approved-monthly',
      );

      Logger.info(_tag, 'Mengirim persetujuan bulanan');
      Logger.info(_tag, 'URL: $uri');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['id_schedule'] = json.encode(scheduleIds);
      request.fields['id_schedule_join_visit'] =
          json.encode(scheduleJoinVisitIds);
      request.fields['id_user'] = userId.toString();
      request.fields['id_user_atasan'] = userAtasanId.toString();
      request.fields['is_rejected'] = isRejected.toString();
      if (comment != null) {
        request.fields['comment'] = comment;
      }

      Logger.info(_tag, 'Request fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Logger.info(_tag, 'Status Code: ${response.statusCode}');
      Logger.info(_tag, 'Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return 'Persetujuan berhasil dikirim';
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message:
                jsonDecode(response.body)['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      Logger.error(_tag, 'sendMonthlyApproval', e.toString());
      throw ServerException(message: e.toString());
    }
  }
}

class RejectedSchedule {
  final int id;
  final String draft;
  final String namaUser;
  final String tipeSchedule;
  final String tujuan;
  final String kodeRayon;
  final String kodeRayonAktif;
  final String tglVisit;
  final String namaProduct;
  final String note;
  final String createdAt;
  final String tglSubmitSchedule;
  final int approved;
  final String shift;
  final String jenis;
  final String namaTujuan;
  final String statusCheckin;
  final String namaDivisi;
  final String namaSpesialis;
  final String namaRejecter;
  final dynamic historyReject;

  RejectedSchedule({
    required this.id,
    required this.draft,
    required this.namaUser,
    required this.tipeSchedule,
    required this.tujuan,
    required this.kodeRayon,
    required this.kodeRayonAktif,
    required this.tglVisit,
    required this.namaProduct,
    required this.note,
    required this.createdAt,
    required this.tglSubmitSchedule,
    required this.approved,
    required this.shift,
    required this.jenis,
    required this.namaTujuan,
    required this.statusCheckin,
    required this.namaDivisi,
    required this.namaSpesialis,
    required this.namaRejecter,
    required this.historyReject,
  });

  factory RejectedSchedule.fromJson(Map<String, dynamic> json) {
    return RejectedSchedule(
      id: json['id'],
      draft: json['draft'],
      namaUser: json['nama_user'],
      tipeSchedule: json['tipe_schedule'],
      tujuan: json['tujuan'],
      kodeRayon: json['kode_rayon'],
      kodeRayonAktif: json['kode_rayon_aktif'],
      tglVisit: json['tgl_visit'],
      namaProduct: json['nama_product'],
      note: json['note'],
      createdAt: json['created_at'],
      tglSubmitSchedule: json['tgl_submit_schedule'],
      approved: json['approved'],
      shift: json['shift'],
      jenis: json['jenis'],
      namaTujuan: json['nama_tujuan'],
      statusCheckin: json['status_checkin'],
      namaDivisi: json['nama_divisi'],
      namaSpesialis: json['nama_spesialis'],
      namaRejecter: json['nama_rejecter'],
      historyReject: json['history_reject'],
    );
  }
}
