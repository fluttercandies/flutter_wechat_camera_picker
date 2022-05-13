// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

void main() {
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
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
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AssetEntity? entity;
  Uint8List? data;

  Future<void> pick(BuildContext context) async {
    final Size size = MediaQuery.of(context).size;
    final double scale = MediaQuery.of(context).devicePixelRatio;
    try {
      final AssetEntity? result = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(enableRecording: true),
      );
      if (result != null && result != entity) {
        entity = result;
        if (mounted) {
          setState(() {});
        }
        data = await result.thumbnailDataWithSize(
          ThumbnailSize(
            (size.width * scale).toInt(),
            (size.height * scale).toInt(),
          ),
        );
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WeChat Camera Picker Demo')),
      body: Stack(
        children: <Widget>[
          if (entity != null && data != null)
            Positioned.fill(child: Image.memory(data!, fit: BoxFit.contain))
          else if (entity != null && data == null)
            const Center(child: CircularProgressIndicator())
          else
            const Center(child: Text('Click the button to start picking.')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => pick(context),
        tooltip: 'Increment',
        child: const Icon(Icons.camera_enhance),
      ),
    );
  }
}
