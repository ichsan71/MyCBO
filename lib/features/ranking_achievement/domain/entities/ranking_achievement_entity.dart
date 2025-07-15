import 'package:equatable/equatable.dart';

class RankingAchievementEntity extends Equatable {
  final int idUser;
  final String nama;
  final String kodeRayon;
  final Map<String, String> monthlyAchievements;

  const RankingAchievementEntity({
    required this.idUser,
    required this.nama,
    required this.kodeRayon,
    required this.monthlyAchievements,
  });

  @override
  List<Object?> get props => [idUser, nama, kodeRayon, monthlyAchievements];
}
