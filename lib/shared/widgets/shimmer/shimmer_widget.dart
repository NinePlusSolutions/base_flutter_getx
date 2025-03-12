import 'dart:math';

import 'package:flutter/material.dart';

class _ImageShimmer extends StatelessWidget {
  _ImageShimmer({
    super.key,
    this.width,
    this.height,
    this.shape,
  });
  final double? width;
  final double? height;
  final BoxShape? shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: shape != null ? null : BorderRadius.circular(8.0),
        color: Colors.white,
        shape: shape ?? BoxShape.rectangle,
      ),
    );
  }
}

class ShimmerBaseWidget {
  static Widget image({double? width, double? height}) {
    return _ImageShimmer(width: width, height: height);
  }

  static Widget atv({double? size}) {
    return _ImageShimmer(
      width: size,
      height: size,
      shape: BoxShape.circle,
    );
  }

  static Widget title(
      {double width = double.infinity, int lines = 1, double? height}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
          lines,
          (index) => Container(
                width: width * (index == 0 ? 1 : Random().nextDouble()),
                height: height ?? 8.0,
                margin: const EdgeInsets.only(bottom: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.white,
                ),
              )),
    );
  }
}
