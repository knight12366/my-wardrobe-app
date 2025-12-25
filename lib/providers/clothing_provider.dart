import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../models/custom_category.dart';
import '../database/database_service.dart';

class ClothingProvider with ChangeNotifier {
  List<ClothingItem> _clothingItems = [];
  List<ClothingItem> _filteredItems = [];
  List<CustomCategory> _customCategories = [];
  ClothingCategory? _selectedCategory;
  String? _selectedCustomCategory;
  String? _searchQuery;
  String? _selectedSeason;
  bool _showFavoritesOnly = false;
  
  List<ClothingItem> get clothingItems => _filteredItems;
  List<CustomCategory> get customCategories => _customCategories;

  // 获取分类树结构
  List<CustomCategory> get customCategoryTree {
    // 创建一个分类ID到分类对象的映射
    Map<int?, CustomCategory> categoryMap = {};
    List<CustomCategory> rootCategories = [];
    Set<int?> categoriesWithParent = {};

    // 首先将所有分类添加到映射中
    for (CustomCategory category in _customCategories) {
      categoryMap[category.id] = CustomCategory(
        id: category.id,
        name: category.name,
        icon: category.icon,
        parentId: category.parentId,
        children: [],
      );
    }

    // 然后构建树结构
    for (CustomCategory category in _customCategories) {
      CustomCategory currentCategory = categoryMap[category.id]!;
      if (category.parentId == null) {
        // 如果是根分类，直接添加到根列表
        rootCategories.add(currentCategory);
      } else {
        // 如果是子分类，添加到父分类的children列表
        CustomCategory? parent = categoryMap[category.parentId];
        if (parent != null) {
          parent.children.add(currentCategory);
          categoriesWithParent.add(category.id);
        }
      }
    }

    // 检查是否有分类的父分类不存在（孤立分类）
    // 如果有，将这些分类作为根分类添加
    for (CustomCategory category in _customCategories) {
      // 如果分类有父ID，但父分类不存在，或者未被添加到父分类的children列表中
      if (category.parentId != null && 
          (categoryMap[category.parentId] == null || 
           !categoriesWithParent.contains(category.id))) {
        // 确保当前分类对象已在映射中
        CustomCategory currentCategory = categoryMap[category.id]!;
        // 将这个分类作为根分类添加
        rootCategories.add(currentCategory);
      }
    }

    return rootCategories;
  }
  ClothingCategory? get selectedCategory => _selectedCategory;
  String? get selectedCustomCategory => _selectedCustomCategory;
  String? get searchQuery => _searchQuery;
  String? get selectedSeason => _selectedSeason;
  bool get showFavoritesOnly => _showFavoritesOnly;
  
  // 加载所有数据
  Future<void> loadAllData() async {
    try {
      await Future.wait([
        loadClothing(),
        loadCustomCategories()
      ]);
      notifyListeners();
    } catch (e) {
      print('Failed to load all data: $e');
    }
  }
  
  // 加载所有服装
  Future<void> loadClothing() async {
    try {
      _clothingItems = await DatabaseService().getAllClothing();
      _applyFilters();
    } catch (e) {
      print('Failed to load clothing: $e');
    }
  }
  
  // 加载所有自定义分类
  Future<void> loadCustomCategories() async {
    try {
      _customCategories = await DatabaseService().getAllCustomCategories();
    } catch (e) {
      print('Failed to load custom categories: $e');
    }
  }
  
  // 添加服装
  Future<void> addClothing(ClothingItem item) async {
    try {
      int id = await DatabaseService().insertClothing(item);
      item.id = id;
      _clothingItems.add(item);
      
      // 如果是新的自定义分类，添加到自定义分类列表
      if (item.category == ClothingCategory.custom && 
          item.customCategory != null && 
          !_customCategories.any((cat) => cat.name == item.customCategory)) {
        // 使用默认图标
        await addCustomCategory(CustomCategory(
          name: item.customCategory!, 
          icon: '🎨'
        ));
      }
      
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Failed to add clothing: $e');
    }
  }
  
  // 添加自定义分类
  Future<void> addCustomCategory(CustomCategory category) async {
    try {
      // 验证参数
      if (category.name.trim().isEmpty) {
        throw Exception('分类名称不能为空');
      }
      
      // 检查分类名称是否重复
      bool isDuplicate = _customCategories.any(
        (cat) => cat.name.toLowerCase() == category.name.toLowerCase() && 
                 cat.parentId == category.parentId
      );
      
      if (isDuplicate) {
        throw Exception('该分类名称已存在');
      }
      
      // 插入到数据库
        int id = await DatabaseService().insertCustomCategory(category);
      category.id = id;
      _customCategories.add(category);
      notifyListeners();
      print('成功添加自定义分类: ${category.name}');
    } catch (e) {
      print('添加自定义分类失败: $e');
      // 抛出异常以便UI层捕获并显示给用户
      rethrow;
    }
  }
  
