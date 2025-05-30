import 'package:equatable/equatable.dart';

class TipeSchedule extends Equatable {
  final int id;
  final String name;
  final String? createdAt;

  const TipeSchedule({
    required this.id,
    required this.name,
    this.createdAt,
  });

  String get nameTipeSchedule => name;

  @override
  List<Object?> get props => [id, name, createdAt];
}
