import 'package:equatable/equatable.dart';

class UpdateScheduleRequestModel {
  final int id;
  final int typeSchedule;
  final String tujuan;
  final String tglVisit;
  final List<String> product;
  final String note;
  final int idUser;
  final List<int> productForIdDivisi;
  final List<int> productForIdSpesialis;
  final String shift;
  final String jenis;
  final int dokter;
  final String klinik;

  UpdateScheduleRequestModel({
    required this.id,
    required this.typeSchedule,
    required this.tujuan,
    required this.tglVisit,
    required this.product,
    required this.note,
    required this.idUser,
    required this.productForIdDivisi,
    required this.productForIdSpesialis,
    required this.shift,
    required this.jenis,
    required this.dokter,
    required this.klinik,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_schedule': id.toString(),
      'type-schedule': typeSchedule.toString(),
      'tujuan': tujuan,
      'tgl-visit': tglVisit,
      'product': product.map((id) => '"$id"').toList().toString(),
      'catatan': note,
      'id_user': idUser.toString(),
      'id_divisi_sales': productForIdDivisi.join(','),
      'id_spesialis': productForIdSpesialis.join(','),
      'shift': shift,
      'jenis-schedule': jenis,
      'dokter': dokter.toString(),
      'klinik': klinik,
    };
  }

  @override
  String toString() {
    return 'UpdateScheduleRequestModel(id: $id, typeSchedule: $typeSchedule, tujuan: $tujuan, tglVisit: $tglVisit, product: $product, note: $note, idUser: $idUser, productForIdDivisi: $productForIdDivisi, productForIdSpesialis: $productForIdSpesialis, shift: $shift, jenis: $jenis, dokter: $dokter, klinik: $klinik)';
  }
}
