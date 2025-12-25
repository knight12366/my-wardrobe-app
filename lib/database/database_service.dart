import 'dart:io' show Platform;
import 'dart:async';
import '../models/clothing_item.dart';
import '../models/custom_category.dart';

// 条件导入
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseService {
  static const String databaseName = 'wardrobe_database.db';
  static const int databaseVersion = 3;
  
  // 表名
  static const String tableClothing = 'clothing_items';
  static const String tableCustomCategories = 'custom_categories';
  
  // 表字段
  static const String columnId = 'id';
  static const String columnImagePath = 'imagePath';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnCategory = 'category';
  static const String columnCustomCategory = 'customCategory';
  static const String columnColors = 'colors';
  static const String columnSeason = 'season';
  static const String columnBrand = 'brand';
  static const String columnSize = 'size';
  static const String columnPurchaseDate = 'purchaseDate';
  static const String columnLocation = 'location';
  static const String columnIsFavorite = 'isFavorite';
  static const String columnPhotoNote = 'photoNote';
  
  // 自定义分类表字段
  static const String columnCustomCategoryId = 'id';
  static const String columnCustomCategoryName = 'name';
  static const String columnCustomCategoryIcon = 'icon';
  
  // 单例模式
  static final DatabaseService _instance = DatabaseService._privateConstructor();
  factory DatabaseService() => _instance;
  
  DatabaseService._privateConstructor();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  // 初始化数据库
  Future<Database> _initDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = p.join(databasePath, databaseName);
    
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  // 创建表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableClothing (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnImagePath TEXT,
        $columnName TEXT NOT NULL,
        $columnDescription TEXT,
        $columnCategory INTEGER NOT NULL,
        $columnCustomCategory TEXT,
        $columnColors TEXT,
        $columnSeason TEXT,
        $columnBrand TEXT,
        $columnSize TEXT,
        $columnPurchaseDate TEXT,
        $columnLocation TEXT,
        $columnIsFavorite INTEGER DEFAULT 0,
        $columnPhotoNote TEXT
      )
    ''');
    
    await _createCustomCategoriesTable(db);
  }
  
  // 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createCustomCategoriesTable(db);
    }
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE $tableCustomCategories ADD COLUMN parent_id INTEGER
      ''');
    }
  }
  
  // 创建自定义分类表
  Future<void> _createCustomCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableCustomCategories (
        $columnCustomCategoryId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCustomCategoryName TEXT NOT NULL,
        $columnCustomCategoryIcon TEXT NOT NULL,
        parent_id INTEGER
      )
    ''');
  }
  
  // 插入服装
  Future<int> insertClothing(ClothingItem item) async {
    final db = await database;
    return await db.insert(tableClothing, item.toMap());
  }
  
  // 获取所有服装
  Future<List<ClothingItem>> getAllClothing() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableClothing);
    
    return List.generate(maps.length, (i) {
      return ClothingItem.fromMap(maps[i]);
    });
  }
  
  // 按分类获取服装
  Future<List<ClothingItem>> getClothingByCategory(ClothingCategory category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableClothing,
      where: '$columnCategory = ?',
      whereArgs: [category.index],
    );
    
    return List.generate(maps.length, (i) {
      return ClothingItem.fromMap(maps[i]);
    });
  }
  
  // 获取收藏的服装
  Future<List<ClothingItem>> getFavoriteClothing() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableClothing,
      where: '$columnIsFavorite = ?',
      whereArgs: [1],
    );
    
    return List.generate(maps.length, (i) {
      return ClothingItem.fromMap(maps[i]);
    });
  }
  
  // 更新服装
  Future<int> updateClothing(ClothingItem item) async {
    final db = await database;
    return await db.update(
      tableClothing,
      item.toMap(),
      where: '$columnId = ?',
      whereArgs: [item.id],
    );
  }
  
  // 删除服装
  Future<int> deleteClothing(int id) async {
    final db = await database;
    return await db.delete(
      tableClothing,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  
  // 搜索服装
  Future<List<ClothingItem>> searchClothing(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableClothing,
      where: '$columnName LIKE ? OR $columnDescription LIKE ? OR $columnBrand LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    
    return List.generate(maps.length, (i) {
      return ClothingItem.fromMap(maps[i]);
    });
  }
  
  // 按季节筛选服装
  Future<List<ClothingItem>> getClothingBySeason(String season) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableClothing,
      where: '$columnSeason = ?',
      whereArgs: [season],
    );
    
    return List.generate(maps.length, (i) {
      return ClothingItem.fromMap(maps[i]);
    });
  }
  
  // 插入自定义分类
  Future<int> insertCustomCategory(CustomCategory category) async {
    final db = await database;
    return await db.insert(tableCustomCategories, category.toMap());
  }
  
  // 获取所有自定义分类
  Future<List<CustomCategory>> getAllCustomCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableCustomCategories);
    
    return List.generate(maps.length, (i) {
      return CustomCategory.fromMap(maps[i]);
    });
  }
  
  // 更新自定义分类
  Future<int> updateCustomCategory(CustomCategory category) async {
    final db = await database;
    return await db.update(
      tableCustomCategories,
      category.toMap(),
      where: '$columnCustomCategoryId = ?',
      whereArgs: [category.id],
    );
  }
  
  // 删除自定义分类
  Future<int> deleteCustomCategory(int id) async {
    final db = await database;
    return await db.delete(
      tableCustomCategories,
      where: '$columnCustomCategoryId = ?',
      whereArgs: [id],
    );
  }
  
  // 根据分类名称删除服装
  Future<int> deleteClothingByCategory(ClothingCategory category) async {
    final db = await database;
    return await db.delete(
      tableClothing,
      where: '$columnCategory = ?',
      whereArgs: [category.index],
    );
  }
  
  // 根据自定义分类名称删除服装
  Future<int> deleteClothingByCustomCategoryName(String categoryName) async {
    final db = await database;
    return await db.delete(
      tableClothing,
      where: '$columnCategory = ? AND $columnCustomCategory = ?',
      whereArgs: [ClothingCategory.custom.index, categoryName],
    );
  }
}