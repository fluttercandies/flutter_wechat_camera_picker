// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../extensions/l10n_extensions.dart';
import 'asset_widget_builder.dart';
import 'preview_asset_widget.dart';

class SelectedAssetView extends StatelessWidget {
  const SelectedAssetView({
    super.key,
    required this.asset,
    required this.isDisplayingDetail,
    required this.onRemoveAsset,
  });

  final AssetEntity asset;
  final ValueNotifier<bool> isDisplayingDetail;
  final VoidCallback onRemoveAsset;

  Widget _selectedAssetWidget(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDisplayingDetail,
      builder: (_, bool value, __) => GestureDetector(
        onTap: () async {
          if (value) {
            showDialog(
              context: context,
              builder: (BuildContext context) => GestureDetector(
                onTap: Navigator.of(context).pop,
                child: Center(child: PreviewAssetWidget(asset)),
              ),
            );
          }
        },
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AssetWidgetBuilder(entity: asset, isDisplayingDetail: value),
          ),
        ),
      ),
    );
  }

  Widget _selectedAssetDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: onRemoveAsset,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(context).canvasColor.withOpacity(0.5),
        ),
        child: const Icon(Icons.close, size: 18),
      ),
    );
  }

  Widget _selectedAssetView(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: _selectedAssetWidget(context)),
            ValueListenableBuilder<bool>(
              valueListenable: isDisplayingDetail,
              builder: (_, bool value, Widget? child) => AnimatedPositioned(
                duration: kThemeAnimationDuration,
                top: value ? 6 : -30,
                right: value ? 6 : -30,
                child: child!,
              ),
              child: _selectedAssetDeleteButton(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDisplayingDetail,
      builder: (_, bool value, Widget? child) => AnimatedContainer(
        duration: kThemeChangeDuration,
        curve: Curves.easeInOut,
        height: value ? 120 : 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 20,
              child: GestureDetector(
                onTap: () =>
                    isDisplayingDetail.value = !isDisplayingDetail.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(context.l10n.selectedAssetsText),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 10),
                      child: Icon(
                        value ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: child!),
          ],
        ),
      ),
      child: _selectedAssetView(context),
    );
  }
}
