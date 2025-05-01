import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) => ProductService());
