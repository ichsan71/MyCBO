import 'package:equatable/equatable.dart';

class Specialist extends Equatable {
  final int id;
  final String nama;

  const Specialist({
    required this.id,
    required this.nama,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) {
    return Specialist(
      id: json['id'],
      nama: json['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }

  @override
  List<Object?> get props => [id, nama];
}
