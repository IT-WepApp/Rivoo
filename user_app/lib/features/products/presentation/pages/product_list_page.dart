import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

class ProductListPage extends StatefulWidget {
  final String? categoryId;
  final String? storeId;
  
  const ProductListPage({
    Key? key,
    this.categoryId,
    this.storeId,
  }) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المنتجات'),
      ),
      body: Center(
        child: Text(
          widget.categoryId != null 
              ? 'منتجات التصنيف: ${widget.categoryId}'
              : widget.storeId != null
                  ? 'منتجات المتجر: ${widget.storeId}'
                  : 'جميع المنتجات'
        ),
      ),
    );
  }
}