  // 更新自定义分类
  Future<void> updateCustomCategory(CustomCategory category) async {
    try {
      await DatabaseService().updateCustomCategory(category);
      int index = _customCategories.indexWhere((cat) => cat.id == category.id);
      if (index != -1) {
        _customCategories[index] = category;
        // 同时更新使用该分类的服装
        for (var item in _clothingItems) {
          if (item.category == ClothingCategory.custom && 
              item.customCategory == _customCategories[index].name) {
            item.customCategory = category.name;
          }
        }
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      print('Failed to update custom category: $e');
    }
  }
  
  // 删除自定义分类
  Future<void> deleteCustomCategory(int id) async {
    try {
      CustomCategory? category = _customCategories.firstWhere((cat) => cat.id == id);
      await DatabaseService().deleteCustomCategory(id);
      _customCategories.removeWhere((cat) => cat.id == id);
      
      // 如果当前选中的是这个自定义分类，清除选择
      if (_selectedCustomCategory == category.name) {
        _selectedCustomCategory = null;
      }
      
      notifyListeners();
    } catch (e) {
      print('Failed to delete custom category: $e');
    }
  }
  
  // 更新服装
  Future<void> updateClothing(ClothingItem item) async {
    try {
      await DatabaseService().updateClothing(item);
      int index = _clothingItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _clothingItems[index] = item;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      print('Failed to update clothing: $e');
    }
  }
  
  // 删除服装
  Future<void> deleteClothing(int id) async {
    try {
      await DatabaseService().deleteClothing(id);
      _clothingItems.removeWhere((item) => item.id == id);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Failed to delete clothing: $e');
    }
  }
  
  // 删除某个分类的所有服装
  Future<void> deleteAllClothingByCategory(ClothingCategory category) async {
    try {
      await DatabaseService().deleteClothingByCategory(category);
      _clothingItems.removeWhere((item) => item.category == category);
      
      // 如果当前选中的是这个分类，清除选择
      if (_selectedCategory == category) {
        _selectedCategory = null;
      }
      
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Failed to delete all clothing by category: $e');
    }
  }
  
  // 删除某个自定义分类的所有服装
  Future<void> deleteAllClothingByCustomCategory(String categoryName) async {
    try {
      await DatabaseService().deleteClothingByCustomCategoryName(categoryName);
      _clothingItems.removeWhere((item) => 
          item.category == ClothingCategory.custom && 
          item.customCategory == categoryName
      );
      
      // 如果当前选中的是这个自定义分类，清除选择
      if (_selectedCustomCategory == categoryName) {
        _selectedCustomCategory = null;
      }
      
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Failed to delete all clothing by custom category: $e');
    }
  }
  
  // 切换收藏状态
  Future<void> toggleFavorite(int id) async {
    try {
      ClothingItem? item = _clothingItems.firstWhere((item) => item.id == id);
      item.isFavorite = !item.isFavorite;
      await DatabaseService().updateClothing(item);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Failed to toggle favorite: $e');
    }
  }
  
  // 设置选中的分类
  void setCategoryFilter(ClothingCategory? category) {
    _selectedCategory = category;
    _selectedCustomCategory = null; // 清除自定义分类选择
    _applyFilters();
    notifyListeners();
  }
  
  // 设置选中的自定义分类
  void setCustomCategoryFilter(String? categoryName) {
    _selectedCustomCategory = categoryName;
    _selectedCategory = null; // 清除系统分类选择
    _applyFilters();
    notifyListeners();
  }
  
  // 设置搜索查询
  void setSearchQuery(String? query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }
  
  // 设置季节筛选
  void setSeasonFilter(String? season) {
    _selectedSeason = season;
    _applyFilters();
    notifyListeners();
  }
  
  // 设置是否只显示收藏
  void setShowFavoritesOnly(bool showOnly) {
    _showFavoritesOnly = showOnly;
    _applyFilters();
    notifyListeners();
  }
  
  // 清除所有筛选
  void clearFilters() {
    _selectedCategory = null;
    _selectedCustomCategory = null;
    _searchQuery = null;
    _selectedSeason = null;
    _showFavoritesOnly = false;
    _applyFilters();
    notifyListeners();
  }
  
  // 应用筛选条件
  void _applyFilters() {
    _filteredItems = _clothingItems.where((item) {
      // 系统分类筛选
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      
      // 自定义分类筛选
      if (_selectedCustomCategory != null && 
          !(item.category == ClothingCategory.custom && 
            item.customCategory?.trim() == _selectedCustomCategory?.trim())) {
        return false;
      }
      
      // 搜索筛选
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        bool matches = item.name.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
                      (item.description != null && item.description!.toLowerCase().contains(_searchQuery!.toLowerCase())) ||
                      (item.brand != null && item.brand!.toLowerCase().contains(_searchQuery!.toLowerCase())) ||
                      (item.customCategory != null && item.customCategory!.toLowerCase().contains(_searchQuery!.toLowerCase()));
        if (!matches) return false;
      }
      
      // 季节筛选
      if (_selectedSeason != null && item.season != _selectedSeason) {
        return false;
      }
      
      // 收藏筛选
      if (_showFavoritesOnly && !item.isFavorite) {
        return false;
      }
      
      return true;
    }).toList();
  }
}