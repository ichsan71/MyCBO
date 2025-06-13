import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/data/models/doctor_clinic_model.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic_base.dart';

class DoctorResponse {
  final List<DoctorClinicBase> dokter;
  final List<dynamic> klinik;

  DoctorResponse({
    required this.dokter,
    required this.klinik,
  });

  factory DoctorResponse.fromJson(Map<String, dynamic> json) {
    try {
      Logger.info('DoctorResponse', 'Starting to parse doctor response');
      Logger.info('DoctorResponse', 'Available keys: ${json.keys.toList()}');
      Logger.debug('DoctorResponse', 'Raw response: $json');

      List<DoctorClinicBase> dokterList = [];
      List<dynamic> klinikList = [];

      // First try to get data from the root level
      var doctorData = json['data'] ?? json['dokter'] ?? json['result'];

      // If no data found at root level, check if it's nested under 'data_dokter'
      if (doctorData == null && json['data_dokter'] != null) {
        doctorData = json['data_dokter']['dokter'] ?? json['data_dokter'];
      }

      // If still no data found, log warning and create empty response
      if (doctorData == null) {
        Logger.warning('DoctorResponse', 'No doctor data found in response');
        Logger.debug(
            'DoctorResponse', 'Response structure: ${json.keys.toList()}');
        return DoctorResponse(dokter: [], klinik: []);
      }

      // Log the structure of found data
      Logger.info('DoctorResponse',
          'Found doctor data of type: ${doctorData.runtimeType}');

      // Parse doctor data based on its type
      if (doctorData is List) {
        Logger.info('DoctorResponse',
            'Processing list of ${doctorData.length} doctors');

        dokterList = doctorData
            .map((item) {
              try {
                if (item is Map<String, dynamic>) {
                  Logger.debug('DoctorResponse',
                      'Processing doctor item: ${item['nama_dokter'] ?? item['nama']}');
                  return DoctorClinicModel.fromJson(item);
                } else {
                  Logger.error(
                      'DoctorResponse', 'Invalid doctor item format: $item');
                  return null;
                }
              } catch (e) {
                Logger.error('DoctorResponse', 'Error parsing doctor item: $e');
                Logger.error('DoctorResponse', 'Problematic data: $item');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<DoctorClinicBase>()
            .toList();
      } else if (doctorData is Map<String, dynamic>) {
        Logger.info('DoctorResponse', 'Processing single doctor object');
        try {
          final model = DoctorClinicModel.fromJson(doctorData);
          dokterList = [model];
        } catch (e) {
          Logger.error('DoctorResponse', 'Error parsing single doctor: $e');
          Logger.error('DoctorResponse', 'Doctor data: $doctorData');
        }
      } else {
        Logger.error('DoctorResponse',
            'Unexpected doctor data format: ${doctorData.runtimeType}');
      }

      // Process clinic data if available
      if (json['klinik'] != null) {
        Logger.info('DoctorResponse', 'Found clinic data');
        if (json['klinik'] is List) {
          klinikList = json['klinik'];
          Logger.info(
              'DoctorResponse', 'Processed ${klinikList.length} clinics');
        } else {
          Logger.warning(
              'DoctorResponse', 'Clinic data is not a list: ${json['klinik']}');
        }
      }

      // Log final results
      if (dokterList.isEmpty) {
        Logger.warning('DoctorResponse', 'No doctors were successfully parsed');
        Logger.debug('DoctorResponse', 'Original response: $json');
      } else {
        Logger.success('DoctorResponse',
            'Successfully parsed ${dokterList.length} doctors');
        Logger.debug(
            'DoctorResponse', 'First doctor: ${dokterList.first.toString()}');
      }

      return DoctorResponse(
        dokter: dokterList,
        klinik: klinikList,
      );
    } catch (e, stackTrace) {
      Logger.error('DoctorResponse', 'Error parsing response: $e');
      Logger.error('DoctorResponse', 'Stack trace: $stackTrace');
      Logger.error('DoctorResponse', 'Response data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'dokter': dokter.map((doctor) => doctor.toJson()).toList(),
      'klinik': klinik,
    };
  }
}
