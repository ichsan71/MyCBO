import 'dart:convert';

class CheckinRequestModel {
  final int idSchedule;
  final String lokasi;
  final String note;
  final String foto;
  final int userId;

  CheckinRequestModel({
    required this.idSchedule,
    required this.lokasi,
    required this.note,
    required this.foto,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_schedule': idSchedule,
      'lokasi': lokasi,
      'note': note,
      'foto': foto,
      'user_id': userId,
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}
