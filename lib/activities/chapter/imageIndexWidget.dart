import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ImageIndexWidget extends StatefulWidget {
  const ImageIndexWidget({key}) : super(key: key);

  @override
  ImageIndexWidgetState createState() => ImageIndexWidgetState();
}

class ImageIndexWidgetState extends State<ImageIndexWidget> {
  int _current = 1;
  int total;

  void set(value, total) {
    _current = value;
    this.total = total;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    String text;
    if (total == null) {
      text = '读取中';
    } else {
      text = '当前图片：$_current / $total';
    }
    return Text(text);
  }
}
