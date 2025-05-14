import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.idUser,
    required super.name,
    required super.email,
    required super.role,
    required super.kodeRayon,
    required super.idDivisi,
    required super.kodeRayonAktif,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    return UserModel(
      idUser: json['id_user'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      kodeRayon: json['kode_rayon'],
      idDivisi: json['id_divisi'],
      kodeRayonAktif: json['kode_rayon_aktif'],
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'name': name,
      'email': email,
      'role': role,
      'kode_rayon': kodeRayon,
      'id_divisi': idDivisi,
      'kode_rayon_aktif': kodeRayonAktif,
      'token': token,
    };
  }
}
