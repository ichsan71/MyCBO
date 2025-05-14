import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int idUser;
  final String name;
  final String email;
  final String role;
  final String kodeRayon;
  final String idDivisi;
  final String kodeRayonAktif;
  final String token;

  const User({
    required this.idUser,
    required this.name,
    required this.email,
    required this.role,
    required this.kodeRayon,
    required this.idDivisi,
    required this.kodeRayonAktif,
    required this.token,
  });

  @override
  List<Object?> get props =>
      [idUser, name, email, role, kodeRayon, idDivisi, kodeRayonAktif, token];
}
