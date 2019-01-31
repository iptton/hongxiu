import 'dart:async';
import 'package:flutter/widgets.dart';

import 'utils.dart' as utils;
import 'consts.dart';


/// TODO: 将获取数据放到  isolate 里执行，因为正文的正则匹配太慢，影响页面刷新
///


  Future<List<Link>> getTopNavs() => utils.getMatchesInsideFromUrl(
      url: '${urlPrefix}all',
      outterPattern: topNavRegOutter,
      pattern: topNavRegInner,
      indexes: [
        1,
        2,
      ],
      processor: (List<String> l) {
        return Link(
            title: utils.getWidgetWithIcon(utils.removeTags(l[1])),
            url: utils.fixUrl(l[0], baseUrl: urlPrefix));
      });

  Future<List<BookItem>> getBooks(String url, {int pageNum = 1}) =>
      utils.getMatchesInsideFromUrl(
          url: utils.fixUrl(url, query: 'pageNum=$pageNum'),
          outterPattern: bookRegOutter,
          pattern: bookRegInner,
          indexes: List<int>.generate(6, (i) => i + 1),
          processor: (List<String> l) {
            /// 0: href
            /// 1: title
            /// 2: imageUrl
            /// 3: author
            /// 4: 连载中
            /// 5: intro
            return BookItem(
              url: utils.fixUrl(l[0]),
              title: l[1],
              coverUrl: utils.fixUrl(l[2]),
              author: l[3],
              status: l[4],
              intro: l[5].trim(),
            );
          });

  Future<String> getContentLinkFromBookList(String url) async {
    var content = await utils.getContent(url);
    List<String> readLinks = utils.getFirstMatchFromContent(
      content: content,
      pattern: readLinkReg,
      processor: (String str) => str,
    );
    if ((readLinks?.length ?? 0) < 1) {
      return null;
    }
    return readLinks[0];
  }

  Future<BookChapter> getContentFromLink(String contentUrl) async {
    var readLink = utils.fixUrl(contentUrl);
    print('readLink = $readLink');
    List<BookChapter> result = await utils.getMatchesFromUrl(
      url: utils.fixUrl(readLink),
      pattern: bookContentAndNextReg,
      indexes: [1, 2],
      processor: (List<String> l) {
        var content = l[0].replaceAll('<p>', '\n');
        var nextUrl = utils.fixUrl(l[1]);
        return BookChapter(content: content, nextPageUrl: nextUrl);
      },
    );
    if (result == null || result.length == 0) return null;
    return result[0];
  }

  /// [fromBookList] : 特殊逻辑，网页中从书列表跳转过去时，先到介绍页，需从介绍页读取首章节
  /// 因此多一个跳转
  Future<BookChapter> getContent(url, {bool fromBookList = false}) async {
    String contentUrl = url;
    if (fromBookList) {
      contentUrl = await utils.computeRunner<String, String>(
          getContentLinkFromBookList, url);
    }
    return await utils.computeRunner(getContentFromLink,contentUrl);;
  }


class BookChapter {
  final String content;
  final int pageNum;
  final String nextPageUrl;

  BookChapter({this.content, this.pageNum, this.nextPageUrl});
}

class BookItem {
  final String url;
  final String intro;
  final String title;
  final String coverUrl;
  final List<String> tags;
  final String author;
  final String status;

  BookItem(
      {this.url,
      this.intro,
      this.title,
      this.coverUrl,
      this.tags,
      this.author,
      this.status});

  @override
  String toString() =>
      '\n{url=$url,title=$title,coverUrl=$coverUrl,status=$status,author:$author,intro:$intro}';
}

class Link {
  final Widget title;
  final String url;

  Link({this.title, this.url});
  @override
  String toString() => '\n{title=$title url=$url}';
}
