import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clothing_provider.dart';
import '../models/clothing_item.dart';
import 'dart:io';

class ClothingDetailScreen extends StatefulWidget {
  final ClothingItem item;

  const ClothingDetailScreen({super.key, required this.item});

  @override
  State<ClothingDetailScreen> createState() => _ClothingDetailScreenState();
}

class _ClothingDetailScreenState extends State<ClothingDetailScreen> {
  bool _isEditing = false;
  late ClothingItem _editingItem;

  @override
  void initState() {
    super.initState();
    _editingItem = ClothingItem(
      id: widget.item.id,
      imagePath: widget.item.imagePath,
      name: widget.item.name,
      description: widget.item.description,
      category: widget.item.category,
      colors: widget.item.colors != null
          ? List.from(widget.item.colors!)
          : null,
      season: widget.item.season,
      brand: widget.item.brand,
      size: widget.item.size,
      purchaseDate: widget.item.purchaseDate,
      location: widget.item.location,
      isFavorite: widget.item.isFavorite,
      photoNote: widget.item.photoNote,
    );
  }

  // 保存编辑
  void _saveEdit() {
    Provider.of<ClothingProvider>(
      context,
      listen: false,
    ).updateClothing(_editingItem);
    setState(() {
      _isEditing = false;
    });
  }

