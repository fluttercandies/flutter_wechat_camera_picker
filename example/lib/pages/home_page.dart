// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../extensions/l10n_extensions.dart';
import '../main.dart';
import '../models/picker_method.dart';
import '../widgets/method_list_view.dart';
import '../widgets/selected_assets_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final ValueNotifier<bool> isDisplayingDetail = ValueNotifier<bool>(true);
  final ValueNotifier<AssetEntity?> selectedAsset =
      ValueNotifier<AssetEntity?>(null);

  Future<void> selectAssets(PickMethod model) async {
    final AssetEntity? result = await model.method(context);
    if (result != null) {
      selectedAsset.value = result;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget header(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(top: 30),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: Hero(
              tag: 'LOGO',
              child: Image.asset('assets/flutter_candies_logo.png'),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                sortKey: const OrdinalSortKey(0),
                child: Text(
                  context.l10n.appTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Semantics(
                sortKey: const OrdinalSortKey(0.1),
                child: Text(
                  context.l10n.appVersion(
                    packageVersion ?? context.l10n.appVersionUnknown,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              header(context),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  context.l10n.pickMethodNotice(
                    'lib/models/picker_method.dart',
                  ),
                ),
              ),
              Expanded(
                child: MethodListView(
                  pickMethods: pickMethods(context),
                  onSelectMethod: selectAssets,
                ),
              ),
              ValueListenableBuilder<AssetEntity?>(
                valueListenable: selectedAsset,
                builder: (_, AssetEntity? asset, __) {
                  if (asset == null) {
                    return const SizedBox.shrink();
                  }
                  return SelectedAssetView(
                    asset: asset,
                    isDisplayingDetail: isDisplayingDetail,
                    onRemoveAsset: () => selectedAsset.value = null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
