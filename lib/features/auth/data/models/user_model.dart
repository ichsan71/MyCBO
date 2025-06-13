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
    // Convert role to string if it's an integer
    final role = json['role']?.toString() ?? '';

    // Handle khusus untuk role GM yang memiliki struktur respons berbeda
    if (role.toUpperCase() == 'GM') {
      return UserModel(
        idUser: json['id_user'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: role,
        kodeRayon:
            json['kode_rayon']?.toString() ?? 'GM_RAYON', // Convert to string
        idDivisi: json['id_divisi']?.toString() ?? '',
        kodeRayonAktif: json['kode_rayon_aktif']?.toString() ??
            'GM_RAYON_AKTIF',
        token: token,
      );
    }

    // Untuk role lainnya, gunakan normal parsing
    return UserModel(
      idUser: json['id_user'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: role,
      kodeRayon: json['kode_rayon']?.toString() ?? '', // Convert to string
      idDivisi: json['id_divisi']?.toString() ?? '',
      kodeRayonAktif: json['kode_rayon_aktif']?.toString() ?? '',
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
