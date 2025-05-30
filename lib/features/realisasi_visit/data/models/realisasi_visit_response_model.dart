import '../../domain/entities/realisasi_visit_response.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';

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
      const String _tag = 'RealisasiVisitResponseModel';
      Logger.info('realisasi_visit', 'Parsing input: $json');

      // Coba berbagai format untuk menentukan status operasi
      bool statusValue;
      if (json.containsKey('status')) {
        statusValue = json['status'] == true ||
            json['status'] == 'true' ||
            json['status'] == 1;
        Logger.info(_tag,
            'Menggunakan field status: ${json['status']} -> $statusValue');
      } else if (json.containsKey('success')) {
        statusValue = json['success'] == true ||
            json['success'] == 'true' ||
            json['success'] == 1;
        Logger.info(_tag,
            'Menggunakan field success: ${json['success']} -> $statusValue');
      } else if (json.containsKey('ok')) {
        statusValue =
            json['ok'] == true || json['ok'] == 'true' || json['ok'] == 1;
        Logger.info(
            _tag, 'Menggunakan field ok: ${json['ok']} -> $statusValue');
      } else {
        // Default nilai ke true jika response code 200 tapi tidak ada flag status/success
        statusValue = true;
        Logger.info(
            _tag, 'Tidak ada flag status/success, default ke: $statusValue');
      }

      // Ambil pesan dari berbagai kemungkinan field
      String messageValue = 'Operasi berhasil';
      if (json.containsKey('message') && json['message'] != null) {
        messageValue = json['message'].toString();
        Logger.info(_tag, 'Menggunakan field message: $messageValue');
      } else if (json.containsKey('msg') && json['msg'] != null) {
        messageValue = json['msg'].toString();
        Logger.info(_tag, 'Menggunakan field msg: $messageValue');
      } else if (json.containsKey('pesan') && json['pesan'] != null) {
        messageValue = json['pesan'].toString();
        Logger.info(_tag, 'Menggunakan field pesan: $messageValue');
      } else if (json.containsKey('response_message') &&
          json['response_message'] != null) {
        messageValue = json['response_message'].toString();
        Logger.info(_tag, 'Menggunakan field response_message: $messageValue');
      }

      Logger.info(
          _tag, 'Hasil parsing - status: $statusValue, message: $messageValue');

      return RealisasiVisitResponseModel(
        status: statusValue,
        message: messageValue,
      );
    } catch (e) {
      const String _tag = 'RealisasiVisitResponseModel';
      Logger.error(_tag, 'Error parsing: $e');
      Logger.error(_tag, 'JSON input: $json');
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
