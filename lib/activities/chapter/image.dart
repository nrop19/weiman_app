import 'dart:ui' as ui;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:weiman/activities/chapter/viewer.dart';
import 'package:weiman/classes/networkImageSSL.dart';
import 'package:weiman/crawler/http18Comic.dart';
import 'package:weiman/db/setting.dart';

class ImageWidget extends StatefulWidget {
  final int index;
  final int total;
  final String image;
  final bool reSort;

  const ImageWidget({
    Key key,
    this.image,
    this.index,
    this.total,
    this.reSort = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ImageWidget> {
  static TextStyle _style = TextStyle(color: Colors.white);
  static BoxDecoration _decoration =
      BoxDecoration(color: Colors.black.withOpacity(0.4));

  String get tag {
    return 'image_viewer_${widget.index}';
  }

  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      overlapHeaders: true,
      header: SafeArea(
        top: true,
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: _decoration,
              child: Text(
                '${widget.index} / ${widget.total}',
                style: _style,
              ),
            ),
          ],
        ),
      ),
      content: ExtendedImage(
        image: NetworkImageSSL(
          Http18Comic.instance,
          widget.image,
          reSort: widget.reSort,
        ),
        loadStateChanged: (ExtendedImageState state) {
          Widget widget;
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              widget = SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
              break;
            case LoadState.completed:
              widget = GestureDetector(
                child: Hero(
                  child:
                      ExtendedRawImage(image: state.extendedImageInfo?.image),
                  tag: tag,
                ),
                onTap: () => onTap(context),
              );
              break;
            default:
          }
          return widget;
        },
      ),
    );
  }

  onTap(BuildContext context) {
    final viewerSwitch =
        Provider.of<Setting>(context, listen: false).getViewerSwitch();
    // print('viewer $viewerSwitch');
    if (!viewerSwitch) return;
    Navigator.push(
      context,
      TransparentMaterialPageRoute(
        builder: (_) => ActivityImageViewer(
          url: this.widget.image,
          heroTag: tag,
          reSort: widget.reSort,
        ),
      ),
    );
  }
}