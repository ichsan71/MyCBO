import 'package:equatable/equatable.dart';

class TypeSchedule extends Equatable {
  final int id;
  final String name;
  final String? createdAt;

  const TypeSchedule({
    required this.id,
    required this.name,
    this.createdAt,
  });

  String get nameTipeSchedule => name;

  @override
  List<Object?> get props => [id, name, createdAt];
}
