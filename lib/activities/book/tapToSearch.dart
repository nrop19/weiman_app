import 'package:flutter/material.dart';
import 'package:weiman/activities/search/search.dart';

class TapToSearchWidget extends StatelessWidget {
  final String leading;
  final List<String> items;

  const TapToSearchWidget({
    Key key,
    this.leading,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          child: Text('$leading：'),
          onPressed: null,
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            overlayColor:
                MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.3)),
            visualDensity: VisualDensity.comfortable,
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: items.map((e) => _Item(string: e)).toList(),
          ),
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final String string;

  const _Item({Key key, @required this.string})
      : assert(string != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ActivitySearch(
                      search: string,
                    )));
      },
      icon: Icon(Icons.search, size: 14),
      label: Text(string),
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        overlayColor:
            MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.3)),
        visualDensity: VisualDensity.comfortable,
      ),
    );
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ActivitySearch(
                      search: string,
                    )));
      },
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text: string,
                style: TextStyle(decoration: TextDecoration.underline)),
            WidgetSpan(
                child: Icon(
              Icons.search,
              color: Colors.white,
              size: 14,
            )),
          ],
        ),
        style: TextStyle(
          color: Colors.white,
          textBaseline: TextBaseline.ideographic,
        ),
      ),
    );
  }
}
