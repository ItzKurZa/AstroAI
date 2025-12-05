import 'package:flutter/material.dart';

const List<String> _blockedHosts = [
  'i.pravatar.cc',
  'storage.googleapis.com',
];

class AppSafeImage extends StatelessWidget {
  const AppSafeImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.placeholderAsset = 'assets/images/app/logo.png',
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final String placeholderAsset;

  bool get _isRemote => imageUrl.startsWith('http');

  bool get _isBlockedHost {
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) return false;
    return _blockedHosts.any((host) => uri.host.contains(host));
  }

  Widget _buildImage() {
    final canUseNetwork = _isRemote && !_isBlockedHost;
    if (canUseNetwork) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.asset(
          placeholderAsset,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }

    final assetPath =
        _isRemote ? placeholderAsset : (imageUrl.isEmpty ? placeholderAsset : imageUrl);
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    return image;
  }
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.imageUrl,
    this.size = 64,
    this.borderColor,
    this.placeholderAsset = 'assets/images/app/logo.png',
  });

  final String imageUrl;
  final double size;
  final Color? borderColor;
  final String placeholderAsset;

  bool get _isRemote => imageUrl.startsWith('http');

  bool get _isBlockedHost {
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) return false;
    return _blockedHosts.any((host) => uri.host.contains(host));
  }

  Widget _buildImage() {
    final fit = BoxFit.cover;
    final canUseNetwork = _isRemote && !_isBlockedHost;
    if (canUseNetwork) {
      return Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.asset(
          placeholderAsset,
          width: size,
          height: size,
          fit: fit,
        ),
      );
    }
    final assetPath =
        _isRemote ? placeholderAsset : (imageUrl.isEmpty ? placeholderAsset : imageUrl);
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.2)
              : null,
        ),
        child: ClipOval(
          child: _buildImage(),
        ),
      ),
    );
  }
}

