import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/data/models/schedule_type_model.dart';

class ScheduleTypeResponse {
  final bool status;
  final String desc;
  final List<ScheduleTypeModel> data;

  ScheduleTypeResponse({
    required this.status,
    required this.desc,
    required this.data,
  });

  factory ScheduleTypeResponse.fromJson(Map<String, dynamic> json) {
    try {
      Logger.info('ScheduleTypeResponse', 'Memproses respons tipe jadwal');
      Logger.info('ScheduleTypeResponse', 'Keys yang tersedia: ${json.keys.toList()}');

      // Handling status field
      bool status = false;
      if (json['status'] is bool) {
        status = json['status'];
      } else if (json['status'] is String) {
        status = json['status'].toString().toLowerCase() == 'true';
      } else if (json['status'] is num) {
        status = json['status'] == 1;
      }
      Logger.info('ScheduleTypeResponse', 'Status: $status');

      // Handling description field yang mungkin disebut 'desc' atau 'message'
      String desc = '';
      if (json['desc'] != null) {
        desc = json['desc'].toString();
      } else if (json['message'] != null) {
        desc = json['message'].toString();
      }
      Logger.info('ScheduleTypeResponse', 'Deskripsi: $desc');

      // Handling data field
      List<ScheduleTypeModel> scheduleTypes = [];
      if (json['data'] != null) {
        Logger.info('ScheduleTypeResponse', 'Data type: ${json['data'].runtimeType}');

        if (json['data'] is List) {
          Logger.info('ScheduleTypeResponse', 'Jumlah data: ${(json['data'] as List).length}');

          scheduleTypes = (json['data'] as List)
              .map((item) {
                try {
                  if (item is Map<String, dynamic>) {
                    Logger.info('ScheduleTypeResponse', 'Item keys: ${item.keys.toList()}');
                    return ScheduleTypeModel.fromJson(item);
                  } else {
                    Logger.error('ScheduleTypeResponse', 'Item bukan Map: $item');
                    return null;
                  }
                } catch (e) {
                  Logger.error('ScheduleTypeResponse', 'Error parsing item: $e');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<ScheduleTypeModel>()
              .toList();
        } else if (json['data'] is Map<String, dynamic>) {
          // Jika data adalah objek, bukan array
          Logger.info('ScheduleTypeResponse', 'Data adalah Map, bukan List');
          try {
            final model = ScheduleTypeModel.fromJson(json['data']);
            scheduleTypes = [model];
          } catch (e) {
            Logger.error('ScheduleTypeResponse', 'Error parsing data as single object: $e');
          }
        }
      }

      Logger.info('ScheduleTypeResponse', 'Jumlah tipe jadwal setelah parsing: ${scheduleTypes.length}');

      // Jika tidak ada data yang berhasil di-parse, tambahkan dummy data
      if (scheduleTypes.isEmpty) {
        Logger.info('ScheduleTypeResponse', 'Tidak ada data yang berhasil di-parse, menambahkan dummy data');
        scheduleTypes = [
          const ScheduleTypeModel(id: 1, nama: 'DETAILING', keterangan: ''),
          const ScheduleTypeModel(id: 2, nama: 'FOLLOW UP', keterangan: ''),
          const ScheduleTypeModel(id: 3, nama: 'ENTERTAINT', keterangan: ''),
          const ScheduleTypeModel(id: 4, nama: 'SERVICE', keterangan: ''),
          const ScheduleTypeModel(id: 5, nama: 'JOIN VISIT', keterangan: ''),
          const ScheduleTypeModel(id: 6, nama: 'REMINDING', keterangan: ''),
        ];
      }

      return ScheduleTypeResponse(
        status: status,
        desc: desc,
        data: scheduleTypes,
      );
    } catch (e) {
      Logger.error('ScheduleTypeResponse', 'Error parsing response: $e');
      Logger.error('ScheduleTypeResponse', 'JSON data: $json');

      // Return a default response with dummy data if parsing fails
      return ScheduleTypeResponse(
        status: false,
        desc: 'Gagal memproses data: $e',
        data: [
          const ScheduleTypeModel(id: 1, nama: 'DETAILING', keterangan: ''),
          const ScheduleTypeModel(id: 2, nama: 'FOLLOW UP', keterangan: ''),
          const ScheduleTypeModel(id: 3, nama: 'ENTERTAINT', keterangan: ''),
          const ScheduleTypeModel(id: 4, nama: 'SERVICE', keterangan: ''),
          const ScheduleTypeModel(id: 5, nama: 'JOIN VISIT', keterangan: ''),
          const ScheduleTypeModel(id: 6, nama: 'REMINDING', keterangan: ''),
        ],
      );
    }
  }
}
