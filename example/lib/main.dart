import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

void main() {
  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AssetEntity? entity;
  Uint8List? data;

  Future<void> pick(BuildContext context) async {
    final Size size = MediaQuery.of(context).size;
    final double scale = MediaQuery.of(context).devicePixelRatio;
    final AssetEntity? _entity = await CameraPicker.pickFromCamera(
      context,
      enableRecording: true,
    );
    if (_entity != null && entity != _entity) {
      entity = _entity;
      if (mounted) {
        setState(() {});
      }
      data = await _entity.thumbDataWithSize(
        (size.width * scale).toInt(),
        (size.height * scale).toInt(),
      );
      if (mounted) {
        setState(() {});
      }
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
