import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/custom_category.dart';
import '../providers/clothing_provider.dart';

class CategoryManagementScreen extends StatefulWidget {
  @override
  _CategoryManagementScreenState createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final TextEditingController _categoryNameController = TextEditingController();
  String _selectedIcon = '🎨';
  // 按类别组织的图标列表
  Map<String, List<String>> _iconCategories = {
    '衣服类': [
      '👕',
      '👖',
      '👗',
      '🧥',
      '🥼',
      '👔',
      '👚',
      '👘',
      '🩱',
      '🩲',
      '🩳',
      '👙',
      '👚',
      '🧦',
      '👜',
      '🎒',
      '👝',
      '👛',
    ],
    '鞋履类': ['👟', '👢', '👞', '👠', '👡', '🥿', '🥾', '👟'],
    '配饰类': [
      '🧢',
      '🧣',
      '🧤',
      '👒',
      '🎩',
      '👓',
      '🕶️',
      '💍',
      '📿',
      '🧿',
      '💄',
      '💋',
      '💅',
      '👁️',
      '👄',
    ],
    '生活用品': [
      '🧴',
      '🧷',
      '🧹',
      '🧺',
      '🧻',
      '🪥',
      '🧼',
      '🧽',
      '🧴',
      '🛁',
      '🚿',
      '🪒',
      '🧴',
      '🧴',
      '🧴',
    ],
    '文具类': [
      '📝',
      '✏️',
      '📚',
      '📖',
      '📒',
      '📕',
      '📗',
      '📘',
      '📙',
      '📄',
      '📃',
      '📑',
      '📊',
      '📈',
      '📉',
    ],
    '数码产品': [
      '📱',
      '💻',
      '🖥️',
      '🖨️',
      '🖱️',
      '⌨️',
      '🎧',
      '📷',
      '🎥',
      '📹',
      '🪟',
      '📞',
      '📟',
      '⏰',
      '⌚',
    ],
    '其他': [
      '🎨',
      '🎭',
      '🎪',
      '🎬',
      '🎤',
      '🎧',
      '🎼',
      '🎵',
      '🎶',
      '🎹',
      '🥁',
      '🎷',
      '🎸',
      '🎺',
      '🎻',
    ],
  };
  Map<String, bool> _expandedCategories = {};

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    try {
      print('_showAddCategoryDialog方法开始执行');

      // 重置输入框
      _categoryNameController.clear();
      String tempSelectedIcon = '🎨'; // 使用临时变量保存对话框内的选中状态

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (dialogContext, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  '添加分类',
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _categoryNameController,
                        decoration: InputDecoration(
                          labelText: '分类名称',
                          labelStyle: TextStyle(color: Color(0xFFE91E63)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFE91E63)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('选择图标:', style: TextStyle(color: Color(0xFFE91E63))),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _iconCategories.entries.map((entry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF795548),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: entry.value.map((icon) {
                                          return GestureDetector(
                                            onTap: () {
                                              // 使用对话框内部的setState，只更新对话框内容
                                              setState(() {
                                                tempSelectedIcon = icon;
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(4),
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      tempSelectedIcon == icon
                                                      ? Color(0xFFE91E63)
                                                      : Colors.grey,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: tempSelectedIcon == icon
                                                    ? Color(
                                                        0xFFE91E63,
                                                      ).withOpacity(0.1)
                                                    : Colors.transparent,
                                              ),
                                              child: Text(
                                                icon,
                                                style: TextStyle(fontSize: 24),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text('取消', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE91E63),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final categoryName = _categoryNameController.text
                            .trim();
                        if (categoryName.isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text('分类名称不能为空'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final provider = Provider.of<ClothingProvider>(
                          dialogContext,
                          listen: false,
                        );
                        await provider.addCustomCategory(
                          CustomCategory(
                            name: categoryName,
                            icon: tempSelectedIcon,
                            parentId: null, // 顶级分类
                            children: [],
                          ),
                        );

                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('分类添加成功'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        print('分类添加成功: $categoryName');
                      } catch (e) {
                        print('添加分类失败: $e');
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text('确认'),
                  ),
                ],
              );
            },
          );
        },
      );
      print('对话框已尝试显示');
    } catch (e) {
      print('显示对话框失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败，请重试'), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditCategoryDialog(CustomCategory category) {
    print('编辑分类按钮被点击');
    print('分类ID: ${category.id}, 名称: ${category.name}');

    // 初始化控制器和选中图标
    _categoryNameController.text = category.name;
    String tempSelectedIcon = category.icon ?? '🎨';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                '编辑分类',
                style: TextStyle(
                  color: Color(0xFFE91E63),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _categoryNameController,
                      decoration: InputDecoration(
                        labelText: '分类名称',
                        labelStyle: TextStyle(color: Color(0xFFE91E63)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE91E63)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('选择图标:', style: TextStyle(color: Color(0xFFE91E63))),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _iconCategories.entries.map((entry) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF795548),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: entry.value.map((icon) {
                                        return GestureDetector(
                                          onTap: () {
                                            // 使用对话框内部的setState，只更新对话框内容
                                            setState(() {
                                              tempSelectedIcon = icon;
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.all(4),
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: tempSelectedIcon == icon
                                                    ? Color(0xFFE91E63)
                                                    : Colors.grey,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: tempSelectedIcon == icon
                                                  ? Color(
                                                      0xFFE91E63,
                                                    ).withOpacity(0.1)
                                                  : Colors.transparent,
                                            ),
                                            child: Text(
                                              icon,
                                              style: TextStyle(fontSize: 24),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('取消', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE91E63),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final categoryName = _categoryNameController.text.trim();
                      if (categoryName.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text('分类名称不能为空'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final provider = Provider.of<ClothingProvider>(
                        dialogContext,
                        listen: false,
                      );

                      // 创建更新后的分类对象
                      CustomCategory updatedCategory = CustomCategory(
                        id: category.id,
                        name: categoryName,
                        icon: tempSelectedIcon,
                        parentId: category.parentId,
                        children: [],
                      );

                      await provider.updateCustomCategory(updatedCategory);

                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('分类更新成功'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      print('分类更新成功: $categoryName');
                    } catch (e) {
                      print('更新分类失败: $e');
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('确认'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddSubCategoryDialog(CustomCategory parentCategory) {
    print('添加子分类按钮被点击');
    print('父分类ID: ${parentCategory.id}, 名称: ${parentCategory.name}');

    // 初始化控制器和选中图标
    _categoryNameController.clear();
    String tempSelectedIcon = '🎨';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                '添加子分类',
                style: TextStyle(
                  color: Color(0xFFE91E63),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _categoryNameController,
                      decoration: InputDecoration(
                        labelText: '子分类名称',
                        labelStyle: TextStyle(color: Color(0xFFE91E63)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE91E63)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('选择图标:', style: TextStyle(color: Color(0xFFE91E63))),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _iconCategories.entries.map((entry) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF795548),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: entry.value.map((icon) {
                                        return GestureDetector(
                                          onTap: () {
                                            // 使用对话框内部的setState，只更新对话框内容
                                            setState(() {
                                              tempSelectedIcon = icon;
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.all(4),
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: tempSelectedIcon == icon
                                                    ? Color(0xFFE91E63)
                                                    : Colors.grey,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: tempSelectedIcon == icon
                                                  ? Color(
                                                      0xFFE91E63,
                                                    ).withOpacity(0.1)
                                                  : Colors.transparent,
                                            ),
                                            child: Text(
                                              icon,
                                              style: TextStyle(fontSize: 24),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('取消', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE91E63),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final categoryName = _categoryNameController.text.trim();
                      if (categoryName.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text('分类名称不能为空'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final provider = Provider.of<ClothingProvider>(
                        dialogContext,
                        listen: false,
                      );

                      // 创建子分类对象
                      CustomCategory subCategory = CustomCategory(
                        name: categoryName,
                        icon: tempSelectedIcon,
                        parentId: parentCategory.id,
                        children: [],
                      );

                      await provider.addCustomCategory(subCategory);

                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('子分类添加成功'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      print('子分类添加成功: $categoryName');
                    } catch (e) {
                      print('添加子分类失败: $e');
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('确认'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(CustomCategory category) {
    print('删除分类按钮被点击');
    print('分类ID: ${category.id}, 名称: ${category.name}');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '确认删除',
            style: TextStyle(
              color: Color(0xFFE91E63),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            '确定要删除分类 "${category.name}" 吗？删除后无法恢复。',
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
              onPressed: () async {
                try {
                  if (category.id == null) {
                    throw Exception('分类ID不存在');
                  }

                  final provider = Provider.of<ClothingProvider>(
                    context,
                    listen: false,
                  );
                  await provider.deleteCustomCategory(category.id!);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('分类删除成功'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  print('分类删除成功: ${category.name}');
                } catch (e) {
                  print('删除分类失败: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('删除'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryTreeItem(CustomCategory category, [int level = 0]) {
    final bool hasChildren = category.children.isNotEmpty;
    final bool isExpanded =
        _expandedCategories[category.id?.toString()] ?? false;

    return Padding(
      padding: EdgeInsets.only(left: level * 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.symmetric(vertical: 4),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: hasChildren
                  ? IconButton(
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Color(0xFFE91E63),
                      ),
                      onPressed: () {
                        setState(() {
                          if (category.id != null) {
                            _expandedCategories[category.id!.toString()] =
                                !isExpanded;
                          }
                        });
                      },
                    )
                  : Container(
                      width: 48,
                      child: Text(
                        category.icon ?? '🎨',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
              // title: Row(
              //   children: [
              //     if (!hasChildren)
              //       Text(category.icon ?? '🎨', style: TextStyle(fontSize: 20)),
              //     SizedBox(width: 8),
              //     Text(category.name),
              //   ],
              // ),
              trailing: PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Color(0xFFE91E63)),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Text('编辑')),
                  PopupMenuItem(value: 'add_sub', child: Text('添加子分类')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('删除'),
                    textStyle: TextStyle(color: Colors.red),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditCategoryDialog(category);
                  } else if (value == 'add_sub') {
                    _showAddSubCategoryDialog(category);
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(category);
                  }
                },
              ),
            ),
          ),
          // 递归渲染子分类
          if (hasChildren && isExpanded)
            for (var child in category.children)
              _buildCategoryTreeItem(child, level + 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE91E63),
        title: Text(
          '分类管理',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Color(0xFFFEF5F5),
      body: Consumer<ClothingProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '自定义分类',
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                provider.customCategories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            Text(
                              '暂无自定义分类',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              '点击下方按钮添加分类',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        child: ListView(
                          children: provider.customCategoryTree.isNotEmpty
                              ? provider.customCategoryTree
                                    .map(
                                      (category) =>
                                          _buildCategoryTreeItem(category),
                                    )
                                    .toList()
                              : [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.amber,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '分类树构建异常，可能存在孤立分类',
                                          style: TextStyle(color: Colors.amber),
                                        ),
                                        SizedBox(height: 16),
                                        Text('所有分类列表:'),
                                        SizedBox(height: 8),
                                        ...provider.customCategories
                                            .map(
                                              (category) =>
                                                  _buildCategoryTreeItem(
                                                    category,
                                                  ),
                                            )
                                            .toList(),
                                      ],
                                    ),
                                  ),
                                ],
                        ),
                      ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFE91E63),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          print('添加分类按钮被点击');
          try {
            _showAddCategoryDialog();
          } catch (e) {
            print('添加分类对话框显示失败: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('操作失败，请重试'), backgroundColor: Colors.red),
            );
          }
        },
        child: Icon(Icons.add, size: 28),
        elevation: 5,
      ),
    );
  }
}
