import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Image;

class ActivityTest extends StatefulWidget {
  @override
  _ActivityTest createState() => _ActivityTest();
}

class _ActivityTest extends State<ActivityTest> {
  final String url =
      'https://cdn-msp.msp-comic1.xyz/media/photos/221039/00001.jpg?v=1603879594';
  ui.Image image;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    Response<List<int>> res = await Dio().get<List<int>>(
      url,
      options: Options(
          responseType: ResponseType.bytes), // // set responseType to `bytes`
    );
    var codec = await ui.instantiateImageCodec(res.data);
    var frame = await codec.getNextFrame();
    this.image = frame.image;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('测试'),
      ),
      body: image == null
          ? Center(child: Text('读取中'))
          : CustomPaint(painter: ImagePainter(image)),
    );
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  Paint mainPaint;

  ImagePainter(this.image) {
    mainPaint = Paint()..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(
        this.image, //报错
        Offset(0, 0),
        mainPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
