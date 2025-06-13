import 'package:equatable/equatable.dart';
import 'doctor_clinic_base.dart';

class DoctorClinic extends DoctorClinicBase {
  const DoctorClinic({
    required int id,
    required String nama,
    required String spesialis,
    String? alamat,
    String? noTelp,
    String? email,
    String? tipeDokter,
    String? tipeKlinik,
    String? kodeRayon,
  }) : super(
          id: id,
          nama: nama,
          spesialis: spesialis,
          alamat: alamat,
          noTelp: noTelp,
          email: email,
          tipeDokter: tipeDokter,
          tipeKlinik: tipeKlinik,
          kodeRayon: kodeRayon,
        );
}
