import 'dart:convert';
import 'dart:io';

import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:weiman/activities/setting/hideStatusBar.dart';

import '../../classes/data.dart';
import '../../crawler/http.dart';
import '../../main.dart';

enum AutoCheckLevel {
  none,
  onlyInWeek,
  all,
}

class SettingData extends ChangeNotifier {
  static final String key = 'setting_data';
  AutoCheckLevel _autoCheck;
  HideOption _hide;
  String _proxy;
  Directory imageCacheDir;

  SettingData() {
    final Map<String, dynamic> data =
        jsonDecode(Data.instance.getString(key) ?? '{}');
    print('SettingData $data');
    _autoCheck = data['autoCheck'] == null
        ? AutoCheckLevel.onlyInWeek
        : AutoCheckLevel.values[data['autoCheck']];
    _hide = data['hide'] == null
        ? HideOption.auto
        : HideOption.values[data['hide']];
    _proxy = data['proxy'];

    MyHttpClient.init(_proxy, 10000, 30000);
  }

  get autoCheck => _autoCheck;

  set autoCheck(AutoCheckLevel val) {
    _autoCheck = val;
    notifyListeners();
    save();
  }

  String get proxy => _proxy;

  set proxy(String value) {
    print('set proxy $value');
    _proxy = value;
    notifyListeners();
    save();
  }

  HideOption get hide => _hide;

  set hide(HideOption value) {
    _hide = value;
    notifyListeners();
    save();
  }

  Map<String, dynamic> toJson() {
    return {
      'autoCheck': _autoCheck.index,
      'proxy': _proxy,
      'hide': _hide.index
    };
  }

  void save() {
    MyHttpClient.init(_proxy, 10000, 30000);
    print('save ${toJson()}');
    Data.instance.setString(key, jsonEncode(toJson()));
  }
}

class ActivitySetting extends StatefulWidget {
  @override
  _ActivitySetting createState() => _ActivitySetting();
}

class _ActivitySetting extends State<ActivitySetting> {
  static final Map<String, AutoCheckLevel> levels = {
    '不检查': AutoCheckLevel.none,
    '7天内看过': AutoCheckLevel.onlyInWeek,
    '全部': AutoCheckLevel.all
  };
  int imagesCount, sizeCount;
  bool isClearing = false;

  @override
  void initState() {
    super.initState();
    imageCaches();
  }

  Future<void> imageCaches() async {
    final files = imageCacheDir.listSync();
    imagesCount = files.length;
    sizeCount = 0;
    files.forEach((file) => sizeCount += file.statSync().size);
    if (mounted) setState(() {});
  }

  Future<void> clearDiskCachedImages() async {
    await imageCacheDir.delete(recursive: true);
    await imageCacheDir.create();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: Consumer<SettingData>(builder: (_, data, __) {
        print('代理 ${data.proxy}');
        return ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              /// 更新设置
              autoCheck(data),

              /// 隐藏状态栏设置
              HideStatusBar(
                option: data.hide,
                onChanged: (option) => data.hide = option,
              ),

              /// 设置代理
              ListTile(
                title: Text('设置代理'),
                subtitle: Text(data.proxy ?? '无'),
                onTap: () async {
                  var proxy = await showDialog<String>(
                      context: context,
                      builder: (_) {
                        final _c = TextEditingController(text: data.proxy);
                        return WillPopScope(
                          child: AlertDialog(
                            title: Text('设置网络代理'),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      '只支持http代理\nSS,SSR,V2Ray,Trojan(Clash)\n这些梯子App都有提供Http代理功能'),
                                  TextField(
                                    controller: _c,
                                    decoration: InputDecoration(
                                        hintText: '例如Clash提供的127.0.0.1:7890'),
                                  ),
                                ]),
                            actions: [
                              FlatButton(
                                child: Text('清空'),
                                onPressed: () {
                                  _c.clear();
                                },
                              ),
                              FlatButton(
                                child: Text('确定'),
                                onPressed: () {
                                  Navigator.pop(context, _c.text);
                                },
                              ),
                            ],
                          ),
                          onWillPop: () {
                            Navigator.pop(context, '-1');
                            return Future.value(false);
                          },
                        );
                      });
                  print('用户输入 $proxy');
                  if (proxy == '-1') return;
                  if (proxy != null) {
                    proxy = proxy
                        .trim()
                        .replaceFirst('http://', '')
                        .replaceFirst('https://', '');
                  }
                  if (proxy == null || proxy.isEmpty) {
                    proxy = null;
                  }
                  print('设置代理 $proxy');
                  data.proxy = proxy;
                },
              ),

              /// 清空图片缓存
              ListTile(
                title: Text('清除所有图片缓存'),
                subtitle: isClearing
                    ? Text('清理中')
                    : Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '图片数量：'),
                            TextSpan(
                                text: imagesCount == null
                                    ? '读取中'
                                    : '$imagesCount 张'),
                            TextSpan(text: '\n'),
                            TextSpan(text: '存储容量：'),
                            TextSpan(
                                text: sizeCount == null
                                    ? '读取中'
                                    : '${filesize(sizeCount)}'),
                          ],
                        ),
                      ),
                onTap: () async {
                  if (isClearing == true) return;
                  final sure = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('确认清除所有图片缓存？'),
                      actions: [
                        RaisedButton(
                          child: Text('确认'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );
                  if (sure == true) {
                    showToast('正在清理图片缓存');
                    isClearing = true;
                    setState(() {});
                    await clearDiskCachedImages();
                    isClearing = false;
                    if (mounted) {
                      setState(() {});
                      await imageCaches();
                    }
                    showToast('成功清理图片缓存');
                  }
                },
              ),

              /// 清空数据缓存
              ListTile(
                title: Text('清空漫画数据缓存'),
                subtitle: Text('正常情况是不需要清空的'),
                onTap: () async {
                  await HttpBook.dataCache.clearAll();
                  showToast('成功清空漫画数据缓存', textPadding: EdgeInsets.all(10));
                },
              ),
            ],
          ).toList(),
        );
      }),
    );
  }

  Widget autoCheck(SettingData data) {
    return ListTile(
      title: Text('自动检查收藏漫画的更新'),
      subtitle: Text('每次启动App后检查一次更新\n有很多漫画收藏的建议只检查7天内看过的漫画'),
      trailing: DropdownButton<AutoCheckLevel>(
        value: data.autoCheck,
        items: levels.keys
            .map(
              (key) => DropdownMenuItem(
                child: Text(key),
                value: levels[key],
              ),
            )
            .toList(),
        onChanged: (level) {
          data.autoCheck = level;
//          setState(() {});
        },
      ),
    );
  }
}
