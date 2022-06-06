// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'extensions/color_extension.dart';

/// Common picking methods are defined in [pickMethods].
/// 常见的选择器调用方式定义在 [pickMethods]。
import 'models/picker_method.dart';

import 'pages/splash_page.dart';

const Color themeColor = Color(0xff00bc56);

String? packageVersion;

void main() {
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeChat Camera Picker Demo',
      theme: ThemeData(
        brightness: MediaQueryData.fromWindow(ui.window).platformBrightness,
        primarySwatch: themeColor.swatch,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: themeColor,
        ),
      ),
      home: const SplashPage(),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en'), // English
        Locale('zh'), // Chinese
      ],
      locale: const Locale('en'),
    );
  }
}
