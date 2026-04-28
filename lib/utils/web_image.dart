/// Web-specific image widget that uses an HTML <img> element
/// to bypass CORS restrictions inherent in XHR-based image loading
/// (CanvasKit / Skwasm renderers).
library;

import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
import 'package:flutter/widgets.dart';

/// A counter to generate unique view-type IDs for each image instance.
int _nextId = 0;

/// Displays an image using a native HTML <img> element via [HtmlElementView].
///
/// This avoids CORS issues because the browser's native <img> tag does not
/// enforce the same-origin policy for *displaying* images (only for reading
/// pixel data, which we don't need).
class WebImage extends StatefulWidget {
  const WebImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final BoxFit fit;

  @override
  State<WebImage> createState() => _WebImageState();
}

class _WebImageState extends State<WebImage> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = '_webImg_${_nextId++}';
    _register();
  }

  void _register() {
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId, {Object? params}) {
        final img = web.document.createElement('img') as web.HTMLImageElement;
        img.src = widget.imageUrl;
        img.style.width = '100%';
        img.style.height = '100%';
        img.style.objectFit = _cssFit(widget.fit);
        img.style.display = 'block';
        return img;
      },
    );
  }

  static String _cssFit(BoxFit fit) {
    switch (fit) {
      case BoxFit.cover:
        return 'cover';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
      case BoxFit.fitWidth:
        return 'cover';
      case BoxFit.fitHeight:
        return 'cover';
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
