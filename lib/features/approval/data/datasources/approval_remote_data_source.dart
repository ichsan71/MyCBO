 import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cbo/core/error/exceptions.dart';
import 'package:test_cbo/core/network/api_config.dart';
import 'package:test_cbo/core/network/api_helper.dart';
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

  /// Mengambil detail persetujuan bulanan untuk GM
  /// Throws [ServerException] jika terjadi error pada server
  Future<dynamic> getMonthlyApprovalDetailGM(int userId, int year, int month);

  /// Mengambil detail persetujuan dadakan untuk GM
  /// Throws [ServerException] jika terjadi error pada server
  Future<dynamic> getSuddenlyApprovalDetailGM(int userId, int year, int month);

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

  /// Helper method to check if current user is GM
  bool _isCurrentUserGM() {
    try {
      final userDataString = sharedPreferences.getString(Constants.userDataKey);
      if (userDataString == null) {
        Logger.warning(_tag, 'User data not found in SharedPreferences');
        return false;
      }

      final userData = json.decode(userDataString);
      if (userData == null) {
        Logger.warning(
            _tag, 'Failed to decode user data from SharedPreferences');
        return false;
      }

      if (!userData.containsKey('role')) {
        Logger.warning(_tag, 'Role field not found in user data');
        return false;
      }

      final role = userData['role']?.toString().toUpperCase() ?? '';
      Logger.info(_tag, 'Current user role: $role');

      if (role.isEmpty) {
        Logger.warning(_tag, 'Role is empty');
        return false;
      }

      return role == 'GM';
    } catch (e) {
      Logger.error(_tag, 'Error checking user role: $e');
      return false;
    }
  }

  /// Helper method to get current user ID from SharedPreferences
  int _getCurrentUserId() {
    try {
      final userDataString = sharedPreferences.getString(Constants.userDataKey);
      if (userDataString == null)
        throw ServerException(message: 'Data user tidak ditemukan');

      final userData = json.decode(userDataString);
      return userData['id_user'] as int;
    } catch (e) {
      Logger.error(_tag, 'Error getting user ID: $e');
      throw ServerException(message: 'Gagal mendapatkan data user');
    }
  }

  @override
  Future<List<ApprovalModel>> getApprovals(int userId) async {
    Logger.info(_tag, 'Mengambil data approval untuk user_id: $userId');

    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw ServerException(message: 'Token tidak ditemukan');
    }

    // Check if current user is GM and use appropriate URL
    final isGM = _isCurrentUserGM();
    final url = isGM
        ? Uri.parse('${Constants.baseUrl}/list-suddenly-gm')
        : Uri.parse('${Constants.baseUrl}/list-approval-dadakan/$userId');

    Logger.info(_tag, 'URL: $url (GM Mode: $isGM)');

    try {
      final response = await ApiHelper.retryRequest(() => client.get(
            url,
            headers: ApiConfig.getHeaders(token),
          ));

      Logger.info(_tag, 'Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Logger.info(_tag, 'Raw Response: ${response.body}');

        if (data['status'] == true || data['status'] == 200) {
          // Handle different response structures between GM and non-GM
          List<dynamic> approvalList;

          if (isGM) {
            // GM response has paginated structure: data.data
            final Map<String, dynamic> responseData = data['data'];
            approvalList = responseData['data'] as List;
          } else {
            // Non-GM response has direct array: data
            approvalList = data['data'] as List;
          }

          Logger.info(_tag,
              'Approval List Structure: ${approvalList.map((item) => item.runtimeType).toList()}');

          List<ApprovalModel> result = [];
          for (var json in approvalList) {
            try {
              Logger.info(_tag, 'Processing approval item: $json');

              final approvalJson = Map<String, dynamic>.from(json);
              approvalJson['id'] = approvalJson['id_user'];
              approvalJson['user_id'] = approvalJson['id_user'];

              final approval = ApprovalModel.fromJson(approvalJson);
              result.add(approval);
            } catch (e, stackTrace) {
              Logger.error(_tag,
                  'Error parsing approval item: $e\nStack trace: $stackTrace');
              Logger.error(_tag, 'Problematic JSON: $json');
              rethrow;
            }
          }
          return result;
        }
        throw ServerException(
            message: data['message'] ?? 'Gagal mengambil data persetujuan');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        throw ServerException(
            message:
                'Gagal mengambil data persetujuan: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      Logger.error(_tag, 'Error: $e\nStack trace: $stackTrace');
      if (e is ServerException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MonthlyApprovalModel>> getMonthlyApprovals(int userId) async {
    Logger.info(_tag, 'Mengambil data approval bulanan untuk user_id: $userId');

    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw ServerException(message: 'Token tidak ditemukan');
    }

    // Check if current user is GM and use appropriate URL
    final isGM = _isCurrentUserGM();
    final url = isGM
        ? Uri.parse('${Constants.baseUrl}/list-approval-gm')
        : Uri.parse('${Constants.baseUrl}/list-approval/$userId');

    Logger.info(_tag, 'URL: $url (GM Mode: $isGM)');

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      Logger.info(_tag, 'Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Logger.info(_tag, 'Response Body: ${response.body}');
        Logger.info(_tag, 'Response Structure: (status, message, data)');
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
    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw ServerException(message: 'Token tidak ditemukan');
    }

    // Check if current user is GM and use appropriate URL
    final isGM = _isCurrentUserGM();
    final Uri url;

    if (isGM && isApproved) {
      // For GM approval (GET method)
      final currentUserId = _getCurrentUserId();
      url = Uri.parse(
          '${Constants.baseUrl}/approval-gm-suddenly/$scheduleId/$currentUserId');
    } else {
      // For regular users or non-approval actions
      url = Uri.parse(
          '${Constants.baseUrl}/api/approve-schedule/$scheduleId/${isApproved ? 1 : 0}');
    }

    Logger.info(_tag,
        'URL request: ${url.toString()} (GM Mode: $isGM, Approved: $isApproved)');

    try {
      if (isGM && isApproved) {
        // GM approval uses GET method
        final response = await ApiHelper.retryRequest(() => client.get(
              url,
              headers: ApiConfig.getHeaders(token),
            ));

        Logger.info(_tag, 'Status response: ${response.statusCode}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          Logger.info(_tag, 'Response data: ${response.body}');
          return ApprovalResponseModel.fromJson(responseData);
        } else {
          final errorData = jsonDecode(response.body);
          throw ServerException(
              message: errorData['message'] ?? 'Gagal mengirim persetujuan');
        }
      } else {
        // Regular users use POST method
        final body = {
          'user_id': userId.toString(),
          if (joinScheduleId != null) 'join_schedule_id': joinScheduleId,
        };

        Logger.info(_tag, 'Body: $body');

        final response = await ApiHelper.retryRequest(() => client.post(
              url,
              headers: ApiConfig.getHeaders(token),
              body: jsonEncode(body),
            ));

        Logger.info(_tag, 'Status response: ${response.statusCode}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          Logger.info(_tag, 'Response data: ${response.body}');
          return ApprovalResponseModel.fromJson(responseData);
        } else {
          final errorData = jsonDecode(response.body);
          throw ServerException(
              message: errorData['message'] ?? 'Gagal mengirim persetujuan');
        }
      }
    } catch (e) {
      Logger.error(_tag, 'Error saat mengirim persetujuan: $e');
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
    Logger.info(_tag, 'Rejecting request with ID: $idSchedule');

    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw ServerException(message: 'Token tidak ditemukan');
    }

    // Check if current user is GM and use appropriate URL
    final isGM = _isCurrentUserGM();
    final url = isGM
        ? Uri.parse('${Constants.baseUrl}/reject-gm-suddenly')
        : Uri.parse('${Constants.baseUrl}/reject-suddenly');

    Logger.info(_tag, 'URL: $url (GM Mode: $isGM)');

    try {
      final response = await client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: isGM
            ? {
                'id_schedule': idSchedule,
                'id_approver': idRejecter,
                'comment': comment,
              }
            : {
                'id_schedule': idSchedule,
                'id_rejecter': idRejecter,
                'comment': comment,
              },
      );

      Logger.info(_tag, 'Status Code: ${response.statusCode}');
      Logger.info(_tag, 'Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          Logger.success(_tag, 'Request rejected successfully');
          return;
        }
        throw ServerException(
            message: responseData['message'] ?? 'Gagal menolak permintaan');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        Logger.error(_tag, 'Error response',
            'Status: ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            message: 'Gagal menolak permintaan: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'rejectRequest', e.toString());
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
  Future<dynamic> getMonthlyApprovalDetailGM(
      int userId, int year, int month) async {
    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw ServerException(message: 'Token tidak ditemukan');
    }

    final uri = Uri.parse(
        '${Constants.baseUrl}/detail-list-approval-gm/$userId/$year/$month');

    Logger.info(_tag, 'Fetching monthly approval detail for GM');
    Logger.info(_tag, 'URL: $uri');

    try {
      final response = await client.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      Logger.info(_tag, 'Status Code: ${response.statusCode}');
      Logger.info(_tag, 'Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data'];
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        throw ServerException(
            message:
                'Gagal mengambil detail approval GM: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'getMonthlyApprovalDetailGM', e.toString());
      throw ServerException(message: 'Error: $e');
    }
  }

  @override
  Future<dynamic> getSuddenlyApprovalDetailGM(
      int userId, int year, int month) async {
    final token = sharedPreferences.getString(Constants.tokenKey);
    if (token == null) {
      throw ServerException(message: 'Token tidak ditemukan');
    }

    final uri = Uri.parse(
        '${Constants.baseUrl}/detail-list-suddenly-gm/$userId/$year/$month');

    Logger.info(_tag, 'Fetching suddenly approval detail for GM');
    Logger.info(_tag, 'URL: $uri');

    try {
      final response = await client.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      Logger.info(_tag, 'Status Code: ${response.statusCode}');
      Logger.info(_tag, 'Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data'];
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Sesi telah berakhir');
      } else {
        throw ServerException(
            message:
                'Gagal mengambil detail approval dadakan GM: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error(_tag, 'getSuddenlyApprovalDetailGM', e.toString());
      throw ServerException(message: 'Error: $e');
    }
  }

  @override
  Future<List<RejectedSchedule>> getRejectedSchedules(int userId) async {
    final token = sharedPreferences.getString(Constants.tokenKey);
    final uri = Uri.parse(
        'https://dev-bco.businesscorporateofficer.com/api/list-rejected-schedule/$userId');

    Logger.info(_tag, 'Fetching rejected schedules for user $userId');

    final response = await client.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    Logger.info(_tag, 'Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      Logger.info(_tag, 'Response body: ${response.body}');

      final List<dynamic> data = jsonResponse['data']['data'];
      Logger.info(_tag, 'Found ${data.length} rejected schedules');

      final result = data.map((e) {
        try {
          return RejectedSchedule.fromJson(e);
        } catch (error) {
          Logger.error(_tag, 'Error parsing schedule: $error');
          Logger.error(_tag, 'Problematic data: $e');
          rethrow;
        }
      }).toList();

      Logger.success(
          _tag, 'Successfully parsed ${result.length} rejected schedules');
      return result;
    } else {
      Logger.error(
          _tag, 'Failed to load rejected schedules: ${response.statusCode}');
      Logger.error(_tag, 'Response body: ${response.body}');
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

      // Check if current user is GM and use appropriate URL
      final isGM = _isCurrentUserGM();
      final Uri uri;

      if (isGM) {
        if (isRejected) {
          // GM rejection uses different endpoint
          uri = Uri.parse('${Constants.baseUrl}/reject-gm-monthly');
        } else {
          // GM approval endpoint
          uri = Uri.parse('${Constants.baseUrl}/approval-gm-monthly');
        }
      } else {
        // Regular users
        uri = Uri.parse(Constants.baseUrl).replace(
          path: '${Uri.parse(Constants.baseUrl).path}/approved-monthly',
        );
      }

      Logger.info(_tag,
          'Mengirim persetujuan bulanan (GM Mode: $isGM, Rejected: $isRejected)');
      Logger.info(_tag, 'URL: $uri');

      if (isGM) {
        // GM uses form-data with different field names
        final Map<String, String> body = isRejected
            ? {
                // For reject, send as array with single item to match backend expectation
                'id_schedule': json
                    .encode(scheduleIds.map((id) => id.toString()).toList()),
                'id_approver': _getCurrentUserId().toString(),
                'comment': comment ?? '',
              }
            : {
                'id_schedule': json
                    .encode(scheduleIds.map((id) => id.toString()).toList()),
                'id_approver': _getCurrentUserId().toString(),
              };

        Logger.info(_tag, 'GM Request body: $body');

        final response = await client.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: body,
        );

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
      } else {
        // Regular users use multipart request
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
      id: json['id'] ?? 0,
      draft: json['draft']?.toString() ?? '',
      namaUser: json['nama_user']?.toString() ?? '',
      tipeSchedule: json['tipe_schedule']?.toString() ?? '',
      tujuan: json['tujuan']?.toString() ?? '',
      kodeRayon: json['kode_rayon']?.toString() ?? '',
      kodeRayonAktif: json['kode_rayon_aktif']?.toString() ?? '',
      tglVisit: json['tgl_visit']?.toString() ?? '',
      namaProduct: json['nama_product']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      tglSubmitSchedule: json['tgl_submit_schedule']?.toString() ?? '',
      approved: json['approved'] ?? 0,
      shift: json['shift']?.toString() ?? '',
      jenis: json['jenis']?.toString() ?? '',
      namaTujuan: json['nama_tujuan']?.toString() ?? '',
      statusCheckin: json['status_checkin']?.toString() ?? '',
      namaDivisi: json['nama_divisi']?.toString() ?? '',
      namaSpesialis: json['nama_spesialis']?.toString() ?? '',
      namaRejecter: json['nama_rejecter']?.toString() ?? '',
      historyReject: json['history_reject'],
    );
  }
}
