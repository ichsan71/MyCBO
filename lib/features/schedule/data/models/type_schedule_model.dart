import '../../domain/entities/type_schedule.dart';

class TypeScheduleModel extends TypeSchedule {
  const TypeScheduleModel({
    required int id,
    required String name,
    String? createdAt,
  }) : super(
          id: id,
          name: name,
          createdAt: createdAt ?? '',
        );

  factory TypeScheduleModel.fromJson(Map<String, dynamic> json) {
    return TypeScheduleModel(
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
}
