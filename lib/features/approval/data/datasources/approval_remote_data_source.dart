import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/approval_filter.dart';
import '../models/approval_model.dart';
import '../models/approval_response_model.dart';

abstract class ApprovalRemoteDataSource {
  /// Mengambil daftar persetujuan
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<ApprovalModel>> getApprovals(int userId);

  /// Memfilter daftar persetujuan
  /// Throws [ServerException] jika terjadi error pada server
  Future<List<ApprovalModel>> filterApprovals(ApprovalFilter filter);

  /// Mengirim persetujuan (setuju atau tolak)
  /// Throws [ServerException] jika terjadi error pada server
  Future<ApprovalResponseModel> sendApproval(int scheduleId, int userId,
      {required bool isApproved});

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
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/list-approval-dadakan/$userId',
      );

      Logger.info(_tag, 'Mengambil data approval untuk user_id: $userId');
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

        Logger.info(_tag, 'Response Structure: ${jsonResponse.keys}');

        if (!jsonResponse.containsKey('data')) {
          throw ServerException(
              message: 'Format response tidak valid: data tidak ditemukan');
        }

        final data = jsonResponse['data'];
        if (data is! List) {
          throw ServerException(
              message: 'Format response tidak valid: data bukan array');
        }

        final List<dynamic> approvalsJson = data;
        return approvalsJson
            .map((json) => ApprovalModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message: 'Gagal memuat data persetujuan: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'getApprovals', e.toString());
      rethrow;
    }
  }

  @override
  Future<List<ApprovalModel>> filterApprovals(ApprovalFilter filter) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final queryParams = <String, String>{};
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        queryParams['search'] = filter.searchQuery!;
      }
      if (filter.month != null) {
        queryParams['month'] = filter.month.toString();
      }
      if (filter.year != null) {
        queryParams['year'] = filter.year.toString();
      }
      if (filter.status != null) {
        queryParams['status'] = filter.status.toString();
      }
      if (filter.userId != null) {
        queryParams['user_id'] = filter.userId.toString();
      }

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/list-approval-dadakan',
        queryParameters: queryParams,
      );

      Logger.info(
          _tag, 'Memfilter data approval dengan parameter: $queryParams');
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

        final data = jsonResponse['data'];
        if (data is! List) {
          throw ServerException(
              message: 'Format response tidak valid: data bukan array');
        }

        final List<dynamic> approvalsJson = data;
        return approvalsJson
            .map((json) => ApprovalModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message:
                'Gagal memfilter data persetujuan: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'filterApprovals', e.toString());
      rethrow;
    }
  }

  @override
  Future<ApprovalResponseModel> sendApproval(int scheduleId, int userId,
      {required bool isApproved}) async {
    try {
      final token = sharedPreferences.getString(Constants.tokenKey);
      if (token == null) {
        throw UnauthorizedException(message: 'Token tidak ditemukan');
      }

      final uri = Uri.parse(baseUrl).replace(
        path:
            '${Uri.parse(baseUrl).path}/approved-suddenly/$scheduleId/$userId',
        queryParameters: {
          'is_approved': isApproved.toString(),
        },
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
        return ApprovalResponseModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message: 'Gagal mengirim persetujuan: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'sendApproval', e.toString());
      rethrow;
    }
  }

  @override
  Future<void> approveRequest(int approvalId, String notes) async {
    await sendApproval(approvalId, approvalId, isApproved: true);
  }

  @override
  Future<void> rejectRequest(
      String idSchedule, String idRejecter, String comment) async {
    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw UnauthorizedException(message: 'Token tidak ditemukan');
    }

    final uri = Uri.parse(
        'https://dev-bco.businesscorporateofficer.com/api/reject-suddenly');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['id_schedule'] = idSchedule;
    request.fields['id_rejecter'] = idRejecter;
    request.fields['comment'] = comment;

    Logger.info(_tag,
        '[LOG] Akan mengirim request reject ke $uri dengan jadwal: $idSchedule, rejecter: $idRejecter, comment: $comment');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    Logger.info(_tag, 'Status Code: \\${response.statusCode}');
    Logger.info(_tag, 'Response Body: \\${response.body}');

    if (response.statusCode == 200) {
      Logger.info(
          _tag, '[LOG] API reject berhasil di-hit dan response sukses.');
    } else {
      Logger.error(_tag,
          '[LOG] API reject di-hit, namun response gagal: Status \\${response.statusCode}, Body: \\${response.body}');
    }

    if (response.statusCode != 200) {
      throw ServerException(
          message:
              'Gagal melakukan reject: Status \\${response.statusCode}, Body: \\${response.body}');
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

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/list-approval-dadakan/$userId',
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
