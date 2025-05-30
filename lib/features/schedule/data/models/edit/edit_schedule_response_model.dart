import 'package:equatable/equatable.dart';
import '../edit_schedule_data_model.dart';

class EditScheduleResponseModel extends Equatable {
  final bool status;
  final String message;
  final EditScheduleDataModel data;

  const EditScheduleResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EditScheduleResponseModel.fromJson(Map<String, dynamic> json) {
    return EditScheduleResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: EditScheduleDataModel.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }

  @override
  List<Object?> get props => [status, message, data];
}
