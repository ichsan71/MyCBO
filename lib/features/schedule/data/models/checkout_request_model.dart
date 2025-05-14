import 'dart:convert';

class CheckoutRequestModel {
  final int idSchedule;
  final String status;
  final String note;
  final String tglScheduleLanjutan;
  final String foto;

  CheckoutRequestModel({
    required this.idSchedule,
    required this.status,
    required this.note,
    required this.tglScheduleLanjutan,
    required this.foto,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_schedule': idSchedule.toString(),
      'status': status,
      'note': note,
      'tgl_schedule_lanjutan': tglScheduleLanjutan,
      'foto': foto,
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}
