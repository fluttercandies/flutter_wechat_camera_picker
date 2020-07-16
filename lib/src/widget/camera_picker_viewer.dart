///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/16 22:02
///
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wechat_camera_picker/src/constants/constants.dart';

import 'camera_picker.dart';

/// Two types for the viewer: image and video.
/// 两种预览类型：图片和视频
enum CameraPickerViewType { image, video }

class CameraPickerViewer extends StatefulWidget {
  const CameraPickerViewer({
    Key key,
    @required this.pickerState,
    @required this.previewFile,
    @required this.previewFilePath,
    @required this.theme,
  })  : assert(
          theme != null && previewFile != null && pickerState != null,
        ),
        super(key: key);

  final CameraPickerState pickerState;

  final File previewFile;

  final String previewFilePath;

  final ThemeData theme;

  @override
  _CameraPickerViewerState createState() => _CameraPickerViewerState();
}

class _CameraPickerViewerState extends State<CameraPickerViewer> {
  CameraPickerState get pickerState => widget.pickerState;

  File get previewFile => widget.previewFile;

  String get previewFilePath => widget.previewFilePath;

  ThemeData get theme => widget.theme;

  /// When users confirm to use the taken file, create the [AssetEntity] using
  /// [Editor.saveImage] (PhotoManager.editor.saveImage), then delete the file
  /// if not [shouldKeptInLocal]. While the entity might returned null, there's
  /// no side effects if popping `null` because the parent picker will ignore it.
  Future<void> createAssetEntityAndPop() async {
    try {
      final File file = previewFile;
      final Uint8List data = await file.readAsBytes();
      final AssetEntity entity = await PhotoManager.editor.saveImage(
        data,
        title: previewFilePath,
      );
      if (!pickerState.shouldKeptInLocal) {
        file.delete();
      }
      Navigator.of(context).pop(entity);
    } catch (e) {
      realDebugPrint('Error when creating entity: $e');
    }
  }

  /// The back button for the preview section.
  /// 预览区的返回按钮
  Widget get previewBackButton {
    return InkWell(
      borderRadius: maxBorderRadius,
      onTap: () {
        previewFile.delete();
        widget.pickerState.setState(() {
          widget.pickerState.takenPictureFilePath = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(10.0),
        width: Screens.width / 15,
        height: Screens.width / 15,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.close,
            color: Colors.black,
            size: 18.0,
          ),
        ),
      ),
    );
  }

  /// The confirm button for the preview section.
  /// 预览区的确认按钮
  Widget get previewConfirmButton {
    return MaterialButton(
      minWidth: 20.0,
      height: 32.0,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      color: theme.colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Text(
        '完成',
        style: TextStyle(
          color: theme.textTheme.bodyText1.color,
          fontSize: 17.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      onPressed: createAssetEntityAndPop,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: Image.file(previewFile)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      previewBackButton,
                      const Spacer(),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Spacer(),
                      previewConfirmButton,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
