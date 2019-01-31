import 'dart:async';

import 'package:flutter/material.dart';

typedef void OnPageFun(int page);

///
/// TODO: 当前页面是否跳转成功，不应该由此控件决定，onPage 方法应该重新设计
/// TODO: 页面布局更灵活，可选择页面
///

class Pager extends StatefulWidget {
  final Widget child;
  final Widget next;
  final Widget prev;
  final OnPageFun onPage;

  const Pager({
    Key key,
    this.onPage,
    @required this.child,
    this.next,
    this.prev,
  }) : super(key: key);
  _PagerState createState() => _PagerState();
}

class _PagerState extends State<Pager> {
  Widget _next;
  Widget _prev;
  TextField _current;

  TextEditingController _textEditingController;

  int _currentPage = 1;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _textEditingController = TextEditingController(text: "$_currentPage");

    _next = FlatButton(
      child: widget.next ?? Icon(Icons.navigate_next),
      onPressed: () {
        _textEditingController.text = '${++_currentPage}';
        if (widget.onPage != null) {
          widget.onPage(_currentPage);
        }
      },
    );
    _prev = FlatButton(
      child: widget.prev ?? Icon(Icons.navigate_before),
      onPressed: () {
        _textEditingController.text = '${--_currentPage}';
        if (widget.onPage != null) {
          widget.onPage(_currentPage);
        }
      },
    );
    _current = TextField(
      keyboardType: TextInputType.number,
      controller: _textEditingController,
      onSubmitted: (newStr) {
        var n = int.tryParse(newStr);
        if (n == null || n <= 0) {
          _textEditingController.text = '$_currentPage';
        } else {
          _currentPage = n;
          if (widget.onPage != null) {
            widget.onPage(_currentPage);
          }
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: widget.child,
        ),
        Expanded(
          flex: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).bottomAppBarColor,
              boxShadow: [
                BoxShadow(color: Colors.grey,blurRadius: 1,),
              ]
            ),
            child: Row(
              children: <Widget>[
                _prev,
                Text('  $_currentPage '),
                _next
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
