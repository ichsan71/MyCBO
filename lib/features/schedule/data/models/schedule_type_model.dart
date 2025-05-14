import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/domain/entities/schedule_type.dart';

class ScheduleTypeModel extends ScheduleType {
  const ScheduleTypeModel({
    required int id,
    required String nama,
    required String keterangan,
  }) : super(
          id: id,
          nama: nama,
          keterangan: keterangan,
        );

  factory ScheduleTypeModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse id, handling different types
      int id;
      if (json['id'] is int) {
        id = json['id'];
      } else if (json['id'] is String) {
        id = int.tryParse(json['id']) ?? 0;
      } else if (json['id_type'] is int) {
        id = json['id_type'];
      } else if (json['id_type'] is String) {
        id = int.tryParse(json['id_type']) ?? 0;
      } else {
        id = 0;
      }

      // Parse nama, handling different field names
      // Prioritaskan 'name' karena itu yang digunakan dalam respons API
      String nama = '';
      if (json['name'] != null) {
        nama = json['name'].toString();
      } else if (json['nama'] != null) {
        nama = json['nama'].toString();
      } else if (json['nama_type'] != null) {
        nama = json['nama_type'].toString();
      }

      // Parse keterangan, handling different field names
      String keterangan = '';
      if (json['keterangan'] != null) {
        keterangan = json['keterangan'].toString();
      } else if (json['desc'] != null) {
        keterangan = json['desc'].toString();
      } else if (json['description'] != null) {
        keterangan = json['description'].toString();
      }

      Logger.info('ScheduleTypeModel', 'Parsing data - id: $id, nama: $nama');

      return ScheduleTypeModel(
        id: id,
        nama: nama,
        keterangan: keterangan,
      );
    } catch (e) {
      Logger.error('ScheduleTypeModel', 'Error parsing ScheduleTypeModel: $e');
      Logger.error('ScheduleTypeModel', 'JSON data: $json');
      // Return a default model if parsing fails
      return const ScheduleTypeModel(
        id: 0,
        nama: 'Error',
        keterangan: 'Gagal memproses data',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'keterangan': keterangan,
    };
  }
}
