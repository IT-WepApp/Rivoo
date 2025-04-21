import 'package:flutter/material.dart';

/// قائمة محسنة للتطبيق
/// توفر قائمة بتصميم موحد وتجربة مستخدم محسنة
class EnhancedLists {
  /// قائمة عناصر محسنة
  /// توفر قائمة عناصر بتصميم موحد مع تأثيرات تفاعلية
  static Widget itemList<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    Widget? emptyWidget,
    bool isLoading = false,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 8.0),
    double spacing = 8.0,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    ScrollController? controller,
  }) {
    return _EnhancedItemList<T>(
      items: items,
      itemBuilder: itemBuilder,
      emptyWidget: emptyWidget,
      isLoading: isLoading,
      padding: padding,
      spacing: spacing,
      physics: physics,
      shrinkWrap: shrinkWrap,
      controller: controller,
    );
  }

  /// قائمة عناصر قابلة للتحديد محسنة
  /// توفر قائمة عناصر قابلة للتحديد بتصميم موحد مع تأثيرات تفاعلية
  static Widget selectableList<T>({
    required List<T> items,
    required T? selectedItem,
    required void Function(T) onItemSelected,
    required Widget Function(BuildContext, T, bool) itemBuilder,
    Widget? emptyWidget,
    bool isLoading = false,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 8.0),
    double spacing = 8.0,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    ScrollController? controller,
  }) {
    return _EnhancedSelectableList<T>(
      items: items,
      selectedItem: selectedItem,
      onItemSelected: onItemSelected,
      itemBuilder: itemBuilder,
      emptyWidget: emptyWidget,
      isLoading: isLoading,
      padding: padding,
      spacing: spacing,
      physics: physics,
      shrinkWrap: shrinkWrap,
      controller: controller,
    );
  }

  /// قائمة عناصر قابلة للتحديد المتعدد محسنة
  /// توفر قائمة عناصر قابلة للتحديد المتعدد بتصميم موحد مع تأثيرات تفاعلية
  static Widget multiSelectableList<T>({
    required List<T> items,
    required List<T> selectedItems,
    required void Function(List<T>) onItemsSelected,
    required Widget Function(BuildContext, T, bool) itemBuilder,
    Widget? emptyWidget,
    bool isLoading = false,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 8.0),
    double spacing = 8.0,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    ScrollController? controller,
  }) {
    return _EnhancedMultiSelectableList<T>(
      items: items,
      selectedItems: selectedItems,
      onItemsSelected: onItemsSelected,
      itemBuilder: itemBuilder,
      emptyWidget: emptyWidget,
      isLoading: isLoading,
      padding: padding,
      spacing: spacing,
      physics: physics,
      shrinkWrap: shrinkWrap,
      controller: controller,
    );
  }

  /// قائمة عناصر قابلة للسحب محسنة
  /// توفر قائمة عناصر قابلة للسحب بتصميم موحد مع تأثيرات تفاعلية
  static Widget draggableList<T>({
    required List<T> items,
    required void Function(int oldIndex, int newIndex) onReorder,
    required Widget Function(BuildContext, T, int) itemBuilder,
    Widget? emptyWidget,
    bool isLoading = false,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 8.0),
    double spacing = 8.0,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    ScrollController? controller,
  }) {
    return _EnhancedDraggableList<T>(
      items: items,
      onReorder: onReorder,
      itemBuilder: itemBuilder,
      emptyWidget: emptyWidget,
      isLoading: isLoading,
      padding: padding,
      spacing: spacing,
      physics: physics,
      shrinkWrap: shrinkWrap,
      controller: controller,
    );
  }

  /// قائمة عناصر قابلة للتمرير أفقياً محسنة
  /// توفر قائمة عناصر قابلة للتمرير أفقياً بتصميم موحد مع تأثيرات تفاعلية
  static Widget horizontalList<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    Widget? emptyWidget,
    bool isLoading = false,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 8.0),
    double spacing = 8.0,
    ScrollPhysics? physics,
    ScrollController? controller,
    double? itemWidth,
    double itemHeight = 100.0,
  }) {
    return _EnhancedHorizontalList<T>(
      items: items,
      itemBuilder: itemBuilder,
      emptyWidget: emptyWidget,
      isLoading: isLoading,
      padding: padding,
      spacing: spacing,
      physics: physics,
      controller: controller,
      itemWidth: itemWidth,
      itemHeight: itemHeight,
    );
  }
}

