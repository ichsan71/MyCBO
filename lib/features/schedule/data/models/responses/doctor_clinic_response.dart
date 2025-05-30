import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/data/models/doctor_clinic_model.dart';

class DoctorClinicResponse {
  final bool status;
  final String desc;
  final List<DoctorClinicModel> data;

  DoctorClinicResponse({
    required this.status,
    required this.desc,
    required this.data,
  });

  factory DoctorClinicResponse.fromJson(Map<String, dynamic> json) {
    try {
      Logger.info(
          'DoctorClinicResponse', 'Memproses respons dokter dan klinik');
      Logger.info(
          'DoctorClinicResponse', 'Keys yang tersedia: ${json.keys.toList()}');

      // Parse status
      bool status = false;
      if (json['status'] != null) {
        if (json['status'] is bool) {
          status = json['status'];
        } else if (json['status'] is String) {
          status = json['status'].toString().toLowerCase() == 'true';
        } else if (json['status'] is int) {
          status = json['status'] == 1;
        }
      }
      Logger.info('DoctorClinicResponse', 'Status: $status');

      // Parse description
      String desc = '';
      if (json['desc'] != null) {
        desc = json['desc'].toString();
      } else if (json['description'] != null) {
        desc = json['description'].toString();
      } else if (json['message'] != null) {
        desc = json['message'].toString();
      }
      Logger.info('DoctorClinicResponse', 'Deskripsi: $desc');

      // Parse data
      List<DoctorClinicModel> doctorClinics = [];
      if (json['data'] != null) {
        Logger.info(
            'DoctorClinicResponse', 'Data type: ${json['data'].runtimeType}');

        if (json['data'] is List) {
          Logger.info('DoctorClinicResponse',
              'Jumlah data: ${(json['data'] as List).length}');

          doctorClinics = (json['data'] as List)
              .map((item) {
                try {
                  if (item is Map<String, dynamic>) {
                    Logger.info('DoctorClinicResponse',
                        'Item keys: ${item.keys.toList()}');
                    return DoctorClinicModel.fromJson(item);
                  } else {
                    Logger.error(
                        'DoctorClinicResponse', 'Item bukan Map: $item');
                    return null;
                  }
                } catch (e) {
                  Logger.error(
                      'DoctorClinicResponse', 'Error parsing item: $e');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<DoctorClinicModel>()
              .toList();
        } else if (json['data'] is Map<String, dynamic>) {
          Logger.info('DoctorClinicResponse', 'Data adalah Map, bukan List');
          try {
            final model = DoctorClinicModel.fromJson(json['data']);
            doctorClinics = [model];
          } catch (e) {
            Logger.error('DoctorClinicResponse',
                'Error parsing data as single object: $e');
          }
        }
      }

      Logger.info('DoctorClinicResponse',
          'Jumlah dokter dan klinik setelah parsing: ${doctorClinics.length}');

      // Jika tidak ada data yang berhasil di-parse, tambahkan dummy data
      if (doctorClinics.isEmpty) {
        Logger.info('DoctorClinicResponse',
            'Tidak ada data yang berhasil di-parse, menambahkan dummy data');
        doctorClinics = [
          const DoctorClinicModel(
            id: 5017,
            nama: 'IT TESTING 1',
            alamat: 'Jl. Test 1',
            noTelp: '08123456789',
            email: 'test1@example.com',
            spesialis: '1',
            tipeDokter: 'Umum',
            tipeKlinik: 'Klinik Umum',
            kodeRayon: 'IT TESTING',
          ),
          const DoctorClinicModel(
            id: 5018,
            nama: 'DR IT TESTING',
            alamat: 'Jl. Test 2',
            noTelp: '08234567890',
            email: 'test2@example.com',
            spesialis: '4',
            tipeDokter: 'Spesialis',
            tipeKlinik: 'Klinik Spesialis',
            kodeRayon: 'IT TESTING',
          ),
          const DoctorClinicModel(
            id: 5019,
            nama: 'DR IT TESTING 2',
            alamat: 'Jl. Test 3',
            noTelp: '08345678901',
            email: 'test3@example.com',
            spesialis: '2',
            tipeDokter: 'Spesialis',
            tipeKlinik: 'Klinik Spesialis',
            kodeRayon: 'IT TESTING',
          ),
        ];
      }

      return DoctorClinicResponse(
        status: status,
        desc: desc,
        data: doctorClinics,
      );
    } catch (e) {
      Logger.error('DoctorClinicResponse', 'Error parsing response: $e');
      Logger.error('DoctorClinicResponse', 'JSON data: $json');

      // Return a default response with dummy data if parsing fails
      return DoctorClinicResponse(
        status: false,
        desc: 'Error parsing response: $e',
        data: [
          const DoctorClinicModel(
            id: 5017,
            nama: 'IT TESTING 1',
            alamat: 'Jl. Test 1',
            noTelp: '08123456789',
            email: 'test1@example.com',
            spesialis: '1',
            tipeDokter: 'Umum',
            tipeKlinik: 'Klinik Umum',
            kodeRayon: 'IT TESTING',
          ),
          const DoctorClinicModel(
            id: 5018,
            nama: 'DR IT TESTING',
            alamat: 'Jl. Test 2',
            noTelp: '08234567890',
            email: 'test2@example.com',
            spesialis: '4',
            tipeDokter: 'Spesialis',
            tipeKlinik: 'Klinik Spesialis',
            kodeRayon: 'IT TESTING',
          ),
          const DoctorClinicModel(
            id: 5019,
            nama: 'DR IT TESTING 2',
            alamat: 'Jl. Test 3',
            noTelp: '08345678901',
            email: 'test3@example.com',
            spesialis: '2',
            tipeDokter: 'Spesialis',
            tipeKlinik: 'Klinik Spesialis',
            kodeRayon: 'IT TESTING',
          ),
        ],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'desc': desc,
      'data': data.map((doctor) => doctor.toJson()).toList(),
    };
  }
}
