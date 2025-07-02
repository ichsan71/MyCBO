import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;
  static bool _isInitializing = false;
  static bool _isInitialized = false;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Prevent multiple initialization attempts
    if (_isInitializing) {
      // Wait for ongoing initialization
      while (_isInitializing && !_isInitialized) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (_database != null) return _database!;
    }

    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    _isInitializing = true;
    try {
      if (kDebugMode) {
        print('Initializing database...');
      }

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      if (kDebugMode) {
        print('Database path: $path');
      }

      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onOpen: (db) async {
          // Try to optimize database settings (safe fallback approach)
          try {
            // Try WAL mode first, but don't fail if it's not supported
            await db.execute('PRAGMA journal_mode=WAL');
            if (kDebugMode) {
              print('WAL mode enabled successfully');
            }
          } catch (e) {
            if (kDebugMode) {
              print('WAL mode not supported, falling back to DELETE mode: $e');
            }
            // Continue with default DELETE mode
          }

          try {
            await db.execute('PRAGMA synchronous=NORMAL');
            await db.execute('PRAGMA cache_size=10000');
            await db.execute('PRAGMA temp_store=MEMORY');
            if (kDebugMode) {
              print('Database optimizations applied successfully');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Some database optimizations failed, but continuing: $e');
            }
            // Continue without optimizations if they fail
          }
        },
      );

      _isInitialized = true;
      return db;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }

      // Reset flags on error
      _isInitialized = false;

      // For critical database errors, try to delete and recreate
      try {
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, filePath);
        await databaseFactory.deleteDatabase(path);
        if (kDebugMode) {
          print('Deleted corrupted database, will retry on next access');
        }
      } catch (deleteError) {
        if (kDebugMode) {
          print('Could not delete database: $deleteError');
        }
      }

      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> initialize() async {
    try {
      if (_isInitialized && _database != null) {
        if (kDebugMode) {
          print('Database already initialized');
        }
        return;
      }

      await database; // This will trigger initialization if needed

      if (kDebugMode) {
        print('Database initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during database initialization: $e');
      }

      // Reset initialization flags to allow retry
      _isInitializing = false;
      _isInitialized = false;

      // Don't rethrow - allow app to continue running
      // Database operations will be retried when needed
      if (kDebugMode) {
        print(
            'Database initialization failed, but app will continue without local database');
      }
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      if (kDebugMode) {
        print('Creating database tables...');
      }

      // Use a transaction for better performance
      await db.transaction((txn) async {
        // Doctors table
        await txn.execute('''
          CREATE TABLE doctors (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            address TEXT,
            phone TEXT,
            email TEXT,
            specialization TEXT,
            doctor_type TEXT,
            clinic_type TEXT,
            rayon_code TEXT,
            last_updated INTEGER
          )
        ''');

        // Products table
        await txn.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            division_id INTEGER,
            specialist_id INTEGER,
            last_updated INTEGER
          )
        ''');

        // Schedule types table
        await txn.execute('''
          CREATE TABLE schedule_types (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            last_updated INTEGER
          )
        ''');

        // Notifications table
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS notifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            isRead INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // Create indexes for better query performance
        await txn.execute(
            'CREATE INDEX IF NOT EXISTS idx_doctors_name ON doctors(name)');
        await txn.execute(
            'CREATE INDEX IF NOT EXISTS idx_products_name ON products(name)');
        await txn.execute(
            'CREATE INDEX IF NOT EXISTS idx_notifications_timestamp ON notifications(timestamp)');

        if (kDebugMode) {
          print('Database tables and indexes created successfully');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error creating tables: $e');
      }
      rethrow;
    }
  }

  Future<void> insertDoctors(List<Map<String, dynamic>> doctors) async {
    if (doctors.isEmpty) return;

    try {
      if (kDebugMode) {
        print('Saving doctors data: ${doctors.length} items');
      }

      final db = await database;

      // Use transaction with batch for better performance
      await db.transaction((txn) async {
        final batch = txn.batch();

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

        await batch.commit(noResult: true);
      });

      if (kDebugMode) {
        print('Doctors data saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving doctors data: $e');
      }
      // Don't rethrow - log error but continue
    }
  }

  Future<void> insertProducts(List<Map<String, dynamic>> products) async {
    if (products.isEmpty) return;

    try {
      if (kDebugMode) {
        print('Saving products data: ${products.length} items');
      }

      final db = await database;

      // Use transaction with batch for better performance
      await db.transaction((txn) async {
        final batch = txn.batch();

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

        await batch.commit(noResult: true);
      });

      if (kDebugMode) {
        print('Products data saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving products data: $e');
      }
      // Don't rethrow - log error but continue
    }
  }

  Future<void> insertScheduleTypes(List<Map<String, dynamic>> types) async {
    if (types.isEmpty) return;

    try {
      if (kDebugMode) {
        print('Saving schedule types data: ${types.length} items');
      }

      final db = await database;

      // Use transaction with batch for better performance
      await db.transaction((txn) async {
        final batch = txn.batch();

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

        await batch.commit(noResult: true);
      });

      if (kDebugMode) {
        print('Schedule types data saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving schedule types data: $e');
      }
      // Don't rethrow - log error but continue
    }
  }

  Future<List<Map<String, dynamic>>> getDoctors() async {
    try {
      final db = await database;
      final result = await db.query('doctors', orderBy: 'name ASC');
      if (kDebugMode) {
        print('Retrieved doctors data: ${result.length} items');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving doctors data: $e');
      }
      return []; // Return empty list instead of throwing
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final db = await database;
      final result = await db.query('products', orderBy: 'name ASC');
      if (kDebugMode) {
        print('Retrieved products data: ${result.length} items');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving products data: $e');
      }
      return []; // Return empty list instead of throwing
    }
  }

  Future<List<Map<String, dynamic>>> getScheduleTypes() async {
    try {
      final db = await database;
      final result = await db.query('schedule_types', orderBy: 'name ASC');
      if (kDebugMode) {
        print('Retrieved schedule types: ${result.length} items');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving schedule types: $e');
      }
      return []; // Return empty list instead of throwing
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
            'Last updated for table $table: ${DateTime.fromMillisecondsSinceEpoch(lastUpdated)}');
      }

      return lastUpdated;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting last_updated for table $table: $e');
      }
      return 0; // Return 0 instead of throwing
    }
  }

  /// Clean all data in database
  /// Used when logging out to avoid previous user data still being stored
  Future<void> clearAllTables() async {
    try {
      if (kDebugMode) {
        print('Starting to clear all database tables...');
      }

      final db = await database;

      // Use transaction for better performance and consistency
      await db.transaction((txn) async {
        await txn.delete('doctors');
        await txn.delete('products');
        await txn.delete('schedule_types');
        await txn.delete('notifications');
      });

      // Vacuum database to reclaim space (optional, can be done periodically)
      await db.execute('VACUUM');

      if (kDebugMode) {
        print('All database tables cleared successfully');

        // Verify cleanup
        final doctorsCount = (await getDoctors()).length;
        final productsCount = (await getProducts()).length;
        final scheduleTypesCount = (await getScheduleTypes()).length;

        print(
            'Verification - Doctors: $doctorsCount, Products: $productsCount, Schedule Types: $scheduleTypesCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing database tables: $e');
      }
      // Don't rethrow - log error but continue
    }
  }

  /// Check if data is outdated and needs refresh
  Future<bool> isDataOutdated(String table,
      {Duration maxAge = const Duration(hours: 24)}) async {
    try {
      final lastUpdated = await getLastUpdated(table);
      if (lastUpdated == 0) return true; // No data exists

      final lastUpdatedDate = DateTime.fromMillisecondsSinceEpoch(lastUpdated);
      final now = DateTime.now();
      final difference = now.difference(lastUpdatedDate);

      final isOutdated = difference > maxAge;

      if (kDebugMode) {
        print(
            'Data outdated check for $table: $isOutdated (age: ${difference.inHours}h)');
      }

      return isOutdated;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking data age for table $table: $e');
      }
      return true; // Assume outdated on error
    }
  }

  /// Optimize database performance (can be called periodically)
  Future<void> optimizeDatabase() async {
    try {
      if (kDebugMode) {
        print('Starting database optimization...');
      }

      final db = await database;

      // Analyze tables for better query planning
      await db.execute('ANALYZE');

      // Update table statistics
      await db.execute('PRAGMA optimize');

      if (kDebugMode) {
        print('Database optimization completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during database optimization: $e');
      }
      // Don't rethrow - optimization is not critical
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      _isInitialized = false;
      if (kDebugMode) {
        print('Database connection closed');
      }
    }
  }

  /// Get database info for debugging
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await database;
      final version = await db.getVersion();
      final path = db.path;

      return {
        'version': version,
        'path': path,
        'isOpen': db.isOpen,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting database info: $e');
      }
      return {};
    }
  }

  Future<void> deleteDatabase() async {
    try {
      if (kDebugMode) {
        print('Menghapus database...');
      }

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'app.db');

      await databaseFactory.deleteDatabase(path);
      _database = null;

      if (kDebugMode) {
        print('Database berhasil dihapus');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saat menghapus database: $e');
      }
      rethrow;
    }
  }
}
