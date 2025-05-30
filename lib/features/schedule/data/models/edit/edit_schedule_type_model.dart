import 'package:equatable/equatable.dart';

class EditScheduleTypeModel extends Equatable {
  final int id;
  final String name;
  final String? createdAt;

  const EditScheduleTypeModel({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory EditScheduleTypeModel.fromJson(Map<String, dynamic> json) {
    return EditScheduleTypeModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, name, createdAt];
} 