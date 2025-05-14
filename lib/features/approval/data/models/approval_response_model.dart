import '../../domain/entities/approval_response.dart';

class ApprovalResponseModel extends ApprovalResponse {
  const ApprovalResponseModel({
    required int status,
    required String message,
  }) : super(
          status: status,
          message: message,
        );

  factory ApprovalResponseModel.fromJson(Map<String, dynamic> json) {
    return ApprovalResponseModel(
      status: json['status'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}
