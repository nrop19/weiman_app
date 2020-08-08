import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class SliverExpandableBuilder {
  final int count;
  final WidgetBuilder builder;

  const SliverExpandableBuilder(this.count, this.builder);
}

class SliverExpandableGroup extends StatefulWidget {
  final Widget title;
  final bool expanded;
  final List<Widget> actions;
  final Color divideColor;
  final double height;
  final int count;
  final IndexedWidgetBuilder builder;

  const SliverExpandableGroup({
    Key key,
    @required this.title,
    @required this.count,
    @required this.builder,
    this.expanded = false,
    this.actions = const [],
    this.divideColor = Colors.grey,
    this.height = kToolbarHeight,
  })  : assert(title != null),
        assert(builder != null),
        super(key: key);

  @override
  _SliverExpandableGroup createState() => _SliverExpandableGroup();
}

class _SliverExpandableGroup extends State<SliverExpandableGroup> {
  bool _expanded;

  @override
  initState() {
    super.initState();
    _expanded = widget.expanded;
  }

  @override
  Widget build(BuildContext context) {
    Decoration _decoration = BoxDecoration(
      border: Border(
        bottom: Divider.createBorderSide(context, color: widget.divideColor),
      ),
    );
    return SliverStickyHeader(
      header: InkWell(
        child: Container(
          height: widget.height,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
          ),
          child: Row(children: [
            Transform.rotate(
              angle: _expanded ? 0 : math.pi,
              child: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey,
              ),
            ),
            Expanded(child: widget.title),
            ...widget.actions,
          ]),
        ),
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
        },
      ),
      sliver: _expanded
          ? SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
              if (i < widget.count - 1) {
                return DecoratedBox(
                  decoration: _decoration,
                  child: widget.builder(context, i),
                );
              }
              return widget.builder(context, i);
            }, childCount: widget.count))
          : null,
    );
  }
}
