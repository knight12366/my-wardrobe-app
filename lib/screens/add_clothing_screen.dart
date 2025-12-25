import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/clothing_provider.dart';
import '../models/clothing_item.dart';
import '../models/custom_category.dart';
import 'dart:io';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({Key? key}) : super(key: key);

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  String? _name;
  String? _description;
  ClothingCategory _category = ClothingCategory.custom;
  String? _customCategoryName;
  List<String> _colors = [];
  String? _colorInput;
  String? _season;
  String? _brand;
  String? _size;
  DateTime? _purchaseDate;
  String? _location;
  bool _isFavorite = false;
  String? _photoNote;

  // 选择图片
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        // 如果是拍照，显示备注对话框
        if (source == ImageSource.camera) {
          _showPhotoNoteDialog();
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // 显示拍照备注对话框
  void _showPhotoNoteDialog() {
    final TextEditingController noteController = TextEditingController(
      text: _photoNote,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '添加备注',
          style: TextStyle(color: Colors.lightBlueAccent),
        ),
        backgroundColor: Color(0xFFFFF3F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: '为这张照片添加备注',
            labelStyle: TextStyle(color: Color(0xFFE91E63)),
            hintText: '例如：购买于商场、材质很舒服等',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFFE91E63)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('跳过', style: TextStyle(color: Color(0xFF795548))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _photoNote = noteController.text.trim();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.limeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 显示图片选择对话框
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '选择图片',
          style: TextStyle(color: Color.fromARGB(136, 233, 30, 98)),
        ),
        backgroundColor: Color(0xFFFFF3F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 添加颜色
  void _addColor() {
    if (_colorInput != null && _colorInput!.trim().isNotEmpty) {
      setState(() {
        _colors.add(_colorInput!.trim());
        _colorInput = '';
      });
    }
  }

  // 删除颜色
  void _removeColor(String color) {
    setState(() {
      _colors.remove(color);
    });
  }

  // 选择购买日期
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  // 提交表单
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final clothingItem = ClothingItem(
        imagePath: _imageFile?.path,
        name: _name!,
        description: _description,
        category: _category,
        customCategory: _customCategoryName,
        colors: _colors.isNotEmpty ? _colors : null,
        season: _season,
        brand: _brand,
        size: _size,
        purchaseDate: _purchaseDate,
        location: _location,
        isFavorite: _isFavorite,
        photoNote: _photoNote,
      );

      Provider.of<ClothingProvider>(
        context,
        listen: false,
      ).addClothing(clothingItem);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '添加服装',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Color.fromARGB(255, 30, 233, 203),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Color(0xFFFEF5F5),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 100.0,
              ), // 为底部按钮留出空间
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 图片选择
                    GestureDetector(
                      onTap: _showImagePickerDialog,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color.fromARGB(255, 30, 182, 233),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(
                                255,
                                213,
                                233,
                                30,
                              ).withOpacity(0.3),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _imageFile != null
                            ? Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      color: Color(0xFFE91E63),
                                      size: 40,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '点击添加图片',
                                      style: TextStyle(
                                        color: Color(0xFFE91E63),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 基本信息
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '名称 *',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 233, 30, 223),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 30, 209, 233),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入名称';
                        }
                        return null;
                      },
                      onSaved: (value) => _name = value,
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '描述',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 30, 233, 121),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 30, 233, 186),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 30, 135, 233),
                            width: 2,
                          ),
                        ),
                      ),
                      maxLines: 3,
                      onSaved: (value) => _description = value,
                    ),
                    const SizedBox(height: 16),

                    // 分类选择
                    Text(
                      '分类 *',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    Divider(color: Color(0xFFE91E63)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        // 自定义分类
                        ...Provider.of<ClothingProvider>(
                          context,
                        ).customCategories.map((category) {
                          return ChoiceChip(
                            label: Row(
                              children: [
                                Text(
                                  category.icon,
                                  style: TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            selectedColor: Color(0xFFE91E63),
                            checkmarkColor: Colors.white,
                            selected:
                                _category == ClothingCategory.custom &&
                                _customCategoryName == category.name,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color:
                                    _category == ClothingCategory.custom &&
                                        _customCategoryName == category.name
                                    ? Color(0xFFE91E63)
                                    : Color(0xFFE91E63).withOpacity(0.3),
                              ),
                            ),
                            elevation:
                                _category == ClothingCategory.custom &&
                                    _customCategoryName == category.name
                                ? 3
                                : 1,
                            onSelected: (selected) {
                              setState(() {
                                _category = ClothingCategory.custom;
                                _customCategoryName = category.name;
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 8),

                    const SizedBox(height: 16),

                    // 颜色管理
                    Text(
                      '颜色',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    Divider(color: Color(0xFFE91E63)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: '添加颜色',
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
                            controller: TextEditingController(
                              text: _colorInput,
                            ),
                            onChanged: (value) => _colorInput = value,
                            onSubmitted: (value) {
                              _colorInput = value;
                              _addColor();
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Color(0xFFE91E63)),
                          onPressed: _addColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: _colors.map((color) {
                        return Chip(
                          label: Text(
                            color,
                            style: TextStyle(color: Color(0xFF5D4037)),
                          ),
                          onDeleted: () => _removeColor(color),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Color(0xFFE91E63).withOpacity(0.3),
                            ),
                          ),
                          elevation: 1,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 其他信息
                    Text(
                      '其他信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    Divider(color: Color(0xFFE91E63)),
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '季节 (春季/夏季/秋季/冬季/四季)',
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
                      onSaved: (value) => _season = value,
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
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
                      onSaved: (value) => _brand = value,
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
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
                      onSaved: (value) => _size = value,
                    ),
                    const SizedBox(height: 8),

                    // 购买日期
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '购买日期',
                          style: TextStyle(
                            color: Color(0xFFE91E63),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _selectDate(context),
                          child: Text(
                            _purchaseDate != null
                                ? '${_purchaseDate?.year}-${_purchaseDate?.month}-${_purchaseDate?.day}'
                                : '选择日期',
                            style: TextStyle(color: Color(0xFFE91E63)),
                          ),
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(
                              Color(0xFFE91E63),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
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
                      onSaved: (value) => _location = value,
                    ),
                    const SizedBox(height: 16),

                    // 拍照备注
                    TextFormField(
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
                      onSaved: (value) => _photoNote = value?.trim(),
                      initialValue: _photoNote,
                    ),
                    const SizedBox(height: 16),

                    // 收藏
                    CheckboxListTile(
                      title: Text(
                        '标记为收藏',
                        style: TextStyle(
                          color: Color(0xFFE91E63),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: _isFavorite,
                      onChanged: (value) {
                        setState(() {
                          _isFavorite = value ?? false;
                        });
                      },
                      activeColor: Color(0xFFE91E63),
                      checkColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 底部保存按钮（修复：只保留一个按钮）
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 30, 233, 47),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  shadowColor: Color(0xFFE91E63).withOpacity(0.5),
                ),
                child: Text(
                  '保存服装',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
