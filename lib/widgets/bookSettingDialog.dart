import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weiman/db/book.dart';
import 'package:weiman/db/group.dart';
import 'package:weiman/provider/favoriteData.dart';
import 'package:weiman/widgets/groupFormDialog.dart';

Future showBookSettingDialog(BuildContext context, Book book) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('藏书《${book.name}》的设置'),
      scrollable: true,
      content: WidgetSetting(book: book),
    ),
  );
}

class WidgetSetting extends StatefulWidget {
  final Book book;

  const WidgetSetting({Key key, this.book}) : super(key: key);

  @override
  _WidgetSetting createState() => _WidgetSetting();
}

class _WidgetSetting extends State<WidgetSetting> {
  static final updateMenus = {true: '自动', false: '不检查'};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ListTile.divideTiles(context: context, tiles: [
        ListTile(
          title: Text('检查更新'),
          trailing: DropdownButton<bool>(
            value: widget.book.needUpdate,
            items: updateMenus.keys
                .map((key) =>
                    DropdownMenuItem(value: key, child: Text(updateMenus[key])))
                .toList(),
            onChanged: changeUpdate,
          ),
        ),
        ListTile(
          title: Text('分组'),
          trailing: DropdownButton<Group>(
            hint: Text('没有分组'),
            value: widget.book.group,
            items: [
              DropdownMenuItem(
                child: Text('新建'),
                value: null,
              ),
              ...Group.groupBox.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
            ],
            onChanged: changeGroup,
          ),
        ),
      ]).toList(),
    );
  }

  changeUpdate(bool needUpdate) async {
    widget.book.needUpdate = needUpdate;
    await widget.book.save();
    setState(() {});
  }

  changeGroup(Group group) async {
    if (group == null) {
      group = await showGroupFormDialog(context);
    }
    widget.book.groupId = group == null ? widget.book.groupId : group.key;
    await widget.book.save();
    setState(() {});
  }

  changeFavorite() async {
    await widget.book.setFavorite(!widget.book.favorite);
    setState(() {});
  }

  removeHistory() async {
    if (widget.book.history != null) await widget.book.setHistory(null);
    setState(() {});
  }

  @override
  void setState(fn) {
    final fav = Provider.of<FavoriteData>(context, listen: false);
    fav.loadBooksList(true);
    super.setState(fn);
  }
}
