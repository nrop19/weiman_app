import 'package:flutter/material.dart';

import 'package:weiman/db/group.dart';

Future<Group> showGroupFormDialog(BuildContext context, [Group group]) {
  return showDialog(
    context: context,
    builder: (_) {
      return GroupFormDialog(group: group);
    },
  );
}

class GroupFormDialog extends StatefulWidget {
  final Group group;

  const GroupFormDialog({Key key, this.group}) : super(key: key);

  @override
  _GroupFormDialog createState() => _GroupFormDialog();
}

class _GroupFormDialog extends State<GroupFormDialog> {
  final _form = GlobalKey<FormState>();
  TextEditingController _nameController;
  Group group;

  @override
  void initState() {
    group = widget.group;
    _nameController = TextEditingController(text: widget.group?.name ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.group == null ? '创建分组' : '分组重命名'),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              autofocus: true,
              controller: _nameController,
              decoration: InputDecoration.collapsed(
                hintText: group == null ? '输入分组名称' : '原名 ${group.name}',
              ),
              validator: (value) {
                value = value.trim();
                if (value.isEmpty) {
                  return '分组名称不能为空';
                }
                final sameName =
                    Group.groupBox.values.firstWhere((Group group) {
                  return group.name == value && group.key != this.group?.key;
                }, orElse: () => null);
                if (sameName != null) {
                  return '已经存在同名的分组';
                }
                return null;
              },
            )
          ],
        ),
      ),
      actions: [
        FlatButton(
          child: Text('确认'),
          onPressed: () async {
            if (group == null) {
              group = Group(_nameController.text);
            } else {
              group.name = _nameController.text;
            }
            await group.save();
            Navigator.pop(context, group);
          },
        ),
        RaisedButton(
          child: Text('取消'),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            Navigator.pop(context, group);
          },
        ),
      ],
    );
  }
}
