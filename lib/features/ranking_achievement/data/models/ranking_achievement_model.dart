import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RankingAchievementResponse {
  final bool status;
  final String role;
  final List<RankingAchievementData> data;

  RankingAchievementResponse({
    required this.status,
    required this.role,
    required this.data,
  });

  factory RankingAchievementResponse.fromJson(Map<String, dynamic> json) {
    debugPrint(
        'RankingAchievementResponse parsing - status: ${json['status']}');
    debugPrint('RankingAchievementResponse parsing - role: ${json['role']}');

    try {
      return RankingAchievementResponse(
        status: json['status'] as bool? ?? false,
        role: json['role'] as String? ?? '',
        data: (json['data'] as List?)
                ?.map((data) => RankingAchievementData.fromJson(data))
                .toList() ??
            [],
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing RankingAchievementResponse: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  RankingAchievementResponse copyWith({
    bool? status,
    String? role,
    List<RankingAchievementData>? data,
  }) {
    return RankingAchievementResponse(
      status: status ?? this.status,
      role: role ?? this.role,
      data: data ?? List.from(this.data),
    );
  }
}

class RankingAchievementData extends Equatable {
  final int idUser;
  final String nama;
  final String kodeRayon;
  final Map<String, String> monthlyAchievements;

  const RankingAchievementData({
    required this.idUser,
    required this.nama,
    required this.kodeRayon,
    required this.monthlyAchievements,
  });

  factory RankingAchievementData.fromJson(Map<String, dynamic> json) {
    debugPrint(
        'RankingAchievementData parsing - idUser: ${json['id_user']}, nama: ${json['nama']}');

    try {
      final Map<String, String> achievements = {};

      // Extract monthly achievements (01-12)
      for (int i = 1; i <= 12; i++) {
        final monthKey = i.toString().padLeft(2, '0');
        final value = json[monthKey];
        achievements[monthKey] = value?.toString() ?? '-';
      }

      return RankingAchievementData(
        idUser: json['id_user'] as int? ?? 0,
        nama: json['nama'] as String? ?? '',
        kodeRayon: json['kode_rayon'] as String? ?? '',
        monthlyAchievements: achievements,
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing RankingAchievementData: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  RankingAchievementData copyWith({
    int? idUser,
    String? nama,
    String? kodeRayon,
    Map<String, String>? monthlyAchievements,
  }) {
    return RankingAchievementData(
      idUser: idUser ?? this.idUser,
      nama: nama ?? this.nama,
      kodeRayon: kodeRayon ?? this.kodeRayon,
      monthlyAchievements:
          monthlyAchievements ?? Map.from(this.monthlyAchievements),
    );
  }

  @override
  List<Object?> get props => [idUser, nama, kodeRayon, monthlyAchievements];
}
