import 'package:flutter/material.dart';

class ProtectFuture extends StatefulWidget {
  final Future future;
  final AsyncWidgetBuilder builder;

  const ProtectFuture({this.future, this.builder});
  @override
  _ProtectFutureState createState() => _ProtectFutureState();
}

class _ProtectFutureState extends State<ProtectFuture> with AutomaticKeepAliveClientMixin<ProtectFuture>{

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: widget.future,
      builder: widget.builder,
    );
  }
}
