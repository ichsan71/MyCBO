import 'dart:convert';

class CheckinRequestModel {
  final int idSchedule;
  final String lokasi;
  final String note;
  final String foto;

  CheckinRequestModel({
    required this.idSchedule,
    required this.lokasi,
    required this.note,
    required this.foto,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_schedule': idSchedule.toString(),
      'lokasi': lokasi,
      'note': note,
      'foto': foto,
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}
