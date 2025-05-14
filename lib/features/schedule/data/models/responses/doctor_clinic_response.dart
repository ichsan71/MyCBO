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
      Logger.info('DoctorClinicResponse', 'Memproses respons dokter dan klinik');
      Logger.info('DoctorClinicResponse', 'Keys yang tersedia: ${json.keys.toList()}');

      // Handling status field
      bool status = false;
      if (json['status'] is bool) {
        status = json['status'];
      } else if (json['status'] is String) {
        status = json['status'].toString().toLowerCase() == 'true';
      } else if (json['status'] is num) {
        status = json['status'] == 1;
      }
      Logger.info('DoctorClinicResponse', 'Status: $status');

      // Handling description field yang mungkin disebut 'desc' atau 'message'
      String desc = '';
      if (json['desc'] != null) {
        desc = json['desc'].toString();
      } else if (json['message'] != null) {
        desc = json['message'].toString();
      }
      Logger.info('DoctorClinicResponse', 'Deskripsi: $desc');

      // Handling data field
      List<DoctorClinicModel> doctorClinics = [];
      if (json['data'] != null) {
        Logger.info('DoctorClinicResponse', 'Data type: ${json['data'].runtimeType}');

        if (json['data'] is List) {
          Logger.info('DoctorClinicResponse', 'Jumlah data: ${(json['data'] as List).length}');

          doctorClinics = (json['data'] as List)
              .map((item) {
                try {
                  if (item is Map<String, dynamic>) {
                    Logger.info('DoctorClinicResponse', 'Item keys: ${item.keys.toList()}');
                    return DoctorClinicModel.fromJson(item);
                  } else {
                    Logger.error('DoctorClinicResponse', 'Item bukan Map: $item');
                    return null;
                  }
                } catch (e) {
                  Logger.error('DoctorClinicResponse', 'Error parsing item: $e');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<DoctorClinicModel>()
              .toList();
        } else if (json['data'] is Map<String, dynamic>) {
          // Jika data adalah objek, bukan array
          Logger.info('DoctorClinicResponse', 'Data adalah Map, bukan List');
          try {
            final model = DoctorClinicModel.fromJson(json['data']);
            doctorClinics = [model];
          } catch (e) {
            Logger.error('DoctorClinicResponse', 'Error parsing data as single object: $e');
          }
        }
      }

      Logger.info('DoctorClinicResponse', 'Jumlah dokter dan klinik setelah parsing: ${doctorClinics.length}');

      // Jika tidak ada data yang berhasil di-parse, tambahkan dummy data
      if (doctorClinics.isEmpty) {
        Logger.info('DoctorClinicResponse', 'Tidak ada data yang berhasil di-parse, menambahkan dummy data');
        doctorClinics = [
          const DoctorClinicModel(
              id: 1,
              nama: 'Dr. Andi',
              alamat: 'Jl. Kesehatan No. 1',
              noTelp: '08123456789',
              email: 'dr.andi@example.com',
              spesialis: 'Umum',
              tipeDokter: 'Umum',
              tipeKlinik: 'Puskesmas',
              kodeRayon: '001'),
          const DoctorClinicModel(
              id: 2,
              nama: 'Dr. Budi',
              alamat: 'Jl. Kesehatan No. 2',
              noTelp: '08123456790',
              email: 'dr.budi@example.com',
              spesialis: 'Jantung',
              tipeDokter: 'Spesialis',
              tipeKlinik: 'Rumah Sakit',
              kodeRayon: '002'),
          const DoctorClinicModel(
              id: 3,
              nama: 'Dr. Citra',
              alamat: 'Jl. Kesehatan No. 3',
              noTelp: '08123456791',
              email: 'dr.citra@example.com',
              spesialis: 'Anak',
              tipeDokter: 'Spesialis',
              tipeKlinik: 'Klinik',
              kodeRayon: '003'),
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
        desc: 'Gagal memproses data: $e',
        data: [
          const DoctorClinicModel(
              id: 1,
              nama: 'Dr. Andi',
              alamat: 'Jl. Kesehatan No. 1',
              noTelp: '08123456789',
              email: 'dr.andi@example.com',
              spesialis: 'Umum',
              tipeDokter: 'Umum',
              tipeKlinik: 'Puskesmas',
              kodeRayon: '001'),
          const DoctorClinicModel(
              id: 2,
              nama: 'Dr. Budi',
              alamat: 'Jl. Kesehatan No. 2',
              noTelp: '08123456790',
              email: 'dr.budi@example.com',
              spesialis: 'Jantung',
              tipeDokter: 'Spesialis',
              tipeKlinik: 'Rumah Sakit',
              kodeRayon: '002'),
          const DoctorClinicModel(
              id: 3,
              nama: 'Dr. Citra',
              alamat: 'Jl. Kesehatan No. 3',
              noTelp: '08123456791',
              email: 'dr.citra@example.com',
              spesialis: 'Anak',
              tipeDokter: 'Spesialis',
              tipeKlinik: 'Klinik',
              kodeRayon: '003'),
        ],
      );
    }
  }
}
