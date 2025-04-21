import 'package:flutter/material.dart';

/// مكونات الشاشات المحسنة للتطبيق
/// توفر مكونات شاشات بتصميم موحد وتجربة مستخدم محسنة
class EnhancedScreens {
  /// شاشة تحميل محسنة
  /// توفر شاشة تحميل بتصميم موحد مع رسوم متحركة
  static Widget loading({
    String? message,
    Color? backgroundColor,
    Color? indicatorColor,
    double indicatorSize = 50.0,
    TextStyle? messageStyle,
  }) {
    return _EnhancedLoadingScreen(
      message: message,
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      indicatorSize: indicatorSize,
      messageStyle: messageStyle,
    );
  }

  /// شاشة خطأ محسنة
  /// توفر شاشة خطأ بتصميم موحد مع إمكانية إعادة المحاولة
  static Widget error({
    required String message,
    String? title,
    VoidCallback? onRetry,
    String retryText = 'إعادة المحاولة',
    IconData icon = Icons.error_outline,
    Color? backgroundColor,
    Color? iconColor,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    TextStyle? buttonTextStyle,
  }) {
    return _EnhancedErrorScreen(
      message: message,
      title: title,
      onRetry: onRetry,
      retryText: retryText,
      icon: icon,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      buttonTextStyle: buttonTextStyle,
    );
  }

  /// شاشة فارغة محسنة
  /// توفر شاشة فارغة بتصميم موحد مع إمكانية إضافة عناصر
  static Widget empty({
    required String message,
    String? title,
    VoidCallback? onAction,
    String? actionText,
    IconData icon = Icons.inbox,
    Color? backgroundColor,
    Color? iconColor,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    TextStyle? buttonTextStyle,
  }) {
    return _EnhancedEmptyScreen(
      message: message,
      title: title,
      onAction: onAction,
      actionText: actionText,
      icon: icon,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      buttonTextStyle: buttonTextStyle,
    );
  }

  /// شاشة نجاح محسنة
  /// توفر شاشة نجاح بتصميم موحد مع إمكانية إضافة إجراء
  static Widget success({
    required String message,
    String? title,
    VoidCallback? onAction,
    String? actionText,
    IconData icon = Icons.check_circle_outline,
    Color? backgroundColor,
    Color? iconColor,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    TextStyle? buttonTextStyle,
  }) {
    return _EnhancedSuccessScreen(
      message: message,
      title: title,
      onAction: onAction,
      actionText: actionText,
      icon: icon,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      buttonTextStyle: buttonTextStyle,
    );
  }

  /// شاشة بحث محسنة
  /// توفر شاشة بحث بتصميم موحد مع إمكانية تخصيص نتائج البحث
  static Widget search<T>({
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    required String Function(T) searchFilter,
    required String searchHint,
    Widget? emptyResultWidget,
    Color? backgroundColor,
    TextStyle? searchTextStyle,
    Color? searchIconColor,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
  }) {
    return _EnhancedSearchScreen<T>(
      items: items,
      itemBuilder: itemBuilder,
      searchFilter: searchFilter,
      searchHint: searchHint,
      emptyResultWidget: emptyResultWidget,
      backgroundColor: backgroundColor,
      searchTextStyle: searchTextStyle,
      searchIconColor: searchIconColor,
      padding: padding,
    );
  }
}

