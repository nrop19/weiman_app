import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:weiman/main.dart';

class ActivityWeb extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<ActivityWeb> {
  LoadState state = LoadState.loading;

  @override
  void initState() {
    analytics.setCurrentScreen(screenName: '/activity_update_web');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('最新版本'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          WebView(
            initialUrl: 'https://nrop19.github.io/weiman_app',
            onWebViewCreated: (controller) {
              state = LoadState.loading;
              setState(() {});
            },
            onPageFinished: (_) {
              state = LoadState.completed;
              setState(() {});
            },
          ),
          if (state == LoadState.loading)
            Container(
              color: Colors.grey.withOpacity(0.3),
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
