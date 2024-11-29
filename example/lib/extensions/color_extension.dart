// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart'
    show Color, Colors, HSLColor, MaterialColor;

extension ColorExtension on Color {
  MaterialColor get swatch {
    return Colors.primaries.firstWhere(
      (Color c) => c.value == value,
      orElse: () => MaterialColor(value, getMaterialColorValues),
    );
  }

  Color _swatchShade(int swatchValue) {
    return HSLColor.fromColor(this)
        .withLightness(1 - (swatchValue / 1000))
        .toColor();
  }

  Map<int, Color> get getMaterialColorValues {
    return <int, Color>{
      50: _swatchShade(50),
      100: _swatchShade(100),
      200: _swatchShade(200),
      300: _swatchShade(300),
      400: _swatchShade(400),
      500: _swatchShade(500),
      600: _swatchShade(600),
      700: _swatchShade(700),
      800: _swatchShade(800),
      900: _swatchShade(900),
    };
  }
}
