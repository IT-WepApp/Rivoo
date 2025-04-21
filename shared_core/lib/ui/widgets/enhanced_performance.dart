import 'package:flutter/material.dart';

/// مكونات تحسين الأداء للتطبيق
/// توفر مكونات لتحسين أداء التطبيق وتجربة المستخدم
class EnhancedPerformance {
  /// قائمة بتحميل جزئي
  /// توفر قائمة تقوم بتحميل العناصر بشكل جزئي عند الحاجة
  static Widget paginatedList<T>({
    required Future<List<T>> Function(int page, int pageSize) fetchItems,
    required Widget Function(BuildContext, T) itemBuilder,
    required int pageSize,
    Widget? loadingWidget,
    Widget? errorWidget,
    Widget? emptyWidget,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    double spacing = 8.0,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    ScrollController? controller,
  }) {
    return _EnhancedPaginatedList<T>(
      fetchItems: fetchItems,
      itemBuilder: itemBuilder,
      pageSize: pageSize,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      emptyWidget: emptyWidget,
      padding: padding,
      spacing: spacing,
      physics: physics,
      shrinkWrap: shrinkWrap,
      controller: controller,
    );
  }

  /// صورة محسنة مع تحميل تدريجي
  /// توفر صورة تظهر بشكل تدريجي مع تأثير تلاشي
  static Widget optimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    Duration fadeInDuration = const Duration(milliseconds: 300),
    BorderRadius? borderRadius,
    bool enableMemoryCache = true,
    bool enableDiskCache = true,
  }) {
    return _EnhancedOptimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      fadeInDuration: fadeInDuration,
      borderRadius: borderRadius,
      enableMemoryCache: enableMemoryCache,
      enableDiskCache: enableDiskCache,
    );
  }

  /// قائمة شبكية محسنة
  /// توفر قائمة شبكية مع تحميل جزئي للعناصر
  static Widget paginatedGrid<T>({
    required Future<List<T>> Function(int page, int pageSize) fetchItems,
    required Widget Function(BuildContext, T) itemBuilder,
    required int pageSize,
    required int crossAxisCount,
    double mainAxisSpacing = 8.0,
    double crossAxisSpacing = 8.0,
    double childAspectRatio = 1.0,
    Widget? loadingWidget,
    Widget? errorWidget,
    Widget? emptyWidget,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    ScrollController? controller,
  }) {
    return _EnhancedPaginatedGrid<T>(
      fetchItems: fetchItems,
      itemBuilder: itemBuilder,
      pageSize: pageSize,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      emptyWidget: emptyWidget,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      controller: controller,
    );
  }
}

/// قائمة بتحميل جزئي
class _EnhancedPaginatedList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) fetchItems;
  final Widget Function(BuildContext, T) itemBuilder;
  final int pageSize;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const _EnhancedPaginatedList({
    required this.fetchItems,
    required this.itemBuilder,
    required this.pageSize,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    required this.padding,
    required this.spacing,
    this.physics,
    required this.shrinkWrap,
    this.controller,
  });

  @override
  _EnhancedPaginatedListState<T> createState() => _EnhancedPaginatedListState<T>();
}

