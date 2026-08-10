import 'package:flutter/material.dart';

class ColorUtils {
  ColorUtils._();

  static Color fromArgbInt(int argb) {
    if (argb == 0) return const Color(0xFF5B6AF0);
    return Color(argb).withValues(alpha: 1.0);
  }

  static int toArgbInt(Color color) {
    return (color.a * 255).toInt() << 24 |
        (color.r * 255).toInt() << 16 |
        (color.g * 255).toInt() << 8 |
        (color.b * 255).toInt();
  }
}
