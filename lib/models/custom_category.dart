class CustomCategory {
  int? id;
  String name;
  String icon;
  int? parentId;
  List<CustomCategory> children;
  
  CustomCategory({
    this.id,
    required this.name,
    required this.icon,
    this.parentId,
    this.children = const [],
  });
  
  // 从Map转换为对象
  factory CustomCategory.fromMap(Map<String, dynamic> map) {
    return CustomCategory(
      id: map['id'],
      name: map['name'] ?? '未命名',
      icon: map['icon'] ?? '🎨', // 添加空值检查，确保即使数据库返回null也不会崩溃
      parentId: map['parent_id'],
    );
  }
  
  // 从对象转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'parent_id': parentId,
    };
  }
}