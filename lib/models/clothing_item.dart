class ClothingItem {
  int? id;
  String? imagePath;
  String name;
  String? description;
  ClothingCategory category;
  String? customCategory; // 自定义分类名称
  List<String>? colors;
  String? season;
  String? brand;
  String? size;
  DateTime? purchaseDate;
  String? location;
  bool isFavorite;
  String? photoNote; // 拍照备注
  
  ClothingItem({
    this.id,
    this.imagePath,
    required this.name,
    this.description,
    required this.category,
    this.customCategory,
    this.colors,
    this.season,
    this.brand,
    this.size,
    this.purchaseDate,
    this.location,
    this.isFavorite = false,
    this.photoNote,
  });
  
  // 从Map转换为对象
  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      imagePath: map['imagePath'],
      name: map['name'],
      description: map['description'],
      category: ClothingCategory.values[map['category']],
      customCategory: map['customCategory'],
      colors: map['colors'] != null ? (map['colors'] as String).split(',') : null,
      season: map['season'],
      brand: map['brand'],
      size: map['size'],
      purchaseDate: map['purchaseDate'] != null ? DateTime.parse(map['purchaseDate']) : null,
      location: map['location'],
      isFavorite: map['isFavorite'] == 1,
      photoNote: map['photoNote'],
    );
  }
  
  // 从对象转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'name': name,
      'description': description,
      'category': category.index,
      'customCategory': customCategory,
      'colors': colors?.join(','),
      'season': season,
      'brand': brand,
      'size': size,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'location': location,
      'isFavorite': isFavorite ? 1 : 0,
      'photoNote': photoNote,
    };
  }
  
  // 获取实际显示的分类名称
  String get displayCategoryName {
    return category == ClothingCategory.custom && customCategory != null && customCategory!.isNotEmpty
        ? customCategory!
        : category.displayName;
  }
}

// 服装分类枚举
enum ClothingCategory {
  top,      // 上衣
  pants,    // 裤子
  shoes,    // 鞋子
  accessories, // 配饰
  dress,    // 连衣裙
  skirt,    // 裙子
  outerwear, // 外套
  custom,   // 自定义
  others    // 其他
}

// 分类扩展，用于获取显示名称和图标
extension ClothingCategoryExtension on ClothingCategory {
  String get displayName {
    switch (this) {
      case ClothingCategory.top:
        return '上衣';
      case ClothingCategory.pants:
        return '裤子';
      case ClothingCategory.shoes:
        return '鞋子';
      case ClothingCategory.accessories:
        return '配饰';
      case ClothingCategory.dress:
        return '连衣裙';
      case ClothingCategory.skirt:
        return '裙子';
      case ClothingCategory.outerwear:
        return '外套';
      case ClothingCategory.custom:
        return '自定义';
      case ClothingCategory.others:
        return '其他';
    }
  }
  
  String get iconName {
    switch (this) {
      case ClothingCategory.top:
        return '👕';
      case ClothingCategory.pants:
        return '👖';
      case ClothingCategory.shoes:
        return '👟';
      case ClothingCategory.accessories:
        return '👜';
      case ClothingCategory.dress:
        return '👗';
      case ClothingCategory.skirt:
        return '👗';
      case ClothingCategory.outerwear:
        return '🧥';
      case ClothingCategory.custom:
        return '🎨';
      case ClothingCategory.others:
        return '👚';
    }
  }
}