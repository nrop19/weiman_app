part of '../main.dart';

enum AutoCheckLevel {
  none,
  onlyInWeek,
  all,
}

class SettingData extends ChangeNotifier {
  static final String key = 'setting_data';
  AutoCheckLevel _autoCheck;

  SettingData() {
    final Map<String, dynamic> data =
        jsonDecode(Data.instance.getString(key) ?? '{}');
    _autoCheck = data['autoCheck'] == null
        ? AutoCheckLevel.onlyInWeek
        : AutoCheckLevel.values[data['autoCheck']];
    print('SettingData');
    print(toJson());
  }

  get autoCheck => _autoCheck;

  set autoCheck(AutoCheckLevel val) {
    _autoCheck = val;
    notifyListeners();
    save();
  }

  Map<String, dynamic> toJson() {
    return {'autoCheck': _autoCheck.index};
  }

  void save() {
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
    final dir = await getTemporaryDirectory();
    final cacheDir = Directory(path.join(dir.path, CacheImageFolderName));
    if (cacheDir.existsSync() == false) cacheDir.createSync();
    final files = cacheDir.listSync();
    imagesCount = files.length;
    sizeCount = 0;
    files.forEach((file) => sizeCount += file.statSync().size);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: Consumer<SettingData>(
        builder: (_, data, __) => ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
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
                  final makeSure = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('确认清除所有图片缓存？'),
                      actions: [
                        FlatButton(
                          child: Text('取消'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        RaisedButton(
                          child: Text('确认'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );
                  if (makeSure == false) return;
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
                },
              ),
              autoCheck(data),
            ],
          ).toList(),
        ),
      ),
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
