import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:weiman/db/group.dart';

class BookGroupHeader extends StatefulWidget {
  final Group group;
  final int count;
  final List<Widget> actions;
  final Color divideColor;
  final double height;
  final IndexedWidgetBuilder builder;
  final List<Widget> slideActions;

  const BookGroupHeader({
    Key key,
    @required this.group,
    @required this.count,
    @required this.builder,
    this.actions = const [],
    this.divideColor = Colors.grey,
    this.height = kToolbarHeight,
    this.slideActions,
  })  : assert(group != null),
        assert(builder != null),
        super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<BookGroupHeader> {
  bool expended;

  @override
  void initState() {
    expended = widget.group.expended ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Decoration _decoration = BoxDecoration(
      border: Border(
        bottom: Divider.createBorderSide(context, color: widget.divideColor),
      ),
    );
    Widget header = InkWell(
      child: Container(
        height: widget.height,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: Row(children: [
          Transform.rotate(
            angle: expended ? 0 : math.pi,
            child: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey,
            ),
          ),
          Expanded(child: Text('${widget.group.name}(${widget.count})')),
          ...widget.actions,
        ]),
      ),
      onTap: () {
        expended = !expended;
        widget.group
          ..expended = expended
          ..save();
        setState(() {});
      },
    );
    if (widget.slideActions != null && widget.slideActions.length > 0) {
      header = Slidable(
        child: header,
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: widget.slideActions,
      );
    }
    return SliverStickyHeader(
      header: header,
      sliver: expended
          ? SliverList(
              delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                if (i < widget.count - 1) {
                  return DecoratedBox(
                    decoration: _decoration,
                    child: widget.builder(context, i),
                  );
                }
                return widget.builder(context, i);
              },
              childCount: widget.count,
            ))
          : null,
    );
  }
}
