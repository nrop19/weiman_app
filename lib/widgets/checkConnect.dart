import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../crawler/http18Comic.dart';

class CheckConnectWidget extends StatefulWidget {
  @override
  _CheckConnectWidget createState() => _CheckConnectWidget();
}

class _CheckConnectWidget extends State<CheckConnectWidget> {
  LoadState state = LoadState.loading;
  String error;

  @override
  void initState() {
    super.initState();
    check();
  }

  Future<void> check() async {
    setState(() {
      state = LoadState.loading;
    });
    try {
      final res = await Http18Comic.instance.dio.head(
        '/',
        options: buildCacheOptions(
          Duration(seconds: 1),
          forceRefresh: true,
        ),
      );
      assert(res.statusCode == 200);
      setState(() {
        state = LoadState.completed;
      });
    } catch (e) {
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
      } else {
        this.error = e.toString();
      }
      setState(() {
        state = LoadState.failed;
      });
    }
  }

  void showError() async {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('错误内容'),
          content: Text(error.toString()),
          actions: [
            FlatButton(
              child: Text('再次尝试'),
              onPressed: () {
                check();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
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
        row = GestureDetector(
          child: Row(
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
          ),
          onTap: showError,
        );
        break;
      default:
        row = GestureDetector(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
              SizedBox(width: 10),
              Text('成功连接到漫画网站，点击重新测试'),
            ],
          ),
          onTap: check,
        );
    }
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 15),
      child: row,
    );
  }
}
