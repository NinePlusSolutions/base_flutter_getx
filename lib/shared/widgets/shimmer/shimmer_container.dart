import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/widgets/shimmer/page_loading.dart';
import 'package:shimmer/shimmer.dart';

enum LoadingType { page, list, grip, custom }

class ShimmerLoadingContainer extends StatelessWidget {
  const ShimmerLoadingContainer({
    super.key,
    required this.type,
    required this.child,
    required this.isLoading,
    this.loadingView,
  });

  final LoadingType type;
  final Widget child;
  final bool isLoading;
  final Widget? loadingView;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      duration: const Duration(milliseconds: 300),
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (!isLoading) return child;
    return Shimmer.fromColors(
      key: ValueKey("shimmer: $key}"),
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: _getLoadingView(),
    );
  }

  Widget _getLoadingView() {
    if (loadingView != null) return loadingView!;
    switch (type) {
      case LoadingType.list:
        return const ListViewShimmerLoading();
      case LoadingType.grip:
        return const GripShimmerLoading();
      default:
        return const ShimmerPageLoading();
    }
  }
}