/// شاشة تحميل محسنة
class _EnhancedLoadingScreen extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double indicatorSize;
  final TextStyle? messageStyle;

  const _EnhancedLoadingScreen({
    this.message,
    this.backgroundColor,
    this.indicatorColor,
    required this.indicatorSize,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = backgroundColor ??
        (theme.brightness == Brightness.dark ? Colors.black12 : Colors.white);

    final effectiveIndicatorColor = indicatorColor ?? theme.primaryColor;

    final effectiveMessageStyle = messageStyle ??
        TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.white70
              : Colors.black54,
          fontSize: 16,
        );

    return Container(
      color: effectiveBackgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: indicatorSize,
              height: indicatorSize,
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(effectiveIndicatorColor),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: effectiveMessageStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// شاشة خطأ محسنة
class _EnhancedErrorScreen extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String retryText;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final TextStyle? buttonTextStyle;

  const _EnhancedErrorScreen({
    required this.message,
    this.title,
    this.onRetry,
    required this.retryText,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.titleStyle,
    this.messageStyle,
    this.buttonTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = backgroundColor ??
        (theme.brightness == Brightness.dark ? Colors.black12 : Colors.white);

    final effectiveIconColor = iconColor ??
        (theme.brightness == Brightness.dark ? Colors.redAccent : Colors.red);

    final effectiveTitleStyle = titleStyle ??
        TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        );

    final effectiveMessageStyle = messageStyle ??
        TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.white70
              : Colors.black54,
          fontSize: 16,
        );

    final effectiveButtonTextStyle = buttonTextStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        );

    return Container(
      color: effectiveBackgroundColor,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: effectiveIconColor,
              size: 80,
            ),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: effectiveTitleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: effectiveMessageStyle,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: effectiveIconColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  retryText,
                  style: effectiveButtonTextStyle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// شاشة فارغة محسنة
class _EnhancedEmptyScreen extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onAction;
  final String? actionText;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final TextStyle? buttonTextStyle;

  const _EnhancedEmptyScreen({
    required this.message,
    this.title,
    this.onAction,
    this.actionText,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.titleStyle,
    this.messageStyle,
    this.buttonTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = backgroundColor ??
        (theme.brightness == Brightness.dark ? Colors.black12 : Colors.white);

    final effectiveIconColor = iconColor ??
        (theme.brightness == Brightness.dark ? Colors.white54 : Colors.black38);

    final effectiveTitleStyle = titleStyle ??
        TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        );

    final effectiveMessageStyle = messageStyle ??
        TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.white70
              : Colors.black54,
          fontSize: 16,
        );

    final effectiveButtonTextStyle = buttonTextStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        );

    return Container(
      color: effectiveBackgroundColor,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: effectiveIconColor,
              size: 80,
            ),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: effectiveTitleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: effectiveMessageStyle,
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: effectiveButtonTextStyle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// شاشة نجاح محسنة
class _EnhancedSuccessScreen extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onAction;
  final String? actionText;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final TextStyle? buttonTextStyle;

  const _EnhancedSuccessScreen({
    required this.message,
    this.title,
    this.onAction,
    this.actionText,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.titleStyle,
    this.messageStyle,
    this.buttonTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = backgroundColor ??
        (theme.brightness == Brightness.dark ? Colors.black12 : Colors.white);

    final effectiveIconColor = iconColor ??
        (theme.brightness == Brightness.dark
            ? Colors.greenAccent
            : Colors.green);

    final effectiveTitleStyle = titleStyle ??
        TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        );

    final effectiveMessageStyle = messageStyle ??
        TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.white70
              : Colors.black54,
          fontSize: 16,
        );

    final effectiveButtonTextStyle = buttonTextStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        );

    return Container(
      color: effectiveBackgroundColor,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: effectiveIconColor,
              size: 80,
            ),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: effectiveTitleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: effectiveMessageStyle,
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: effectiveIconColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: effectiveButtonTextStyle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// شاشة بحث محسنة
class _EnhancedSearchScreen<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final String Function(T) searchFilter;
  final String searchHint;
  final Widget? emptyResultWidget;
  final Color? backgroundColor;
  final TextStyle? searchTextStyle;
  final Color? searchIconColor;
  final EdgeInsetsGeometry padding;

  const _EnhancedSearchScreen({
    required this.items,
    required this.itemBuilder,
    required this.searchFilter,
    required this.searchHint,
    this.emptyResultWidget,
    this.backgroundColor,
    this.searchTextStyle,
    this.searchIconColor,
    required this.padding,
  });

  @override
  _EnhancedSearchScreenState<T> createState() =>
      _EnhancedSearchScreenState<T>();
}

class _EnhancedSearchScreenState<T> extends State<_EnhancedSearchScreen<T>> {
  late TextEditingController _searchController;
  List<T> _filteredItems = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => widget
                .searchFilter(item)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = widget.backgroundColor ??
        (theme.brightness == Brightness.dark ? Colors.black12 : Colors.white);

    final effectiveSearchTextStyle = widget.searchTextStyle ??
        TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
          fontSize: 16,
        );

    final effectiveSearchIconColor = widget.searchIconColor ??
        (theme.brightness == Brightness.dark ? Colors.white54 : Colors.black54);

    return Container(
      color: effectiveBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: effectiveSearchTextStyle,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: effectiveSearchTextStyle.copyWith(
                    color: effectiveSearchTextStyle.color!.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: effectiveSearchIconColor,
                  ),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: effectiveSearchIconColor,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _filterItems('');
                            setState(() {
                              _isSearching = false;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  _filterItems(value);
                  setState(() {
                    _isSearching = value.isNotEmpty;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? widget.emptyResultWidget ??
                    Center(
                      child: Text(
                        'لا توجد نتائج',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    )
                : ListView.builder(
                    padding: widget.padding,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return widget.itemBuilder(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
