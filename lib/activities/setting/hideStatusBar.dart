import 'package:flutter/material.dart';
import 'package:weiman/db/setting.dart';

class HideStatusBar extends StatelessWidget {
  final options = {
    '自动': HideOption.auto,
    '全程隐藏': HideOption.always,
    '不隐藏': HideOption.none,
  };
  final Function(HideOption option) onChanged;
  final HideOption option;

  HideStatusBar({Key key, @required this.onChanged, @required this.option})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('看漫画时隐藏状态栏'),
      subtitle: Text('自动：随着图片列表的上下滚动而自动显示或隐藏状态栏\n'
          '全程隐藏：进入看图界面就隐藏状态栏，退出就显示状态栏\n'
          '不隐藏：就是不隐藏状态栏咯'),
      trailing: DropdownButton<HideOption>(
        value: option,
        items: options.keys
            .map((key) => DropdownMenuItem(
                  child: Text(key),
                  value: options[key],
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
