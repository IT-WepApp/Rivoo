import 'package:equatable/equatable.dart';

/// الكيان الأساسي
/// يمثل كائن نموذج المجال الأساسي الذي يحتوي على المعرف
abstract class Entity extends Equatable {
  final String id;
  
  const Entity({required this.id});
  
  @override
  List<Object?> get props => [id];
}