/// قائمة عناصر محسنة
class _EnhancedItemList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? emptyWidget;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const _EnhancedItemList({
    required this.items,
    required this.itemBuilder,
    this.emptyWidget,
    required this.isLoading,
    required this.padding,
    required this.spacing,
    this.physics,
    required this.shrinkWrap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (items.isEmpty) {
      return emptyWidget ??
          Center(
            child: Text(
              'لا توجد عناصر',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
                fontSize: 16,
              ),
            ),
          );
    }

    return ListView.separated(
      controller: controller,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        final item = items[index];
        return itemBuilder(context, item, index);
      },
    );
  }
}

/// قائمة عناصر قابلة للتحديد محسنة
class _EnhancedSelectableList<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final void Function(T) onItemSelected;
  final Widget Function(BuildContext, T, bool) itemBuilder;
  final Widget? emptyWidget;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const _EnhancedSelectableList({
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    required this.itemBuilder,
    this.emptyWidget,
    required this.isLoading,
    required this.padding,
    required this.spacing,
    this.physics,
    required this.shrinkWrap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (items.isEmpty) {
      return emptyWidget ??
          Center(
            child: Text(
              'لا توجد عناصر',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
                fontSize: 16,
              ),
            ),
          );
    }

    return ListView.separated(
      controller: controller,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItem == item;
        return GestureDetector(
          onTap: () => onItemSelected(item),
          child: itemBuilder(context, item, isSelected),
        );
      },
    );
  }
}

/// قائمة عناصر قابلة للتحديد المتعدد محسنة
class _EnhancedMultiSelectableList<T> extends StatelessWidget {
  final List<T> items;
  final List<T> selectedItems;
  final void Function(List<T>) onItemsSelected;
  final Widget Function(BuildContext, T, bool) itemBuilder;
  final Widget? emptyWidget;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const _EnhancedMultiSelectableList({
    required this.items,
    required this.selectedItems,
    required this.onItemsSelected,
    required this.itemBuilder,
    this.emptyWidget,
    required this.isLoading,
    required this.padding,
    required this.spacing,
    this.physics,
    required this.shrinkWrap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (items.isEmpty) {
      return emptyWidget ??
          Center(
            child: Text(
              'لا توجد عناصر',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
                fontSize: 16,
              ),
            ),
          );
    }

    return ListView.separated(
      controller: controller,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItems.contains(item);
        return GestureDetector(
          onTap: () {
            final newSelectedItems = List<T>.from(selectedItems);
            if (isSelected) {
              newSelectedItems.remove(item);
            } else {
              newSelectedItems.add(item);
            }
            onItemsSelected(newSelectedItems);
          },
          child: itemBuilder(context, item, isSelected),
        );
      },
    );
  }
}

/// قائمة عناصر قابلة للسحب محسنة
class _EnhancedDraggableList<T> extends StatelessWidget {
  final List<T> items;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? emptyWidget;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const _EnhancedDraggableList({
    required this.items,
    required this.onReorder,
    required this.itemBuilder,
    this.emptyWidget,
    required this.isLoading,
    required this.padding,
    required this.spacing,
    this.physics,
    required this.shrinkWrap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (items.isEmpty) {
      return emptyWidget ??
          Center(
            child: Text(
              'لا توجد عناصر',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
                fontSize: 16,
              ),
            ),
          );
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: true,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      scrollController: controller,
      itemCount: items.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          key: ValueKey(index),
          padding:
              EdgeInsets.only(bottom: index < items.length - 1 ? spacing : 0),
          child: itemBuilder(context, item, index),
        );
      },
    );
  }
}

/// قائمة عناصر قابلة للتمرير أفقياً محسنة
class _EnhancedHorizontalList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? emptyWidget;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final double? itemWidth;
  final double itemHeight;

  const _EnhancedHorizontalList({
    required this.items,
    required this.itemBuilder,
    this.emptyWidget,
    required this.isLoading,
    required this.padding,
    required this.spacing,
    this.physics,
    this.controller,
    this.itemWidth,
    required this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: itemHeight,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (items.isEmpty) {
      return SizedBox(
        height: itemHeight,
        child: emptyWidget ??
            Center(
              child: Text(
                'لا توجد عناصر',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),
      );
    }

    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        controller: controller,
        padding: padding,
        physics: physics,
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final item = items[index];
          if (itemWidth != null) {
            return SizedBox(
              width: itemWidth,
              child: itemBuilder(context, item, index),
            );
          }
          return itemBuilder(context, item, index);
        },
      ),
    );
  }
}
