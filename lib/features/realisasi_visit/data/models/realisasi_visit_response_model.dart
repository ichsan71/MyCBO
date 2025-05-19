import '../../domain/entities/realisasi_visit_response.dart';
import '../../../../core/error/exceptions.dart';

class RealisasiVisitResponseModel extends RealisasiVisitResponse {
  const RealisasiVisitResponseModel({
    required bool status,
    required String message,
  }) : super(
          status: status,
          message: message,
        );

  factory RealisasiVisitResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      return RealisasiVisitResponseModel(
        status: json['status'] as bool? ?? false,
        message: json['message'] as String? ?? 'Tidak ada pesan',
      );
    } catch (e) {
      throw ServerException(
          message:
              'Error parsing RealisasiVisitResponseModel: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}
