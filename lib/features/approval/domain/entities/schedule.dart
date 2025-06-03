class Schedule {
  final int idSchedule;
  final String tglVisit;
  final String shift;
  final int approved;
  final String? note;
  final TujuanData tujuanData;
  final List<ProductData> productData;

  Schedule({
    required this.idSchedule,
    required this.tglVisit,
    required this.shift,
    required this.approved,
    this.note,
    required this.tujuanData,
    required this.productData,
  });
}

class TujuanData {
  final String? namaDokter;
  final String? namaKlinik;

  TujuanData({
    this.namaDokter,
    this.namaKlinik,
  });
}

class ProductData {
  final String namaProduct;

  ProductData({
    required this.namaProduct,
  });
}
