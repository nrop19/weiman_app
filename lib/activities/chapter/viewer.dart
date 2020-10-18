import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:weiman/classes/networkImageSSL.dart';
import 'package:weiman/crawler/http18Comic.dart';

class ActivityImageViewer extends StatefulWidget {
  final String url;
  final String heroTag;

  const ActivityImageViewer({
    Key key,
    this.url,
    this.heroTag,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<ActivityImageViewer> {
  double currentScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return ExtendedImageSlidePage(
      slideAxis: SlideAxis.both,
      slideType: SlideType.onlyImage,
      child: Material(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: ExtendedImage(
                image: NetworkImageSSL(Http18Comic.instance, widget.url),
                enableSlideOutPage: true,
                mode: ExtendedImageMode.gesture,
                onDoubleTap: (status) {
                  currentScale = currentScale == 1 ? 3 : 1;
                  status.handleDoubleTap(scale: currentScale);
                },
                heroBuilderForSlidingPage: (child) {
                  return Hero(
                    child: child,
                    tag: widget.heroTag,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
