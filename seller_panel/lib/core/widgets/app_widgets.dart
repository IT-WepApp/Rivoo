import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// مكونات واجهة المستخدم المشتركة للتطبيق
class AppWidgets {
  // زر أساسي موحد
  static Widget appButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isOutlined = false,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    double width = double.infinity,
    double height = 48,
    double borderRadius = 8,
  }) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: textColor,
            side: BorderSide(color: textColor ?? Colors.transparent),
            minimumSize: Size(width, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          )
        : ElevatedButton.styleFrom(
            foregroundColor: textColor,
            backgroundColor: backgroundColor,
            minimumSize: Size(width, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          );

    Widget child = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(text),
                ],
              )
            : Text(text);

    return isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: child,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: child,
          );
  }

  // حقل إدخال نص موحد
  static Widget appTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    int? maxLines = 1,
    int? maxLength,
    bool enabled = true,
    FocusNode? focusNode,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    TextInputAction? textInputAction,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding,
      ),
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      focusNode: focusNode,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      textInputAction: textInputAction,
    );
  }

  // بطاقة عرض موحدة
  static Widget appCard({
    required Widget child,
    double elevation = 2,
    Color? color,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    final card = Card(
      elevation: elevation,
      color: color,
      margin: margin ?? const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    return onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            child: card,
          )
        : card;
  }

  // شريط تبويب سفلي موحد
  static Widget appBottomNavigationBar({
    required int currentIndex,
    required Function(int) onTap,
    required List<BottomNavigationBarItem> items,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  // مؤشر حالة الطلب
  static Widget orderStatusStepper({
    required String currentStatus,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final statuses = [
      'pending',
      'preparing',
      'delivering',
      'delivered',
    ];
    
    final statusLabels = {
      'pending': 'قيد الانتظار',
      'preparing': 'جاري التحضير',
      'delivering': 'قيد التوصيل',
      'delivered': 'تم التوصيل',
    };
    
    final statusIcons = {
      'pending': Icons.hourglass_empty,
      'preparing': Icons.restaurant,
      'delivering': Icons.delivery_dining,
      'delivered': Icons.check_circle,
    };
    
    final currentStep = statuses.indexOf(currentStatus);
    
    return Stepper(
      currentStep: currentStep >= 0 ? currentStep : 0,
      controlsBuilder: (context, details) => Container(),
      steps: statuses.map((status) {
        final index = statuses.indexOf(status);
        final isActive = index <= currentStep;
        
        return Step(
          title: Text(
            statusLabels[status] ?? status,
            style: TextStyle(
              color: isActive ? theme.colorScheme.primary : theme.disabledColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          content: Container(),
          isActive: isActive,
          state: index < currentStep
              ? StepState.complete
              : index == currentStep
                  ? StepState.indexed
                  : StepState.disabled,
          icon: Icon(
            statusIcons[status] ?? Icons.circle,
            color: isActive ? theme.colorScheme.primary : theme.disabledColor,
          ),
        );
      }).toList(),
    );
  }

  // مؤشر تحميل مع نص
  static Widget loadingIndicator({
    String? message,
    double size = 36,
    Color? color,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Colors.blue,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // رسالة خطأ موحدة
  static Widget errorMessage({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ],
      ),
    );
  }

  // شريط بحث موحد
  static Widget searchBar({
    required TextEditingController controller,
    required Function(String) onSearch,
    String hintText = 'بحث...',
    VoidCallback? onFilterPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: onSearch,
              textInputAction: TextInputAction.search,
              onSubmitted: onSearch,
            ),
          ),
          if (onFilterPressed != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: onFilterPressed,
              tooltip: 'تصفية',
            ),
          ],
        ],
      ),
    );
  }

  // عنصر قائمة منتج
  static Widget productListItem({
    required String productId,
    required String name,
    required double price,
    String? imageUrl,
    bool isAvailable = true,
    VoidCallback? onTap,
    VoidCallback? onEdit,
    VoidCallback? onToggleAvailability,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: imageUrl != null && imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              )
            : Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image),
              ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isAvailable ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${price.toStringAsFixed(2)} ر.س',
              style: TextStyle(
                color: isAvailable ? Colors.green.shade700 : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              isAvailable ? 'متوفر' : 'غير متوفر',
              style: TextStyle(
                color: isAvailable ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onToggleAvailability != null)
              IconButton(
                icon: Icon(
                  isAvailable ? Icons.visibility : Icons.visibility_off,
                  color: isAvailable ? Colors.green : Colors.grey,
                ),
                onPressed: onToggleAvailability,
                tooltip: isAvailable ? 'إخفاء' : 'إظهار',
              ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'تعديل',
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  // عنصر قائمة طلب
  static Widget orderListItem({
    required String orderId,
    required String status,
    required double total,
    required DateTime date,
    required String customerName,
    VoidCallback? onTap,
  }) {
    final statusColors = {
      'pending': Colors.orange,
      'preparing': Colors.blue,
      'delivering': Colors.purple,
      'delivered': Colors.green,
      'cancelled': Colors.red,
    };
    
    final statusLabels = {
      'pending': 'قيد الانتظار',
      'preparing': 'جاري التحضير',
      'delivering': 'قيد التوصيل',
      'delivered': 'تم التوصيل',
      'cancelled': 'ملغي',
    };
    
    final statusColor = statusColors[status] ?? Colors.grey;
    final statusLabel = statusLabels[status] ?? status;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Row(
          children: [
            Text(
              'طلب #$orderId',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 4),
                Text(customerName),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16),
                const SizedBox(width: 4),
                Text(
                  'المجموع: ${total.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // مربع حوار تأكيد
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDangerous ? Colors.red : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  // مربع حوار اختيار
  static Future<T?> showSelectionDialog<T>({
    required BuildContext context,
    required String title,
    required List<T> options,
    required String Function(T) labelBuilder,
    String? message,
  }) async {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null) ...[
              Text(message),
              const SizedBox(height: 16),
            ],
            ...options.map(
              (option) => ListTile(
                title: Text(labelBuilder(option)),
                onTap: () => Navigator.of(context).pop(option),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  // شريط تنبيه
  static void showSnackBar({
    required BuildContext context,
    required String message,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    Color backgroundColor;
    Color textColor = Colors.white;
    
    if (isError) {
      backgroundColor = Colors.red;
    } else if (isSuccess) {
      backgroundColor = Colors.green;
    } else {
      backgroundColor = Colors.black;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: textColor,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
