part of '../main.dart';

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
