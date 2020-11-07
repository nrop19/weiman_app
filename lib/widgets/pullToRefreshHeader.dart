import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:weiman/widgets/animatedLogo.dart';

class SliverPullToRefreshHeader extends StatelessWidget {
  static final double height = kToolbarHeight * 2;
  final PullToRefreshScrollNotificationInfo info;
  final void Function() onTap;
  final double fontSize;

  const SliverPullToRefreshHeader({
    Key key,
    @required this.info,
    this.onTap,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (info == null) return SliverToBoxAdapter(child: SizedBox());
    double dragOffset = info?.dragOffset ?? 0.0;
    Widget widget;
    if (info.mode == RefreshIndicatorMode.error) {
      widget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('读取网络数据失败\n你可能需要梯子'),
          RaisedButton.icon(
            icon: Icon(Icons.refresh),
            onPressed: onTap,
            label: Text('再次尝试'),
          ),
        ],
      );
    } else if (info.mode == RefreshIndicatorMode.refresh ||
        info.mode == RefreshIndicatorMode.snap) {
      widget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedLogoWidget(width: 20, height: 30),
          SizedBox(width: 5),
          Text('读取中，请稍候'),
        ],
      );
    } else if ([
      RefreshIndicatorMode.drag,
      RefreshIndicatorMode.armed,
      RefreshIndicatorMode.snap
    ].contains(info.mode)) {
      widget = Text('下拉刷新');
    } else {
      widget = SizedBox();
    }
    return SliverToBoxAdapter(
      child: Container(
        height: dragOffset,
        alignment: Alignment.center,
        child: widget,
      ),
    );
  }
}
