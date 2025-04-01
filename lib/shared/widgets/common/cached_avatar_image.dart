import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/constants/assets_path.dart';
import 'package:flutter_svg/svg.dart';

class CachedAvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CachedAvatarImage({
    super.key,
    this.imageUrl,
    this.size = 50,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildDefaultAvatar();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(50)),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: fit,
        placeholder: (context, url) => _buildDefaultAvatar(),
        errorWidget: (context, url, error) => _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return ClipRRect(
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(50)),
      child: SvgPicture.asset(
        AssetPath.iconAvatarDefault,
        width: size,
        height: size,
        fit: fit,
      ),
    );
  }
}
