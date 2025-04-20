import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  
  const ProductDetailsPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
      ),
      body: Center(
        child: Text('تفاصيل المنتج رقم: ${widget.productId}'),
      ),
    );
  }
}
