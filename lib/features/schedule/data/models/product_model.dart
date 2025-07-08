import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required int idProduct,
    String? kode,
    required String namaProduct,
    String? idDivisiSales,
    String? idSpesialis,
    int? hargaNormal,
    String? desc,
    String? image,
    String? createdAt,
    required String nama,
    required String keterangan,
    required int id,
  }) : super(
          idProduct: idProduct,
          kode: kode,
          namaProduct: namaProduct,
          idDivisiSales: idDivisiSales,
          idSpesialis: idSpesialis,
          hargaNormal: hargaNormal,
          desc: desc,
          image: image,
          createdAt: createdAt,
          nama: nama,
          keterangan: keterangan,
          id: id,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse id, handling different types
      int id;
      if (json['id'] is int) {
        id = json['id'];
      } else if (json['id'] is String) {
        id = int.tryParse(json['id']) ?? 0;
      } else if (json['id_product'] is int) {
        id = json['id_product'];
      } else if (json['id_product'] is String) {
        id = int.tryParse(json['id_product']) ?? 0;
      } else if (json['product_id'] is int) {
        id = json['product_id'];
      } else if (json['product_id'] is String) {
        id = int.tryParse(json['product_id']) ?? 0;
      } else if (json['prod_id'] is int) {
        id = json['prod_id'];
      } else if (json['prod_id'] is String) {
        id = int.tryParse(json['prod_id']) ?? 0;
      } else if (json['idProduk'] is int) {
        id = json['idProduk'];
      } else if (json['idProduk'] is String) {
        id = int.tryParse(json['idProduk']) ?? 0;
      } else {
        // Gunakan hash dari nama sebagai ID jika ID tidak ditemukan
        id = json['nama']?.hashCode ??
            json['name']?.hashCode ??
            json['product_name']?.hashCode ??
            json['produk_nama']?.hashCode ??
            DateTime.now().millisecondsSinceEpoch % 10000; // Fallback ID
      }

      // Parse nama, handling different field names
      String nama = '';
      if (json['nama'] != null) {
        nama = json['nama'].toString();
      } else if (json['nama_product'] != null) {
        nama = json['nama_product'].toString();
      } else if (json['name'] != null) {
        nama = json['name'].toString();
      } else if (json['product_name'] != null) {
        nama = json['product_name'].toString();
      } else if (json['namaProduk'] != null) {
        nama = json['namaProduk'].toString();
      } else if (json['produk_nama'] != null) {
        nama = json['produk_nama'].toString();
      } else if (json['title'] != null) {
        nama = json['title'].toString();
      } else {
        nama = 'Produk #$id';
      }

      // Parse keterangan, handling different field names
      String keterangan = '';
      if (json['keterangan'] != null) {
        keterangan = json['keterangan'].toString();
      } else if (json['desc'] != null) {
        keterangan = json['desc'].toString();
      } else if (json['description'] != null) {
        keterangan = json['description'].toString();
      } else if (json['detail'] != null) {
        keterangan = json['detail'].toString();
      } else if (json['deskripsi'] != null) {
        keterangan = json['deskripsi'].toString();
      } else if (json['keteranganProduk'] != null) {
        keterangan = json['keteranganProduk'].toString();
      }

      // Parse kodeRayon, handling different field names
      String kodeRayon = '';
      if (json['kode_rayon'] != null) {
        kodeRayon = json['kode_rayon'].toString();
      } else if (json['kode'] != null) {
        kodeRayon = json['kode'].toString();
      } else if (json['rayon_code'] != null) {
        kodeRayon = json['rayon_code'].toString();
      } else if (json['code'] != null) {
        kodeRayon = json['code'].toString();
      } else if (json['kodeRayon'] != null) {
        kodeRayon = json['kodeRayon'].toString();
      } else if (json['kodeProduk'] != null) {
        kodeRayon = json['kodeProduk'].toString();
      }

      Logger.info('ProductModel', 'Parsing data - id: $id, nama: $nama');

      // Temporary fallback for division and specialist IDs when API doesn't provide them
      String? idDivisiSales = json['id_divisi_sales']?.toString();
      String? idSpesialis = json['id_spesialis']?.toString();

      // Handle string "null" values from API
      if (idDivisiSales == 'null') idDivisiSales = null;
      if (idSpesialis == 'null') idSpesialis = null;

      Logger.debug('ProductModel',
          'After null check - idDivisiSales: $idDivisiSales, idSpesialis: $idSpesialis');

      // If API doesn't provide division/specialist data, provide default values based on product type
      if ((idDivisiSales == null || idDivisiSales.isEmpty) &&
          (idSpesialis == null || idSpesialis.isEmpty)) {
        // Provide default division and specialist mapping based on product name patterns
        if (nama.toLowerCase().contains('cream') ||
            nama.toLowerCase().contains('gel') ||
            nama.toLowerCase().contains('moisturizer')) {
          idDivisiSales = '[1,2]'; // Default divisions for skin care
          idSpesialis = '[4,10]'; // Dermatology and General
        } else if (nama.toLowerCase().contains('mask') ||
            nama.toLowerCase().contains('sheet')) {
          idDivisiSales = '[1,3]'; // Default divisions for cosmetic
          idSpesialis = '[4,11]'; // Dermatology and Others
        } else {
          idDivisiSales = '[1]'; // Default division
          idSpesialis = '[1]'; // General specialist
        }

        Logger.debug('ProductModel',
            'Applied fallback division/specialist for: $nama - idDivisiSales: $idDivisiSales, idSpesialis: $idSpesialis');
      }

      return ProductModel(
        idProduct: id,
        kode: kodeRayon,
        namaProduct: nama,
        idDivisiSales: idDivisiSales,
        idSpesialis: idSpesialis,
        hargaNormal: json['harga_normal'] as int?,
        desc: keterangan,
        image: json['image']?.toString(),
        createdAt: json['created_at']?.toString(),
        nama: nama,
        keterangan: keterangan,
        id: id,
      );
    } catch (e) {
      Logger.error('ProductModel', 'Error parsing ProductModel: $e');
      Logger.error('ProductModel', 'JSON data: $json');
      // Return a default model if parsing fails
      return const ProductModel(
        idProduct: 0,
        kode: '',
        namaProduct: 'Error',
        idDivisiSales: null,
        idSpesialis: null,
        hargaNormal: null,
        desc: 'Gagal memproses data',
        image: null,
        createdAt: null,
        nama: '',
        keterangan: '',
        id: 0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_product': idProduct,
      'kode': kode,
      'nama_product': namaProduct,
      'id_divisi_sales': idDivisiSales,
      'id_spesialis': idSpesialis,
      'harga_normal': hargaNormal,
      'desc': desc,
      'image': image,
      'created_at': createdAt,
      'nama': nama,
      'keterangan': keterangan,
      'id': id,
    };
  }

  @override
  List<Object?> get props => [
        idProduct,
        kode,
        namaProduct,
        idDivisiSales,
        idSpesialis,
        hargaNormal,
        desc,
        image,
        createdAt,
        nama,
        keterangan,
        id,
      ];
}
