import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      if (kDebugMode) {
        print('Menginisialisasi database...');
      }

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      if (kDebugMode) {
        print('Path database: $path');
      }

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saat inisialisasi database: $e');
      }
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      if (kDebugMode) {
        print('Membuat tabel-tabel database...');
      }

      // Tabel untuk menyimpan data dokter
      await db.execute('''
        CREATE TABLE doctors (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          specialization TEXT,
          last_updated INTEGER
        )
      ''');
      if (kDebugMode) {
        print('Tabel doctors berhasil dibuat');
      }

      // Tabel untuk menyimpan data produk
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          division_id INTEGER,
          specialist_id INTEGER,
          last_updated INTEGER
        )
      ''');
      if (kDebugMode) {
        print('Tabel products berhasil dibuat');
      }

      // Tabel untuk menyimpan tipe jadwal
      await db.execute('''
        CREATE TABLE schedule_types (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          last_updated INTEGER
        )
      ''');
      if (kDebugMode) {
        print('Tabel schedule_types berhasil dibuat');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saat membuat tabel: $e');
      }
      rethrow;
    }
  }

  Future<void> insertDoctors(List<Map<String, dynamic>> doctors) async {
    try {
      if (kDebugMode) {
        print('Menyimpan data dokter: ${doctors.length} item');
      }

      final db = await database;
      final batch = db.batch();

      for (var doctor in doctors) {
        batch.insert(
          'doctors',
          {
            ...doctor,
            'last_updated': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit();

      if (kDebugMode) {
        print('Data dokter berhasil disimpan');
        final savedDoctors = await getDoctors();
        print('Data dokter yang tersimpan: ${savedDoctors.length} item');
        print('Contoh data: ${savedDoctors.take(2)}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saat menyimpan data dokter: $e');
      }
      rethrow;
    }
  }

  Future<void> insertProducts(List<Map<String, dynamic>> products) async {
    try {
      if (kDebugMode) {
        print('Menyimpan data produk: ${products.length} item');
      }

      final db = await database;
      final batch = db.batch();

      for (var product in products) {
        batch.insert(
          'products',
          {
            ...product,
            'last_updated': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit();

      if (kDebugMode) {
        print('Data produk berhasil disimpan');
        final savedProducts = await getProducts();
        print('Data produk yang tersimpan: ${savedProducts.length} item');
        print('Contoh data: ${savedProducts.take(2)}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saat menyimpan data produk: $e');
      }
      rethrow;
    }
  }

  Future<void> insertScheduleTypes(List<Map<String, dynamic>> types) async {
    try {
      if (kDebugMode) {
        print('Menyimpan tipe jadwal: ${types.length} item');
      }

      final db = await database;
      final batch = db.batch();

      for (var type in types) {
        batch.insert(
          'schedule_types',
          {
            ...type,
            'last_updated': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit();

      if (kDebugMode) {
        print('Tipe jadwal berhasil disimpan');
        final savedTypes = await getScheduleTypes();
        print('Tipe jadwal yang tersimpan: ${savedTypes.length} item');
        print('Contoh data: ${savedTypes.take(2)}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saat menyimpan tipe jadwal: $e');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDoctors() async {
    try {
      final db = await database;
      final result = await db.query('doctors');
      if (kDebugMode) {
        print('Mengambil data dokter: ${result.length} item');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error saat mengambil data dokter: $e');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final db = await database;
      final result = await db.query('products');
      if (kDebugMode) {
        print('Mengambil data produk: ${result.length} item');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error saat mengambil data produk: $e');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getScheduleTypes() async {
    try {
      final db = await database;
      final result = await db.query('schedule_types');
      if (kDebugMode) {
        print('Mengambil tipe jadwal: ${result.length} item');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error saat mengambil tipe jadwal: $e');
      }
      rethrow;
    }
  }

  Future<int> getLastUpdated(String table) async {
    try {
      final db = await database;
      final result = await db.query(
        table,
        columns: ['last_updated'],
        orderBy: 'last_updated DESC',
        limit: 1,
      );

      if (result.isEmpty) return 0;
      final lastUpdated = result.first['last_updated'] as int;

      if (kDebugMode) {
        print(
            'Last updated untuk tabel $table: ${DateTime.fromMillisecondsSinceEpoch(lastUpdated)}');
      }

      return lastUpdated;
    } catch (e) {
      if (kDebugMode) {
        print('Error saat mengambil last_updated untuk tabel $table: $e');
      }
      rethrow;
    }
  }

  /// Membersihkan semua data dalam database
  /// Digunakan saat logout untuk menghindari data user sebelumnya masih tersimpan
  Future<void> clearAllTables() async {
    try {
      if (kDebugMode) {
        print('Mulai membersihkan semua tabel database...');
      }
      
      final db = await database;
      final batch = db.batch();
      
      // Hapus semua data dari tabel-tabel
      batch.delete('doctors');
      batch.delete('products');
      batch.delete('schedule_types');
      
      // Tambahkan tabel lain jika ada
      
      await batch.commit();
      
      // Verifikasi pembersihan
      if (kDebugMode) {
        final doctorsCount = (await getDoctors()).length;
        final productsCount = (await getProducts()).length;
        final scheduleTypesCount = (await getScheduleTypes()).length;
        
        print('Database berhasil dibersihkan:');
        print('- Dokter: $doctorsCount item');
        print('- Produk: $productsCount item');
        print('- Tipe Jadwal: $scheduleTypesCount item');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saat membersihkan tabel: $e');
      }
      rethrow;
    }
  }

  Future<void> close() async {
    try {
      final db = await database;
      await db.close();
      if (kDebugMode) {
        print('Database berhasil ditutup');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saat menutup database: $e');
      }
      rethrow;
    }
  }
}
