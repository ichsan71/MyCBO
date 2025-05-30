import 'package:equatable/equatable.dart';
import 'dart:convert';

import 'package:test_cbo/core/utils/logger.dart';

class EditScheduleProductModel extends Equatable {
  final int idProduct;
  final String? kode;
  final String namaProduct;
  final List<String> idDivisiSales;
  final List<String> idSpesialis;
  final int? hargaNormal;
  final String? desc;
  final String? image;
  final String? createdAt;

  const EditScheduleProductModel({
    required this.idProduct,
    this.kode,
    required this.namaProduct,
    required this.idDivisiSales,
    required this.idSpesialis,
    this.hargaNormal,
    this.desc,
    this.image,
    this.createdAt,
  });

  factory EditScheduleProductModel.fromJson(Map<String, dynamic> json) {
    // Parse list from string or list
    List<String> parseList(dynamic value) {
      if (value == null) return [];

      if (value is String) {
        try {
          // Try to parse as JSON array first
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
          // If not a JSON array, try splitting by comma
          String cleanString = value
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .replaceAll(' ', '');
          return cleanString.split(',').where((e) => e.isNotEmpty).toList();
        } catch (e) {
          Logger.error('schedule', 'Error parsing string to list: $e');
          // If single value, return as single item list
          if (value.trim().isNotEmpty) {
            return [value.trim()];
          }
          return [];
        }
      } else if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return EditScheduleProductModel(
      idProduct: json['id_product'] ?? 0,
      kode: json['kode']?.toString(),
      namaProduct: json['nama_product']?.toString() ?? '',
      idDivisiSales: parseList(json['id_divisi_sales']),
      idSpesialis: parseList(json['id_spesialis']),
      hargaNormal: json['harga_normal'] is String
          ? int.tryParse(json['harga_normal'])
          : json['harga_normal'],
      desc: json['desc']?.toString(),
      image: json['image']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
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
      ];

  @override
  String toString() {
    return 'EditScheduleProductModel(idProduct: $idProduct, namaProduct: $namaProduct, idDivisiSales: $idDivisiSales, idSpesialis: $idSpesialis)';
  }
}
