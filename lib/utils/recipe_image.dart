/// Platform-aware image widget.
///
/// On **web** → uses a native HTML <img> tag (no CORS issues).
/// On **mobile / desktop** → uses [CachedNetworkImage] for caching.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'web_image.dart' if (dart.library.io) 'web_image_stub.dart';

/// A cross-platform network image widget that handles CORS on web.
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.black),
      );
    }

    if (kIsWeb) {
      return WebImage(imageUrl: imageUrl, fit: fit);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (context, url) {
        return const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.black),
        );
      },
    );
  }
}
