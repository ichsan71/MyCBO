import 'package:equatable/equatable.dart';

class ScheduleType extends Equatable {
  final int id;
  final String nama;
  final String keterangan;

  const ScheduleType({
    required this.id,
    required this.nama,
    required this.keterangan,
  });

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'ScheduleType($id, $nama, $keterangan)';
}
