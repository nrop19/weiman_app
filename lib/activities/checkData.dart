part of '../main.dart';

class ActivityCheckData extends StatefulWidget {
  @override
  _State createState() => _State();
}

enum CheckState {
  Uncheck,
  Pass,
  Fail,
}

final titleTextStyle = TextStyle(fontSize: 14, color: Colors.blue),
    passStyle = TextStyle(color: Colors.green),
    failStyle = TextStyle(color: Colors.red);

class _State extends State<ActivityCheckData> {
  CheckState firstState;
  int firstLength = 0;
  final TextSpan secondResults = TextSpan();
  TextEditingController _outputController, _inputController;

  @override
  void initState() {
    super.initState();
    _outputController = TextEditingController();
    _inputController = TextEditingController();
  }

  TextSpan first() {
    String text;
    switch (firstState) {
      case CheckState.Pass:
        text = '有数据, 一共 $firstLength 本收藏';
        break;
      case CheckState.Fail:
        text = '没有收藏数据';
        break;
      default:
        text = '未检查';
    }
    return TextSpan(
        text: text,
        style: firstState == CheckState.Pass ? passStyle : failStyle);
  }

  @override
  Widget build(BuildContext context) {
    final firstChildren = [
      Text('检查漫画收藏列表'),
      RaisedButton(
        child: Text('检查'),
        color: Colors.blue,
        textColor: Colors.white,
        onPressed: () {
          final has = Data.has(Data.favoriteBooksKey);
          if (has) {
            final String str = Data.instance.getString(Data.favoriteBooksKey);
            final Map<String, Object> map = json.decode(str);
            firstLength = map.keys.length;
            _outputController.text = str;
          }
          firstState = firstLength > 0 ? CheckState.Pass : CheckState.Fail;

          setState(() {});
        },
      ),
      RichText(
        text: TextSpan(
            text: '结果：',
            children: [first()],
            style: TextStyle(color: Colors.black)),
      ),
    ];
    if (firstState == CheckState.Pass) {
      firstChildren.add(Text('点击复制'));
      firstChildren.add(TextField(
        maxLines: 8,
        controller: _outputController,
        onTap: () {
          showToast('已经复制');
          Clipboard.setData(ClipboardData(text: _outputController.text));
        },
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('收藏数据检修'),
      ),
      body: ListView(children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: firstChildren,
              ),
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('导入收藏数据'),
                TextField(
                  controller: _inputController,
                  maxLines: 8,
                ),
                RaisedButton(
                  child: Text('导入'),
                  onPressed: () {
                    if (_inputController.text.length > 0) {
                      Data.instance.setString(
                          Data.favoriteBooksKey, _inputController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
