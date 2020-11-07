import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TextDivider extends StatelessWidget {
  final String text;
  final double leftPadding, padding;
  final List<Widget> actions;

  const TextDivider({
    Key key,
    @required this.text,
    this.padding = 5,
    this.leftPadding = 15,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: leftPadding, top: padding, bottom: padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey))),
          ...actions,
        ],
      ),
    );
  }
}

Widget oldBookAvatar({
  String text = '旧\n藏\n书',
  width = double.infinity,
  height = double.infinity,
}) {
  return Container(
    width: width,
    height: height,
    alignment: Alignment.center,
    color: Colors.greenAccent,
    child: Text(text),
  );
}
