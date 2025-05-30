import '../../domain/entities/tipe_schedule.dart';

class TipeScheduleModel extends TipeSchedule {
  const TipeScheduleModel({
    required int id,
    required String name,
    String? createdAt,
  }) : super(
          id: id,
          name: name,
          createdAt: createdAt,
        );

  factory TipeScheduleModel.fromJson(Map<String, dynamic> json) {
    return TipeScheduleModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      createdAt: json['created_at'],
    );
  }

  static List<TipeScheduleModel> fromJsonList(List<dynamic> list) {
    return list.map((json) => TipeScheduleModel.fromJson(json)).toList();
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
