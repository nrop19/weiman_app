part of '../main.dart';

class SliverPullToRefreshHeader extends StatelessWidget {
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
    TextSpan text = TextSpan(
        style: Theme.of(context).textTheme.body1.copyWith(
              fontSize: fontSize,
            ),
        children: [
          WidgetSpan(
            baseline: TextBaseline.alphabetic,
            child: Padding(
              child: Image.asset("images/logo.png", height: 20),
              padding: EdgeInsets.only(right: 5),
            ),
          ),
        ]);
    if (info.mode == RefreshIndicatorMode.error) {
      text.children.addAll([
        TextSpan(
          text: '读取失败\n当失败次数太多请检查网络情况\n有些很旧的章节会看不到，请见谅\n',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        WidgetSpan(
            child: RaisedButton.icon(
                icon: Icon(Icons.refresh),
                onPressed: onTap,
                label: Text('再次尝试'))),
      ]);
    } else if (info.mode == RefreshIndicatorMode.refresh ||
        info.mode == RefreshIndicatorMode.snap) {
      text.children.addAll([
        TextSpan(text: '读取中，请稍候'),
      ]);
    } else if ([
      RefreshIndicatorMode.drag,
      RefreshIndicatorMode.armed,
      RefreshIndicatorMode.snap
    ].contains(info.mode)) {
      text.children.add(TextSpan(text: '重新读取'));
    } else {
      text.children.add(TextSpan(text: 'Bye~'));
    }
    return SliverToBoxAdapter(
      child: Container(
        height: dragOffset,
        child: Center(
          child: Text.rich(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
