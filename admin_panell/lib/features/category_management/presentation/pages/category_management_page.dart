import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/widgets/category_list.dart';
import '../../../../features/dashboard/presentation/widgets/admin_drawer.dart';

/// صفحة إدارة الفئات
class CategoryManagementPage extends ConsumerWidget {
  const CategoryManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفئات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddCategoryDialog(context);
            },
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: CategoryList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// عرض حوار إضافة فئة جديدة
  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة فئة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الفئة',
                  hintText: 'أدخل اسم الفئة',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف الفئة',
                  hintText: 'أدخل وصف الفئة',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // اختيار صورة للفئة
                },
                icon: const Icon(Icons.image),
                label: const Text('اختيار صورة'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // إضافة الفئة الجديدة
              if (nameController.text.isNotEmpty) {
                // يمكن إضافة منطق حفظ الفئة هنا
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم إضافة الفئة ${nameController.text} بنجاح'),
                  ),
                );
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى إدخال اسم الفئة'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}

/// قائمة الفئات (ملف وهمي للتجميع)
class CategoryList extends StatelessWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // هذه بيانات وهمية للعرض فقط
    final categories = [
      {'id': '1', 'name': 'إلكترونيات', 'description': 'أجهزة إلكترونية وملحقاتها'},
      {'id': '2', 'name': 'ملابس', 'description': 'ملابس رجالية ونسائية وأطفال'},
      {'id': '3', 'name': 'أثاث', 'description': 'أثاث منزلي ومكتبي'},
      {'id': '4', 'name': 'مستلزمات المنزل', 'description': 'مستلزمات وأدوات منزلية'},
      {'id': '5', 'name': 'هواتف ذكية', 'description': 'هواتف ذكية وملحقاتها'},
    ];

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(category['name']!),
            subtitle: Text(category['description']!),
            leading: CircleAvatar(
              child: Text(category['name']![0]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // تعديل الفئة
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // حذف الفئة
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
