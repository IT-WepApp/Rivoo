import 'package:equatable/equatable.dart';

/// كيان أساسي يمثل كائن له هوية فريدة
abstract class Entity extends Equatable {
  /// معرف الكيان
  final String id;

  /// إنشاء كيان جديد
  const Entity({required this.id});

  /// تحويل الكيان إلى خريطة
  Map<String, dynamic> toMap();

  @override
  List<Object?> get props => [id];

  @override
  bool get stringify => true;
}
