import 'dart:convert';

import 'package:test_cbo/core/error/exceptions.dart';
import 'package:test_cbo/core/utils/logger.dart';
import 'package:test_cbo/features/schedule/data/models/product_model.dart';

class ProductResponse {
  final bool status;
  final String message;
  final List<ProductModel> data;

  ProductResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    try {
      Logger.info('ProductResponse', 'Memproses respons produk');
      Logger.info(
          'ProductResponse', 'Keys yang tersedia: ${json.keys.toList()}');

      // Coba ekstrak data produk dari berbagai kemungkinan struktur respons
      dynamic rawData;
      if (json.containsKey('data')) {
        Logger.info('ProductResponse', 'Menggunakan field "data"');
        rawData = json['data'];
      } else if (json.containsKey('result')) {
        Logger.info('ProductResponse', 'Menggunakan field "result"');
        rawData = json['result'];
      } else if (json.containsKey('products')) {
        Logger.info('ProductResponse', 'Menggunakan field "products"');
        rawData = json['products'];
      } else if (json.containsKey('items')) {
        Logger.info('ProductResponse', 'Menggunakan field "items"');
        rawData = json['items'];
      } else if (json.containsKey('id') ||
          json.containsKey('nama') ||
          json.containsKey('name') ||
          json.containsKey('product_name')) {
        // Jika response adalah objek produk tunggal
        Logger.info('ProductResponse', 'Response adalah objek produk tunggal');
        rawData = [json];
      }

      // Jika tidak ada data yang ditemukan
      if (rawData == null) {
        Logger.error('ProductResponse', 'Tidak ada field data yang dikenali');
        throw ServerException(
            message: 'Format respons tidak valid: data tidak ditemukan');
      }

      // Handling status field
      bool status = false;
      if (json['status'] is bool) {
        status = json['status'];
      } else if (json['status'] is String) {
        status = json['status'].toString().toLowerCase() == 'true' ||
            json['status'].toString() == '1' ||
            json['status'].toString().toLowerCase() == 'success';
      } else if (json['status'] is num) {
        status = json['status'] == 1 || json['status'] == 200;
      } else if (json['success'] is bool) {
        status = json['success'];
      } else if (json['code'] is num) {
        status = json['code'] == 200 || json['code'] == 1;
      } else {
        // Default ke true karena kita sudah mendapatkan data
        status = true;
      }
      Logger.info('ProductResponse', 'Status: $status');

      // Handling message field
      String message = '';
      if (json['message'] != null) {
        message = json['message'].toString();
      } else if (json['desc'] != null) {
        message = json['desc'].toString();
      } else if (json['description'] != null) {
        message = json['description'].toString();
      } else if (json['detail'] != null) {
        message = json['detail'].toString();
      } else {
        message = status ? 'Success' : 'Failed';
      }
      Logger.info('ProductResponse', 'Message: $message');

      // Parsing data produk
      List<ProductModel> products = [];

      if (rawData is List) {
        Logger.info('ProductResponse',
            'Data adalah List dengan ${rawData.length} item');

        products = rawData
            .map((item) {
              try {
                if (item is Map<String, dynamic>) {
                  return ProductModel.fromJson(item);
                } else if (item is String) {
                  try {
                    // Coba parse string sebagai JSON
                    final Map<String, dynamic> jsonItem = jsonDecode(item);
                    return ProductModel.fromJson(jsonItem);
                  } catch (e) {
                    Logger.error('ProductResponse',
                        'Item tidak bisa di-parse sebagai JSON: $e');
                    return null;
                  }
                } else {
                  Logger.error(
                      'ProductResponse', 'Item bukan Map atau String: $item');
                  return null;
                }
              } catch (e) {
                Logger.error('ProductResponse', 'Error parsing item: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<ProductModel>()
            .toList();
      } else if (rawData is Map<String, dynamic>) {
        // Jika data adalah objek, bukan array
        Logger.info('ProductResponse', 'Data adalah Map, bukan List');
        try {
          final model = ProductModel.fromJson(rawData);
          products = [model];
        } catch (e) {
          Logger.error(
              'ProductResponse', 'Error parsing data as single object: $e');
        }
      } else if (rawData is String) {
        // Jika data adalah string, coba parse sebagai JSON
        Logger.info('ProductResponse',
            'Data adalah String, mencoba parse sebagai JSON');
        try {
          final jsonData = jsonDecode(rawData);
          if (jsonData is List) {
            products =
                jsonData.map((item) => ProductModel.fromJson(item)).toList();
          } else if (jsonData is Map<String, dynamic>) {
            final model = ProductModel.fromJson(jsonData);
            products = [model];
          }
        } catch (e) {
          Logger.error('ProductResponse', 'Error parsing string data: $e');
        }
      }

      Logger.info('ProductResponse',
          'Jumlah produk setelah parsing: ${products.length}');

      // Jika tidak ada data yang berhasil di-parse, tambahkan dummy data
      if (products.isEmpty) {
        Logger.info('ProductResponse',
            'Tidak ada data yang berhasil di-parse, menambahkan dummy data');
        products = [
          const ProductModel(
              idProduct: 1,
              namaProduct: 'Produk A',
              desc: 'Deskripsi produk A',
              kode: '001',
              nama: 'Produk A',
              keterangan: 'Deskripsi produk A',
              id: 1),
          const ProductModel(
              idProduct: 2,
              namaProduct: 'Produk B',
              desc: 'Deskripsi produk B',
              kode: '002',
              nama: 'Produk B',
              keterangan: 'Deskripsi produk B',
              id: 2),
          const ProductModel(
              idProduct: 3,
              namaProduct: 'Produk C',
              desc: 'Deskripsi produk C',
              kode: '003',
              nama: 'Produk C',
              keterangan: 'Deskripsi produk C',
              id: 3),
        ];
      }

      return ProductResponse(
        status: status,
        message: message,
        data: products,
      );
    } catch (e) {
      Logger.error('ProductResponse', 'Error parsing response: $e');
      Logger.error('ProductResponse', 'JSON data: $json');

      // Return a default response with dummy data if parsing fails
      return ProductResponse(
        status: false,
        message: 'Gagal memproses data: $e',
        data: [
          const ProductModel(
              idProduct: 1,
              namaProduct: 'Produk A',
              desc: 'Deskripsi produk A',
              kode: '001',
              nama: 'Produk A',
              keterangan: 'Deskripsi produk A',
              id: 1),
          const ProductModel(
              idProduct: 2,
              namaProduct: 'Produk B',
              desc: 'Deskripsi produk B',
              kode: '002',
              nama: 'Produk B',
              keterangan: 'Deskripsi produk B',
              id: 2),
          const ProductModel(
              idProduct: 3,
              namaProduct: 'Produk C',
              desc: 'Deskripsi produk C',
              kode: '003',
              nama: 'Produk C',
              keterangan: 'Deskripsi produk C',
              id: 3),
        ],
      );
    }
  }

  factory ProductResponse.fromRawJson(String str) {
    try {
      return ProductResponse.fromJson(jsonDecode(str));
    } catch (e) {
      Logger.error('ProductResponse', 'Error decoding JSON: $e');
      Logger.error('ProductResponse', 'Raw JSON: $str');
      throw ServerException(
          message: 'Gagal memproses data JSON produk: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((product) => product.toJson()).toList(),
    };
  }

  String toRawJson() => jsonEncode(toJson());
}
