import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weiman/db/group.dart';
import 'package:weiman/provider/favoriteData.dart';

Future showDeleteGroupDialog(BuildContext context, Group group) {
  return showDialog(
    context: context,
    builder: (_) => DeleteGroupWidget(group: group),
  );
}

class DeleteGroupWidget extends StatefulWidget {
  final Group group;

  const DeleteGroupWidget({Key key, this.group}) : super(key: key);

  @override
  _DeleteGroupWidget createState() => _DeleteGroupWidget();
}

class _DeleteGroupWidget extends State<DeleteGroupWidget> {
  bool deleteBooks = false;

  @override
  Widget build(BuildContext context) {
    final length = widget.group.books.length;
    return AlertDialog(
      title: Text('删除分组 ${widget.group.name}'),
      scrollable: true,
      content: Column(
        children: ListTile.divideTiles(context: context, tiles: [
          if (length > 0)
            ListTile(
              title: Text('删除藏书'),
              subtitle: Text('有 $length 本藏书'),
              trailing: Checkbox(
                value: deleteBooks,
                onChanged: (v) => setState(() => deleteBooks = v),
              ),
            )
        ]).toList(),
      ),
      actions: [
        FlatButton(
          child: Text('确认'),
          onPressed: () async {
            await Provider.of<FavoriteData>(context, listen: false)
                .deleteGroup(widget.group, deleteBooks);
            Navigator.pop(context);
          },
        ),
        RaisedButton(
            child: Text('取消'), onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
