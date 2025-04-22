/// حالات المنتج المختلفة في النظام
enum ProductStatus {
  /// المنتج متاح للشراء
  available,
  
  /// المنتج غير متاح حالياً
  outOfStock,
  
  /// المنتج سيتوفر قريباً
  comingSoon,
  
  /// المنتج متوقف
  discontinued,
  
  /// المنتج في حالة عروض خاصة
  onSale,
  
  /// المنتج حصري
  exclusive,
}
