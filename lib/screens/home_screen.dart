import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/clothing_provider.dart';
import '../models/clothing_item.dart';
import '../models/custom_category.dart';
import 'clothing_detail_screen.dart';
import 'add_clothing_screen.dart';
import 'category_management_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 加载所有数据（包括服装和自定义分类）
    Provider.of<ClothingProvider>(context, listen: false).loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'cc衣服馆',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Color.fromARGB(255, 30, 233, 223),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryManagementScreen(),
                ),
              );
            },
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.search, size: 24),
            onPressed: () {
              _showSearchDialog(context);
            },
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, size: 24),
            onPressed: () {
              _showFilterDialog(context);
            },
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类选择器
          _buildCategorySelector(),
          // 服装列表
          Expanded(
            child: Consumer<ClothingProvider>(
              builder: (context, provider, child) {
                if (provider.clothingItems.isEmpty) {
                  return const Center(child: Text('衣橱还是空的，添加一些衣服吧！'));
                }

                return MasonryGridView.count(
                  crossAxisCount: 2,
                  itemCount: provider.clothingItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.clothingItems[index];
                    return _buildClothingCard(item);
                  },
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  padding: const EdgeInsets.all(8),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClothingScreen()),
          );
        },
        tooltip: '添加服装',
        child: const Icon(Icons.add, size: 28),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        splashColor: Colors.orange,
      ),
    );
  }

  // 构建分类选择器
  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Consumer<ClothingProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              _buildAllCategoryChip(),
              // 自定义分类
              for (var customCategory in provider.customCategories)
                _buildCustomCategoryChip(customCategory),
            ],
          );
        },
      ),
    );
  }

  // 构建全部分类Chip
  Widget _buildAllCategoryChip() {
    final provider = Provider.of<ClothingProvider>(context);
    bool isSelected =
        provider.selectedCategory == null &&
        provider.selectedCustomCategory == null;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: const Text('全部', style: TextStyle(fontSize: 14)),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            provider.clearFilters();
          }
        },
        selectedColor: Color(0xFFE91E63),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? Color(0xFFE91E63)
                : Color(0xFFE91E63).withOpacity(0.3),
          ),
        ),
        elevation: isSelected ? 3 : 1,
        shadowColor: Color(0xFFE91E63).withOpacity(0.3),
        avatar: Icon(
          Icons.check_circle,
          size: 16,
          color: isSelected ? Colors.white : Colors.transparent,
        ),
      ),
    );
  }

  // 构建系统分类Chip
  Widget _buildSystemCategoryChip(ClothingCategory category) {
    final provider = Provider.of<ClothingProvider>(context);
    bool isSelected = provider.selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          children: [
            Text(category.iconName, style: TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Text(
              category.displayName,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : Color(0xFF5D4037),
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          provider.setCategoryFilter(selected ? category : null);
        },
        selectedColor: Color(0xFFE91E63),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? Color(0xFFE91E63)
                : Color(0xFFE91E63).withOpacity(0.3),
          ),
        ),
        elevation: isSelected ? 3 : 1,
        shadowColor: Color(0xFFE91E63).withOpacity(0.3),
        onDeleted: isSelected
            ? () => _showDeleteCategoryConfirmation(context, category: category)
            : null,
        deleteIconColor: isSelected ? Colors.white : null,
      ),
    );
  }

  // 构建自定义分类Chip
  Widget _buildCustomCategoryChip(CustomCategory category) {
    final provider = Provider.of<ClothingProvider>(context);
    bool isSelected = provider.selectedCustomCategory == category.name;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          children: [
            Text(
              category.icon ?? '🎨',
              style: TextStyle(fontSize: 18),
            ), // 添加空值检查
            const SizedBox(width: 4),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : Color(0xFF5D4037),
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          provider.setCustomCategoryFilter(selected ? category.name : null);
        },
        selectedColor: Color(0xFFE91E63),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? Color(0xFFE91E63)
                : Color(0xFFE91E63).withOpacity(0.3),
          ),
        ),
        elevation: isSelected ? 3 : 1,
        shadowColor: Color(0xFFE91E63).withOpacity(0.3),
        onDeleted: isSelected
            ? () => _showDeleteCategoryConfirmation(
                context,
                customCategoryName: category.name,
              )
            : null,
        deleteIconColor: isSelected ? Colors.white : null,
      ),
    );
  }

  // 显示删除分类确认对话框
  void _showDeleteCategoryConfirmation(
    BuildContext context, {
    ClothingCategory? category,
    String? customCategoryName,
  }) {
    String categoryName = category?.displayName ?? customCategoryName ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFFFF3F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '清除分类',
          style: TextStyle(
            color: Color(0xFFE91E63),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          '确定要删除分类 "$categoryName" 下的所有服装吗？\n此操作不可撤销。',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              final provider = Provider.of<ClothingProvider>(
                context,
                listen: false,
              );
              if (category != null) {
                provider.deleteAllClothingByCategory(category);
              } else if (customCategoryName != null) {
                provider.deleteAllClothingByCustomCategory(customCategoryName);
              }
              Navigator.pop(context);
            },
            child: Text('删除'),
          ),
        ],
      ),
    );
  }

  // 构建服装卡片
  Widget _buildClothingCard(ClothingItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0xFFE91E63).withOpacity(0.3)),
      ),
      shadowColor: Color(0xFFE91E63).withOpacity(0.3),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClothingDetailScreen(item: item),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 服装图片
            AspectRatio(
              aspectRatio: 1,
              child: item.imagePath != null
                  ? Image.file(File(item.imagePath!), fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
            ),
            // 服装信息
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.displayCategoryName,
                    style: TextStyle(fontSize: 14, color: Color(0xFF8D6E63)),
                  ),
                  if (item.brand != null) Text(item.brand!),
                ],
              ),
            ),
            // 收藏按钮
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: item.isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  Provider.of<ClothingProvider>(
                    context,
                    listen: false,
                  ).toggleFavorite(item.id!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示搜索对话框
  void _showSearchDialog(BuildContext context) {
    String query =
        Provider.of<ClothingProvider>(context, listen: false).searchQuery ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '搜索服装',
          style: TextStyle(color: Color.fromARGB(255, 30, 230, 233)),
        ),
        backgroundColor: Color(0xFFFFF3F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: TextEditingController(text: query),
          onChanged: (value) {
            query = value;
          },
          decoration: InputDecoration(
            labelText: '输入名称、描述、品牌或分类',
            labelStyle: TextStyle(color: Color.fromARGB(255, 223, 233, 30)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFFE91E63)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('取消', style: TextStyle(color: Color(0xFF795548))),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ClothingProvider>(
                context,
                listen: false,
              ).setSearchQuery(query);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE91E63),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  // 显示筛选对话框
  void _showFilterDialog(BuildContext context) {
    final provider = Provider.of<ClothingProvider>(context, listen: false);

    // 将状态变量移到builder函数外部，确保它们在对话框生命周期内保持状态
    bool showFavorites = provider.showFavoritesOnly;
    String? selectedSeason = provider.selectedSeason;
    String? selectedCustomCategory = provider.selectedCustomCategory;

    showDialog(
      context: context,
      builder: (context) {
        // 使用StatefulBuilder来更新对话框内的状态
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                '筛选选项',
                style: TextStyle(color: Color(0xFFE91E63)),
              ),
              backgroundColor: Color(0xFFFFF3F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 收藏筛选
                    CheckboxListTile(
                      title: const Text('只显示收藏'),
                      value: showFavorites,
                      onChanged: (value) {
                        setState(() {
                          showFavorites = value ?? false;
                        });
                      },
                      activeColor: Color(0xFFE91E63),
                    ),
                    const SizedBox(height: 16),

                    // 季节筛选
                    Text(
                      '季节筛选:',
                      style: TextStyle(
                        color: Color(0xFFE91E63),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedSeason,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('全部季节'),
                        ),
                        const DropdownMenuItem(value: '春季', child: Text('春季')),
                        const DropdownMenuItem(value: '夏季', child: Text('夏季')),
                        const DropdownMenuItem(value: '秋季', child: Text('秋季')),
                        const DropdownMenuItem(value: '冬季', child: Text('冬季')),
                        const DropdownMenuItem(value: '四季', child: Text('四季')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedSeason = value;
                          // 清除分类筛选
                          provider.setCategoryFilter(null);
                          selectedCustomCategory = null;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFFE91E63)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color(0xFFE91E63),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 分类筛选
                    Text(
                      '分类筛选:',
                      style: TextStyle(
                        color: Color(0xFFE91E63),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 自定义分类
                    DropdownButtonFormField<String>(
                      value: selectedCustomCategory,
                      hint: const Text('选择自定义分类'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('全部自定义分类'),
                        ),
                        ...provider.customCategories.map(
                          (category) => DropdownMenuItem(
                            value: category.name,
                            child: Row(
                              children: [
                                Text(
                                  category.icon ?? '🎨',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(category.name),
                              ],
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCustomCategory = value;
                          // 清除季节筛选
                          selectedSeason = null;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFFE91E63)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color(0xFFE91E63),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    provider.clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '清除筛选',
                    style: TextStyle(color: Color(0xFF795548)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 应用所有筛选条件
                    provider.setShowFavoritesOnly(showFavorites);
                    provider.setSeasonFilter(selectedSeason);

                    // 设置自定义分类筛选
                    provider.setCustomCategoryFilter(selectedCustomCategory);

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE91E63),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('应用'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
