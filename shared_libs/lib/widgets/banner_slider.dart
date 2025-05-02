import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// واجهة لعرض شرائح البانر
class BannerSlider extends StatefulWidget {
  final List<String> bannerImages;
  final double height;
  final double borderRadius;
  final Function(int)? onBannerTap;

  const BannerSlider({
    Key? key,
    required this.bannerImages,
    this.height = 180,
    this.borderRadius = 12,
    this.onBannerTap,
  }) : super(key: key);

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // تغيير الشريحة تلقائيًا كل 5 ثوانٍ
    if (widget.bannerImages.length > 1) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _autoScroll();
        }
      });
    }
  }

  void _autoScroll() {
    if (!mounted) return;
    
    final nextPage = (_currentPage + 1) % widget.bannerImages.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _autoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.bannerImages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (widget.onBannerTap != null) {
                      widget.onBannerTap!(index);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 13), // 0.05 * 255 = 13
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      widget.bannerImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.bannerImages.length > 1)
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.bannerImages.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
