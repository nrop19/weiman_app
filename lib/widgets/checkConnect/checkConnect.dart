import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:weiman/crawler/http.dart';
import 'package:weiman/crawler/http18Comic.dart';
import 'package:weiman/db/setting.dart';

class CheckConnectWidget extends StatefulWidget {
  @override
  _CheckConnectWidget createState() => _CheckConnectWidget();
}

class _CheckConnectWidget extends State<CheckConnectWidget> {
  LoadState state = LoadState.loading;
  final List<_Check> https = [];
  String lastProxy;

  @override
  void initState() {
    final setting = Provider.of<Setting>(context, listen: false);
    lastProxy = setting.getProxy();
    createHttps();
    super.initState();
    setting.addListener(() {
      final proxy = setting.getProxy();
      if (lastProxy != proxy) {
        lastProxy = proxy;
        createHttps();
      }
    });
  }

  void createHttps() {
    print('重建http池 proxy:$lastProxy');
    https.clear();
    https.addAll(
      baseUrls.keys.map(
        (key) => _Check(
          name: key,
          url: baseUrls[key],
          proxy: lastProxy,
        ),
      ),
    );
    check();
  }

  void check() async {
    setState(() {
      state = LoadState.loading;
    });
    https.forEach((http) => http.load());
    await Future.wait(https.map((http) => http.load()));
    final bool hasCompleted =
        https.where((http) => http.state == LoadState.completed).isNotEmpty;
    state = hasCompleted ? LoadState.completed : LoadState.failed;
    if (hasCompleted) {
      final sort = https.toList()..sort((a, b) => a.time.compareTo(b.time));
      Http18Comic.instance = sort.first.http;
    }
    setState(() {});
  }

  void _showDialog(String title) async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        title: title,
        https: https,
        retry: check,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget row;
    switch (state) {
      case LoadState.loading:
        row = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('正在尝试连接漫画网站'),
          ],
        );
        break;
      case LoadState.failed:
        row = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Icon(Icons.error, color: Colors.red),
            ),
            SizedBox(width: 10),
            Text('连接不上漫画网站，点击查看错误'),
          ],
        );
        break;
      default:
        row = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Icon(Icons.check_circle, color: Colors.green),
            ),
            SizedBox(width: 10),
            Text('成功连接到漫画网站，点击查看结果'),
          ],
        );
    }
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 15),
      child: GestureDetector(
        child: row,
        onTap: () => _showDialog('测试结果，选择源'),
      ),
    );
  }
}

class Dialog extends StatefulWidget {
  final String title;
  final List<_Check> https;
  final Function retry;

  const Dialog({Key key, this.title, this.https, this.retry}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Dialog();
}

class _Dialog extends State<Dialog> {
  @override
  Widget build(BuildContext context) {
    final proxy = widget.https[0].proxy;
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title),
          if (proxy != null)
            Text('正在使用代理：$proxy', style: TextStyle(fontSize: 14)),
        ],
      ),
      content: Container(
        width: 300,
        height: 300,
        child: ListView(
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          children: ListTile.divideTiles(
              context: context,
              tiles: widget.https.map(
                (e) => e.build(onTap: () => setState(() {})),
              )).toList(),
        ),
      ),
      actions: [
        FlatButton(
          child: Text('再次测试'),
          onPressed: () {
            widget.retry();
            setState(() {});
          },
        ),
      ],
    );
  }
}

class _Check {
  final String name;
  final String proxy;
  Http18Comic http;
  Future future;
  Duration time;
  String error;
  LoadState state;

  _Check({
    String url,
    @required this.name,
    @required this.proxy,
  }) {
    http = Http18Comic(
      url,
      name: name,
      headers: headers,
      proxy: proxy,
    );
  }

  Future load() {
    future = this._load();
    return future;
  }

  Future _load() async {
    state = LoadState.loading;
    final now = DateTime.now();
    try {
      final Response<String> res = await http.dio.get<String>('/');
      final $ = parse(res.data);
      final $title = $.querySelector('title');
      if (res.data.contains('Restricted') ||
          $title == null ||
          $title.text.indexOf('禁漫天堂') == -1) {
        throw DioError(
          request: res.request,
          response: res,
          error: '你使用的IP被漫画网站禁止访问，请更换网络IP\n不要使用日本IP。',
        );
      }
      state = LoadState.completed;
    } catch (e) {
      print(e);
      if (e.runtimeType == DioError) {
        final DioError error = e as DioError;
        switch (error.type) {
          case DioErrorType.CONNECT_TIMEOUT:
          case DioErrorType.RECEIVE_TIMEOUT:
          case DioErrorType.SEND_TIMEOUT:
            this.error = '连接超时';
            break;
          default:
            this.error = error.error.toString();
        }
        if (error.response?.data != null) {
          this.error += '\n接收到的内容：\n' + error.response.data;
        }
      } else {
        this.error = e.toString();
      }
      state = LoadState.failed;
      print('$name 结果 $state');
    }
    time = DateTime.now().difference(now);
  }

  Widget build({Function onTap}) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final Widget title = Text(name);
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            return ListTile(
              title: title,
              subtitle: Row(children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 5),
                Text('读取中'),
              ]),
            );
            break;
          case ConnectionState.done:
            if (state == LoadState.failed) {
              return ListTile(
                title: title,
                subtitle: Text('连接失败，点击查看原因'),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text('$name 错误内容'),
                          content: Text(error),
                        );
                      });
                },
              );
            }
            final _time = time.inMilliseconds;
            final timeString = _time > 1000
                ? '${(time.inMilliseconds / 1000).toStringAsFixed(2)} 秒'
                : '${time.inMilliseconds} 毫秒';
            return CheckboxListTile(
              title: title,
              subtitle: Text('连接成功\n耗时：$timeString'),
              isThreeLine: true,
              value: Http18Comic.instance?.name == name,
              onChanged: (name) {
                Http18Comic.instance = http;
                MyHttpClient.clients[http.id] = http;
                onTap();
              },
            );
            break;
          default:
            return ListTile(title: title, subtitle: Text('还没有开始网络请求'));
        }
      },
    );
  }
}
