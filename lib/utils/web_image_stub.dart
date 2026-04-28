/// Stub for non-web platforms so that the conditional import compiles.
///
/// This file is never actually used at runtime on web; it only exists so
/// that `dart:io` platforms can compile without pulling in `dart:ui_web`.
library;

import 'package:flutter/widgets.dart';

class WebImage extends StatelessWidget {
  const WebImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    // Should never be reached on non-web platforms.
    return const SizedBox.shrink();
  }
}
