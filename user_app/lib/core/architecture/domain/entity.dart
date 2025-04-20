/// الكيان الأساسي الذي يمثل كائنًا في المجال
/// جميع كيانات المجال يجب أن ترث من هذه الفئة
abstract class Entity {
  /// المعرف الفريد للكيان
  final String id;
  
  /// منشئ الكيان الأساسي
  const Entity({required this.id});
  
  /// طريقة المقارنة بين الكيانات
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Entity && other.id == id;
  }
  
  /// حساب الهاش كود للكيان
  @override
  int get hashCode => id.hashCode;
}
