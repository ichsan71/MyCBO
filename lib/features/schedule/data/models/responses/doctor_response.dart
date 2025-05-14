import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/data/models/doctor_model.dart';

class DoctorResponse {
  final List<DoctorModel> dokter;
  final List<dynamic> klinik;

  DoctorResponse({
    required this.dokter,
    required this.klinik,
  });

  factory DoctorResponse.fromJson(Map<String, dynamic> json) {
    try {
      Logger.info('DoctorResponse', 'Memproses respons dokter');
      Logger.info('DoctorResponse', 'Keys yang tersedia: ${json.keys.toList()}');

      // Parse dokter
      List<DoctorModel> dokterList = [];
      if (json['dokter'] != null && json['dokter'] is List) {
        Logger.info('DoctorResponse', 'Jumlah dokter: ${(json['dokter'] as List).length}');

        dokterList = (json['dokter'] as List)
            .map((item) {
              try {
                if (item is Map<String, dynamic>) {
                  Logger.info('DoctorResponse', 'Item keys: ${item.keys.toList()}');
                  return DoctorModel.fromJson(item);
                } else {
                  Logger.error('DoctorResponse', 'Item bukan Map: $item');
                  return null;
                }
              } catch (e) {
                Logger.error('DoctorResponse', 'Error parsing item: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<DoctorModel>()
            .toList();
      }

      // Parse klinik (untuk saat ini hanya disimpan sebagai List<dynamic>)
      List<dynamic> klinikList = [];
      if (json['klinik'] != null && json['klinik'] is List) {
        klinikList = json['klinik'] as List;
      }

      Logger.info('DoctorResponse', 'Jumlah dokter setelah parsing: ${dokterList.length}');
      Logger.info('DoctorResponse', 'Jumlah klinik setelah parsing: ${klinikList.length}');

      // Jika tidak ada data dokter yang berhasil di-parse, tambahkan dummy data
      if (dokterList.isEmpty) {
        Logger.info('DoctorResponse', 'Tidak ada data dokter yang berhasil di-parse, menambahkan dummy data');
        dokterList = [
          DoctorModel(
              id: 5017,
              kodePelanggan: "MAZ-ITTESTING-6385666",
              nama: "IT TESTING 1",
              rayonDokter: ["219"],
              spesialis: 1,
              statusDokter: null,
              createdAt: DateTime.now(),
              kodeRayon: "IT TESTING"),
          DoctorModel(
              id: 5018,
              kodePelanggan: "MAZ-ITTESTING-8234641",
              nama: "DR IT TESTING",
              rayonDokter: ["219"],
              spesialis: 4,
              statusDokter: null,
              createdAt: DateTime.now(),
              kodeRayon: "IT TESTING"),
        ];
      }

      return DoctorResponse(
        dokter: dokterList,
        klinik: klinikList,
      );
    } catch (e) {
      Logger.error('DoctorResponse', 'Error parsing response: $e');
      Logger.error('DoctorResponse', 'JSON data: $json');

      // Return a default response with dummy data if parsing fails
      return DoctorResponse(
        dokter: [
          DoctorModel(
              id: 5017,
              kodePelanggan: "MAZ-ITTESTING-6385666",
              nama: "IT TESTING 1",
              rayonDokter: ["219"],
              spesialis: 1,
              statusDokter: null,
              createdAt: DateTime.now(),
              kodeRayon: "IT TESTING"),
          DoctorModel(
              id: 5018,
              kodePelanggan: "MAZ-ITTESTING-8234641",
              nama: "DR IT TESTING",
              rayonDokter: ["219"],
              spesialis: 4,
              statusDokter: null,
              createdAt: DateTime.now(),
              kodeRayon: "IT TESTING"),
        ],
        klinik: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'dokter': dokter.map((doctor) => doctor.toJson()).toList(),
      'klinik': klinik,
    };
  }
}