  // 删除服装
  void _deleteClothing() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除服装', style: TextStyle(color: Color(0xFFE91E63))),
        backgroundColor: Color(0xFFFFF3F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Text(
          '确定要删除这件服装吗？',
          style: TextStyle(color: Color(0xFF795548)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Color(0xFF795548))),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ClothingProvider>(
                context,
                listen: false,
              ).deleteClothing(widget.item.id!);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFFE91E63),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Text(value, style: TextStyle(fontSize: 16, color: Color(0xFF5D4037))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _isEditing ? _editingItem : widget.item;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFE91E63),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              item.isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 24,
            ),
            color: item.isFavorite ? Colors.yellow : Colors.white,
            onPressed: () {
              if (_isEditing) {
                setState(() {
                  _editingItem.isFavorite = !_editingItem.isFavorite;
                });
              } else {
                Provider.of<ClothingProvider>(
                  context,
                  listen: false,
                ).toggleFavorite(item.id!);
              }
            },
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, size: 24, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            ElevatedButton(
              onPressed: _saveEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFFE91E63),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('保存'),
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, size: 24, color: Colors.white),
              onPressed: _deleteClothing,
            ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 服装图片
              Center(
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE91E63), width: 2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(
                          233,
                          30,
                          99,
                          0.3,
                        ), // Color(0xFFE91E63) with opacity 0.3
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: item.imagePath != null
                      ? Image.file(File(item.imagePath!), fit: BoxFit.contain)
                      : Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // 基本信息
              ListTile(
                leading: Icon(Icons.category, color: Color(0xFFE91E63)),
                title: Text(
                  item.displayCategoryName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ),

              // 分类和名称信息
              _isEditing
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 分类编辑
                        const Text(
                          '选择分类:',
                          style: TextStyle(
                            color: Color(0xFFE91E63),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            // 自定义分类选择
                            ...Provider.of<ClothingProvider>(
                              context,
                            ).customCategories.map((customCategory) {
                              return ChoiceChip(
                                label: Row(
                                  children: [
                                    Text(
                                      customCategory.icon,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      customCategory.name,
                                      style: TextStyle(
                                        color:
                                            _editingItem.category ==
                                                    ClothingCategory.custom &&
                                                _editingItem.customCategory ==
                                                    customCategory.name
                                            ? Colors.white
                                            : Color(0xFF5D4037),
                                      ),
                                    ),
                                  ],
                                ),
                                selected:
                                    _editingItem.category ==
                                        ClothingCategory.custom &&
                                    _editingItem.customCategory ==
                                        customCategory.name,
                                backgroundColor: Colors.white,
                                selectedColor: Color(0xFFE91E63),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color:
                                        _editingItem.category ==
                                                ClothingCategory.custom &&
                                            _editingItem.customCategory ==
                                                customCategory.name
                                        ? Color(0xFFE91E63)
                                        : Color.fromRGBO(233, 30, 99, 0.3),
                                  ),
                                ),
                                elevation:
                                    _editingItem.category ==
                                            ClothingCategory.custom &&
                                        _editingItem.customCategory ==
                                            customCategory.name
                                    ? 3
                                    : 1,
                                onSelected: (selected) {
                                  setState(() {
                                    _editingItem.category =
                                        ClothingCategory.custom;
                                    _editingItem.customCategory =
                                        customCategory.name;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 显示当前选中的自定义分类名称
                        if (_editingItem.category == ClothingCategory.custom)
                          TextFormField(
                            initialValue: _editingItem.customCategory,
                            decoration: InputDecoration(
                              labelText: '自定义分类名称',
                              labelStyle: TextStyle(color: Color(0xFFE91E63)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Color(0xFFE91E63),
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) =>
                                _editingItem.customCategory = value,
                          ),
                        const SizedBox(height: 16),

                        // 其他基本信息编辑
                        TextFormField(
                          initialValue: item.name,
                          decoration: InputDecoration(
                            labelText: '名称',
                            labelStyle: TextStyle(color: Color(0xFFE91E63)),
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
                          onChanged: (value) => _editingItem.name = value,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: item.description,
                          decoration: InputDecoration(
                            labelText: '描述',
                            labelStyle: TextStyle(color: Color(0xFFE91E63)),
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
                          maxLines: 3,
                          onChanged: (value) =>
                              _editingItem.description = value,
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('名称', item.name),

                        // 描述信息
                        if (item.description != null)
                          _buildInfoRow('描述', item.description!),
                      ],
                    ),

              // 详细信息
              const SizedBox(height: 20),
              Text(
                '详细信息',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
              Divider(color: Color(0xFFE91E63)),

              if (item.colors != null && item.colors!.isNotEmpty)
                _buildInfoRow('颜色', item.colors!.join(', ')),

              if (item.season != null || _isEditing)
                _isEditing
                    ? TextFormField(
                        initialValue: item.season,
                        decoration: InputDecoration(
                          labelText: '季节',
                          labelStyle: TextStyle(color: Color(0xFFE91E63)),
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
                        onChanged: (value) => _editingItem.season = value,
                      )
                    : _buildInfoRow('季节', item.season!),

              if (item.brand != null || _isEditing)
                _isEditing
                    ? TextFormField(
                        initialValue: item.brand,
                        decoration: InputDecoration(
                          labelText: '品牌',
                          labelStyle: TextStyle(color: Color(0xFFE91E63)),
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
                        onChanged: (value) => _editingItem.brand = value,
                      )
                    : _buildInfoRow('品牌', item.brand!),

              if (item.size != null || _isEditing)
                _isEditing
                    ? TextFormField(
                        initialValue: item.size,
                        decoration: InputDecoration(
                          labelText: '尺码',
                          labelStyle: TextStyle(color: Color(0xFFE91E63)),
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
                        onChanged: (value) => _editingItem.size = value,
                      )
                    : _buildInfoRow('尺码', item.size!),

              if (item.purchaseDate != null || _isEditing)
                _isEditing
                    ? Row(
                        children: [
                          const Text(
                            '购买日期: ',
                            style: TextStyle(
                              color: Color(0xFFE91E63),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              foregroundColor: WidgetStateProperty.all(
                                Color(0xFFE91E63),
                              ),
                            ),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    _editingItem.purchaseDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _editingItem.purchaseDate = picked;
                                });
                              }
                            },
                            child: Text(
                              _editingItem.purchaseDate != null
                                  ? '${_editingItem.purchaseDate?.year}-${_editingItem.purchaseDate?.month}-${_editingItem.purchaseDate?.day}'
                                  : '选择日期',
                            ),
                          ),
                        ],
                      )
                    : _buildInfoRow(
                        '购买日期',
                        '${item.purchaseDate?.year}-${item.purchaseDate?.month}-${item.purchaseDate?.day}',
                      ),

              if (item.location != null || _isEditing)
                _isEditing
                    ? TextFormField(
                        initialValue: item.location,
                        decoration: InputDecoration(
                          labelText: '存放位置',
                          labelStyle: TextStyle(color: Color(0xFFE91E63)),
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
                        onChanged: (value) => _editingItem.location = value,
                      )
                    : _buildInfoRow('存放位置', item.location!),

              // 拍照备注
              if (item.photoNote != null && !_isEditing)
                _buildInfoRow('拍照备注', item.photoNote!),
              if (_isEditing)
                TextFormField(
                  initialValue: item.photoNote,
                  decoration: InputDecoration(
                    labelText: '拍照备注',
                    labelStyle: TextStyle(color: Color(0xFFE91E63)),
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
                  maxLines: 3,
                  onChanged: (value) => _editingItem.photoNote = value,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
