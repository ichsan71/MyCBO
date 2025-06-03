import '../../domain/entities/approval_response.dart';

class ApprovalResponseModel extends ApprovalResponse {
  const ApprovalResponseModel({
    required bool success,
    required String message,
  }) : super(
          success: success,
          message: message,
        );

  factory ApprovalResponseModel.fromJson(Map<String, dynamic> json) {
    return ApprovalResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
