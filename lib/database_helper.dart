import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/POI.dart';
import '../models/user.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;
  static const String dbName = 'tahura_users.db';
  static const String rootPath =
      'C:/Users/Nikolaus Franz/Documents/tahura_project';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payment_method TEXT,
        amount REAL,
        transaction_date TEXT,
        product_name TEXT,
        discount REAL,
        user_name TEXT,
        adult_tickets INTEGER,
        child_tickets INTEGER
      )
    ''');

    // Users table with enhanced fields
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        profile_image TEXT,
        role TEXT DEFAULT 'user',
        created_at TEXT,
        last_login TEXT
      )
    ''');

    // Enhanced events table
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        image_url TEXT,
        date TEXT,
        location TEXT,
        max_participants INTEGER,
        current_participants INTEGER DEFAULT 0,
        status TEXT DEFAULT 'upcoming'
      )
    ''');

    // FAQ table with categories
    await db.execute('''
      CREATE TABLE faq (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT,
        answer TEXT,
        category TEXT,
        priority INTEGER DEFAULT 0
      )
    ''');

    // Enhanced POI table
    await db.execute('''
      CREATE TABLE poi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        latitude REAL,
        longitude REAL,
        imageUrl TEXT,
        category TEXT,
        status TEXT DEFAULT 'active',
        last_updated TEXT
      )
    ''');

    // Ticket prices table
    await db.execute('''
      CREATE TABLE ticket_prices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        adult_price REAL,
        child_price REAL,
        updated_at TEXT,
        valid_from TEXT,
        valid_until TEXT
      )
    ''');

    // Ticket packages table
    await db.execute('''
      CREATE TABLE ticket_packages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        description TEXT,
        created_at TEXT,
        max_usage INTEGER,
        current_usage INTEGER DEFAULT 0,
        valid_until TEXT
      )
    ''');

    // Insert default admin and staff accounts
    await _insertDefaultAccounts(db);

    // Insert initial POIs
    await _insertInitialPOIs(db);

    // Insert default ticket prices
    await _insertDefaultTicketPrices(db);

    // Insert sample data for testing
    if (version == 1) {
      await _insertSampleData(db);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN profile_image TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE users ADD COLUMN role TEXT DEFAULT "user"');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE users ADD COLUMN created_at TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN last_login TEXT');
    }
  }

  Future<void> _insertDefaultAccounts(Database db) async {
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin',
      'password': 'admin',
      'role': 'admin',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'name': 'Staff',
      'email': 'staff',
      'password': 'staff',
      'role': 'staff',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _insertInitialPOIs(Database db) async {
    final pois = [
      {
        'name': 'Tahura',
        'description': 'Selamat datang di Taman Hutan Raya Bandung!',
        'latitude': -6.858110,
        'longitude': 107.630884,
        'imageUrl': '$rootPath/lib/assets/tahura1.png',
        'category': 'main',
      },
      {
        'name': 'Goa Jepang',
        'description': 'Situs bersejarah dari Perang Dunia II',
        'latitude': -6.856650,
        'longitude': 107.632461,
        'imageUrl': '$rootPath/lib/assets/tahura8.png',
        'category': 'historical',
      },
      // ... more POIs
    ];

    for (var poi in pois) {
      await db.insert('poi', poi);
    }
  }

  Future<void> _insertDefaultTicketPrices(Database db) async {
    await db.insert('ticket_prices', {
      'adult_price': 50000,
      'child_price': 25000,
      'updated_at': DateTime.now().toIso8601String(),
      'valid_from': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _insertSampleData(Database db) async {
    // Sample transactions
    final transactions = [
      {
        'payment_method': 'debit',
        'amount': 150000.0,
        'transaction_date':
            DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'product_name': 'Tiket Perjalanan (Dewasa: 2, Anak: 1)',
        'user_name': 'john.doe@gmail.com',
        'adult_tickets': 2,
        'child_tickets': 1
      },
      // ... more sample transactions
    ];

    final batch = db.batch();
    for (var transaction in transactions) {
      batch.insert('transactions', transaction);
    }
    await batch.commit(noResult: true);
  }

  // User Operations
  Future<int> insertUser(String name, String email, String password) async {
    final db = await database;
    return await db.insert(
      'users',
      {
        'name': name,
        'email': email,
        'password': password,
        'role': 'user',
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> loginUser(String email, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (results.isNotEmpty) {
      await db.update(
        'users',
        {'last_login': DateTime.now().toIso8601String()},
        where: 'email = ?',
        whereArgs: [email],
      );
      return true;
    }
    return false;
  }

  Future<String?> getUserRole(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      columns: ['role'],
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? results.first['role'] as String? : null;
  }

  // Transaction Operations
  Future<int> insertDetailedTransaction({
    required String paymentMethod,
    required double amount,
    required String productName,
    String? userName,
    double discount = 0.0,
    int? adultTickets,
    int? childTickets,
  }) async {
    final db = await database;
    return await db.insert(
      'transactions',
      {
        'payment_method': paymentMethod,
        'amount': amount,
        'product_name': productName,
        'discount': discount,
        'transaction_date': DateTime.now().toIso8601String(),
        'user_name': userName,
        'adult_tickets': adultTickets,
        'child_tickets': childTickets,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'transaction_date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'transaction_date DESC',
    );
  }

  // Event Operations
  Future<int> insertEvent(
      String title, String description, String imageUrl, DateTime date,
      {String? location, int? maxParticipants}) async {
    final db = await database;
    return await db.insert(
      'events',
      {
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'date': date.toIso8601String(),
        'location': location,
        'max_participants': maxParticipants,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getEventsByDate(DateTime date) async {
    final db = await database;
    return await db.query(
      'events',
      where: 'date LIKE ?',
      whereArgs: ['${date.toIso8601String().split('T')[0]}%'],
    );
  }

  // FAQ Operations
  Future<int> insertFAQ(String question, String answer,
      {String? category, int priority = 0}) async {
    final db = await database;
    return await db.insert(
      'faq',
      {
        'question': question,
        'answer': answer,
        'category': category,
        'priority': priority,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllFAQs() async {
    final db = await database;
    return await db.query('faq', orderBy: 'priority DESC, id ASC');
  }

  // POI Operations
  Future<List<PointOfInterest>> getAllPOIs() async {
    final db = await database;
    final results = await db.query(
      'poi',
      where: 'status = ?',
      whereArgs: ['active'],
    );
    return results
        .map((e) => PointOfInterest(
              id: e['id'] as int,
              name: e['name'] as String,
              description: e['description'] as String,
              latitude: e['latitude'] as double,
              longitude: e['longitude'] as double,
              imageUrl: e['imageUrl'] as String,
            ))
        .toList();
  }

  Future<int> updatePOI(
    int id,
    String name,
    String description,
    double latitude,
    double longitude,
  ) async {
    final db = await database;
    return await db.update(
      'poi',
      {
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ticket Operations
  Future<int> updateTicketPrices(double adultPrice, double childPrice) async {
    final db = await database;
    return await db.insert(
      'ticket_prices',
      {
        'adult_price': adultPrice,
        'child_price': childPrice,
        'updated_at': DateTime.now().toIso8601String(),
        'valid_from': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<Map<String, dynamic>?> getLatestTicketPrices() async {
    final db = await database;
    final results = await db.query(
      'ticket_prices',
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Generic Operations
  Future<void> deleteRecord(String table, int id) async {
    final db = await database;
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllRecords(String table) async {
    final db = await database;
    return await db.query(table);
  }
  // Metode untuk menghapus FAQ
Future<void> deleteFAQ(int id) async {
  final db = await database;
  await db.delete(
    'faq',
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Metode untuk menambahkan Ticket Package
Future<int> insertTicketPackage({
  required String name,
  required double price,
  required String description,
  int? maxUsage,
  DateTime? validUntil,
}) async {
  final db = await database;
  return await db.insert(
    'ticket_packages',
    {
      'name': name,
      'price': price,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
      'max_usage': maxUsage,
      'current_usage': 0,
      'valid_until': validUntil?.toIso8601String(),
    },
  );
}

// Metode untuk menghapus POI
Future<void> deletePOI(int id) async {
  final db = await database;
  await db.delete(
    'poi',
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Metode untuk mendapatkan semua transaksi
Future<List<Map<String, dynamic>>> getAllTransactions() async {
  final db = await database;
  return await db.query(
    'transactions', 
    orderBy: 'transaction_date DESC'
  );
}
Future<void> updateProfileImage(String email, String imagePath) async {
  final db = await database;
  await db.update(
    'users',
    {'profile_image': imagePath},
    where: 'email = ?',
    whereArgs: [email],
  );
}
Future<Map<String, dynamic>?> getUserByEmail(String email) async {
  final db = await database;
  List<Map<String, dynamic>> results = await db.query(
    'users',
    where: 'email = ?',
    whereArgs: [email],
    limit: 1,
  );

  // Kembalikan user jika ditemukan, jika tidak maka null
  return results.isNotEmpty ? results.first : null;
}
}
