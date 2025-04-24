import 'package:flutter/material.dart';

/// قائمة الفئات
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
