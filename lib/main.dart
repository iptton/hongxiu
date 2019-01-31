import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook/admob.dart';
import 'package:flutter_ebook/background_text.dart';
import 'package:flutter_ebook/book_page.dart';
import 'package:flutter_ebook/common_widgets.dart';
import 'package:flutter_ebook/consts.dart';
import 'package:flutter_ebook/model.dart';
import 'package:flutter_ebook/pager.dart';

void main() {
  initAd();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _pageNum = 1;
  @override
  void initState() {
    // interstitialAd
    //   ..load()
    //   ..show(
    //     anchorOffset: 70,
    //     anchorType: AnchorType.top,
    //   );

    banner
      ..load()
      ..show(
        anchorOffset: 60.0,
        anchorType: AnchorType.bottom,
      );

    _getPage();
    _getCats();
    super.initState();
  }

  _getPage() {
    var url = _currentLink?.url ?? '${urlPrefix}all';
    getBooks(url, pageNum: _pageNum).then((List<BookItem> list) {
      setState(() {
        _books = list;
      });
    });
  }

  void _getCats() {
    getTopNavs().then((list) {
      setState(() {
        print(_cats);
        _cats = list;
      });
    });
  }

  Link _currentLink;
  List<Link> _cats = [];
  List<BookItem> _books = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView.builder(
          itemCount: _cats.length,
          itemBuilder: (context, i) {
            return ListTile(
              title: _cats[i].title,
              onTap: () {
                _pageNum = 1;
                _currentLink = _cats[i];
                _getPage();
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      appBar: AppBar(
        title: buildAppBar(context),
      ),
      body: Pager(
        child: _buildBooList(),
        onPage: (int page){
          _pageNum = page;
          _getPage();
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  ListView _buildBooList() {
    return ListView.builder(
      itemCount: _books.length,
      itemBuilder: (context, index) {
        BookItem item = _books[index];
        return Container(
          color: index % 2 == 0 ?Color.fromARGB(255, 0xF0, 0xF0, 0xE9):Color.fromARGB(255, 0xE3, 0xE3, 0xE9),
          child: ListTile(
            leading: Image.network(item.coverUrl),
            title: Text(item.title),
            subtitle: Text(item.intro),
            onTap: () {
              openBook(item);
            },
          ),
        );
      },
    );
  }

  void openBook(BookItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BookPage(book: item),
    ));
  }
}
