import 'package:flutter/material.dart';
import 'package:flutter_ebook/common_widgets.dart';
import 'package:flutter_ebook/model.dart';
import 'package:flutter_ebook/pager.dart';
import 'utils.dart' as utils;

class BookPage extends StatefulWidget {
  final BookItem book;

  const BookPage({Key key, this.book}) : super(key: key);
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  BookChapter currentChapter;
  int currentPage = 1;
  Map<int, BookChapter> chapters = {};

  @override
  void initState() {
    _getPage(1);
    super.initState();
  }

  _getPage(int page) {
    if (chapters.containsKey(page)) {
      // has cache
      setState(() {
        currentPage = page;
        currentChapter = chapters[page];
      });
    } else {
      bool fromBookList = page == 1; // page 1
      String url = fromBookList
          ? widget.book.url
          : currentChapter.nextPageUrl;

      getContent(url, fromBookList: fromBookList)
          .then((BookChapter chapter) {
        setState(() {
          currentPage = page;
          chapters[page] = chapter;
          currentChapter = chapter;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildAppBar(context),
      ),
      body: Container(
        width: double.infinity,
        child: Pager(
          onPage: (pageNum) {
            _getPage(pageNum);
          },
          child: SingleChildScrollView(
            child: Text(currentChapter?.content ?? 'loading...'),
          ),
        ),
      ),
    );
  }
}
