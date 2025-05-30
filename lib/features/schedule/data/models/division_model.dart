import 'package:equatable/equatable.dart';

class Division extends Equatable {
  final int id;
  final String nama;

  const Division({
    required this.id,
    required this.nama,
  });

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
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