class _EnhancedPaginatedListState<T> extends State<_EnhancedPaginatedList<T>> {
  final List<T> _items = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _hasMoreItems = true;
  int _currentPage = 1;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadItems();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreItems) {
      _loadMoreItems();
    }
  }

  Future<void> _loadItems() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final newItems = await widget.fetchItems(1, widget.pageSize);
      
      setState(() {
        _items.clear();
        _items.addAll(newItems);
        _isLoading = false;
        _currentPage = 1;
        _hasMoreItems = newItems.length >= widget.pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoading || !_hasMoreItems) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await widget.fetchItems(_currentPage + 1, widget.pageSize);
      
      setState(() {
        _items.addAll(newItems);
        _isLoading = false;
        _currentPage++;
        _hasMoreItems = newItems.length >= widget.pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _items.isEmpty) {
      return widget.errorWidget ??
          Center(
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
                  'حدث خطأ أثناء تحميل البيانات',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadItems,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
    }

    if (_items.isEmpty) {
      if (_isLoading) {
        return widget.loadingWidget ??
            const Center(
              child: CircularProgressIndicator(),
            );
      }

      return widget.emptyWidget ??
          Center(
            child: Text(
              'لا توجد عناصر',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
          );
    }

    return RefreshIndicator(
      onRefresh: _loadItems,
      child: ListView.separated(
        controller: _scrollController,
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemCount: _items.length + (_hasMoreItems ? 1 : 0),
        separatorBuilder: (context, index) => SizedBox(height: widget.spacing),
        itemBuilder: (context, index) {
          if (index < _items.length) {
            return widget.itemBuilder(context, _items[index]);
          } else {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

/// صورة محسنة مع تحميل تدريجي
class _EnhancedOptimizedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final BorderRadius? borderRadius;
  final bool enableMemoryCache;
  final bool enableDiskCache;

  const _EnhancedOptimizedImage({
    required this.imageUrl,
    this.width,
    this.height,
    required this.fit,
    this.placeholder,
    this.errorWidget,
    required this.fadeInDuration,
    this.borderRadius,
    required this.enableMemoryCache,
    required this.enableDiskCache,
  });

  @override
  _EnhancedOptimizedImageState createState() => _EnhancedOptimizedImageState();
}

class _EnhancedOptimizedImageState extends State<_EnhancedOptimizedImage> with SingleTickerProviderStateMixin {
  late ImageProvider _imageProvider;
  bool _isLoading = true;
  bool _hasError = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _loadImage();
  }

  @override
  void didUpdateWidget(_EnhancedOptimizedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      _loadImage();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadImage() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    _imageProvider = NetworkImage(widget.imageUrl);
    final image = Image(image: _imageProvider);
    
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (info, synchronousCall) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _controller.forward(from: 0.0);
          }
        },
        onError: (exception, stackTrace) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
    } else if (_hasError) {
      content = widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
            ),
          );
    } else {
      content = FadeTransition(
        opacity: _animation,
        child: Image(
          image: _imageProvider,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        ),
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return content;
  }
}

/// قائمة شبكية محسنة
class _EnhancedPaginatedGrid<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) fetchItems;
  final Widget Function(BuildContext, T) itemBuilder;
  final int pageSize;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const _EnhancedPaginatedGrid({
    required this.fetchItems,
    required this.itemBuilder,
    required this.pageSize,
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.childAspectRatio,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    required this.padding,
    this.physics,
    required this.shrinkWrap,
    this.controller,
  });

  @override
  _EnhancedPaginatedGridState<T> createState() => _EnhancedPaginatedGridState<T>();
}

class _EnhancedPaginatedGridState<T> extends State<_EnhancedPaginatedGrid<T>> {
  final List<T> _items = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _hasMoreItems = true;
  int _currentPage = 1;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadItems();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreItems) {
      _loadMoreItems();
    }
  }

  Future<void> _loadItems() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final newItems = await widget.fetchItems(1, widget.pageSize);
      
      setState(() {
        _items.clear();
        _items.addAll(newItems);
        _isLoading = false;
        _currentPage = 1;
        _hasMoreItems = newItems.length >= widget.pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoading || !_hasMoreItems) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await widget.fetchItems(_currentPage + 1, widget.pageSize);
      
      setState(() {
        _items.addAll(newItems);
        _isLoading = false;
        _currentPage++;
        _hasMoreItems = newItems.length >= widget.pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _items.isEmpty) {
      return widget.errorWidget ??
          Center(
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
                  'حدث خطأ أثناء تحميل البيانات',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadItems,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
    }

    if (_items.isEmpty) {
      if (_isLoading) {
        return widget.loadingWidget ??
            const Center(
              child: CircularProgressIndicator(),
            );
      }

      return widget.emptyWidget ??
          Center(
            child: Text(
              'لا توجد عناصر',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
          );
    }

    return RefreshIndicator(
      onRefresh: _loadItems,
      child: CustomScrollView(
        controller: _scrollController,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        slivers: [
          SliverPadding(
            padding: widget.padding,
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
                mainAxisSpacing: widget.mainAxisSpacing,
                crossAxisSpacing: widget.crossAxisSpacing,
                childAspectRatio: widget.childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return widget.itemBuilder(context, _items[index]);
                },
                childCount: _items.length,
              ),
            ),
          ),
          if (_hasMoreItems)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
