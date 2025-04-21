import 'package:equatable/equatable.dart';

/// الكيان الأساسي الذي تمثل جميع كيانات المجال
/// يوفِّر المعرف الفريد ويعتمد على مكتبة Equatable للمقارنة
abstract class Entity extends Equatable {
  /// المعرف الفريد للكيان
  final String id;

  /// منشئ الكيان الأساسي
  const Entity({required this.id});

  @override
  List<Object?> get props => [id];
}
