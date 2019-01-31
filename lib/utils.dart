import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ebook/consts.dart';
import 'package:meta/meta.dart';
import 'package:isolate/isolate_runner.dart';

Future<String> getContent(String url, {String cookies}) async {
  var req = await HttpClient().getUrl(Uri.parse(url));
  req.headers.add("User-Agent", _getUserAgent());
  req.headers.add("cookie", cookies ?? "");
  var res = await req.close();
  var result = await res.transform(utf8.decoder).join();
  // print("getContent:$url $result");
  return result.replaceAll(RegExp('\\r|\\n'), " ");
}

List<String> getFirstMatch(String src,
    {String pattern, List<int> indexes = const <int>[1, 3]}) {
  var reg = RegExp(pattern, multiLine: true, caseSensitive: false);
  // print('${src.indexOf("right-book-list")} ========');
  var match = reg.firstMatch(src);
  if (match == null) {
    print(' ${src.substring(14469)}');
    return [];
  }
  return indexes.map((i) {
    return match.group(i);
  }).toList();
}

List<List<String>> getMatches(String src,
    {String pattern, List<int> indexes = const <int>[1, 3]}) {
  var reg = RegExp(pattern, multiLine: true, caseSensitive: false);
  var matches = reg.allMatches(src);
  // print("matches: ${matches.length}");

  return matches?.map((match) {
    if (indexes.length > match.groupCount) return null;
    // print("${match.groupCount}");
    return indexes.map((i) {
      return match.group(i);
    }).toList();
  })?.toList();
}

Future<List<String>> sendRequestGetCookie(url, {String query = ''}) async {
//  print("get cookie $url");
  var req = await HttpClient().getUrl(Uri.parse(url));
  req.headers.add("User-Agent", _getUserAgent());
  var res = await req.close();
  var cookie = res.cookies
      .map((cookie) {
        return "${cookie.name}=${cookie.value}; ";
      })
      .toList()
      .join();
  var body = await res.transform(utf8.decoder).join();
  body = body.replaceAll(RegExp('\\r|\\n'), " ");
//  print("body=${body.substring(9800)}");
  return [cookie, body];
}

List<ITEM> getMatchesFromContent<ITEM>({
  @required String content,
  @required String pattern,
  @required List<int> indexes,
  ITEM processor(List<String> l),
}) {
  return getMatches(content, pattern: pattern, indexes: indexes)
      .map(processor)
      .toList();
}

List<ITEM> getFirstMatchFromContent<ITEM>({
  String content,
  String pattern,
  List<int> indexes = const <int>[1],
  @required ITEM processor(String l),
}) {
  return getFirstMatch(content, pattern: pattern, indexes: indexes)
      .map(processor)
      .toList();
}

List<Item> getMatchesInsideContent<Item>(
  String content, {
  @required String outterPattern,
  @required String innerPattern,
  Item processor(List<String> l),
  List<int> indexes = const <int>[1],
}) {
  List<String> listOuter = getFirstMatchFromContent(
          processor: (String str) => str,
          content: content,
          pattern: outterPattern,
          indexes: [1]) ??
      [];
  // print('listouter: $listOuter');
  if (listOuter.length > 0) {
    var contentInner = listOuter[0];
    return getMatchesFromContent(
      content: contentInner,
      pattern: innerPattern,
      indexes: indexes,
      processor: processor,
    );
  } else {
    return null;
  }
}

Future<List<ITEM>> getMatchesInsideFromUrl<ITEM>({
  @required String url,
  String cookie,
  @required String pattern,
  @required String outterPattern,
  List<int> indexes = const <int>[1, 2],
  updateCookie: true,
  ITEM processor(List<String> l),
}) async {
  var str = await getContent(url, cookies: cookie);
  return getMatchesInsideContent(str,
      innerPattern: pattern,
      outterPattern: outterPattern,
      indexes: indexes,
      processor: processor);
}

Future<List<ITEM>> getMatchesFromUrl<ITEM>({
  String url,
  String cookie,
  String pattern,
  List<int> indexes,
  updateCookie: true,
  ITEM processor(List<String> l),
}) async {
  var str = await getContent(url, cookies: cookie);
  return getMatches(str, pattern: pattern, indexes: indexes)
      .map(processor)
      .toList();
}

///
/// fix url like:
///   /path1/path2/?que  http://host.to.replaced/path1/path2
/// to
///   http://real.host/path1/path2/
///
/// fix url like:
///   //host.com/path
/// to
///   https://host.com/path
///
/// if {query} not null add queries correctly
///
String fixUrl(String targetUrl, {String query, String baseUrl = urlPrefix}) {
  var result = targetUrl;
  if (!targetUrl.startsWith(baseUrl)) {
    //  if(targetUrl.startsWith('https://')){
    //    targetUrl = targetUrl.substring('https://'.length);// 好笨的方法，为什么不用正则匹配(好的，马上用!)
    //    targetUrl = targetUrl.substring(targetUrl.indexOf('/')); // 如果为 -1 呢 ?
    //  }

    if (targetUrl.startsWith('//')) {
      result = 'https:$targetUrl';
    } else {
      targetUrl = mayReplaceHost(targetUrl, baseUrl);

      if (baseUrl.endsWith("/") && targetUrl.startsWith("/")) {
        targetUrl = targetUrl.substring(1);
      }
      result = baseUrl + targetUrl;
    }
  }

// don't use targetUrl below.use result.
  if (query != null) {
    var hashIndex = result.indexOf("#");
    var queryIndex = result.indexOf('?');
    var path = result;
    var hashes = "";
    if (hashIndex != -1) {
      path = result.substring(0, hashIndex);
      hashes = result.substring(hashIndex);

      if (queryIndex > hashIndex) {
        // ? after # , not real query
        queryIndex = -1;
      }
    }

    if (queryIndex != -1) {
      result = '$path&query$hashes';
    } else {
      result = '$path?$query$hashes';
    }
  }
  return result;
}

String removeTags(String content) => content.replaceAll(RegExp(trimTags), '');

String mayReplaceHost(String targetUrl, String baseUrl) =>
    targetUrl.replaceFirst(RegExp('(https://([^/]+)/?)'), baseUrl);

String _getUserAgent() {
  return "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36";
}

Widget getWidgetWithIcon(String text) {
  var iconFontReg = '&#([^;]*);';
  // List<String>result = getFirstMatchFromContent(
  //   content: text,
  //   pattern: iconFontReg,
  //   processor: (String str)=>str,
  // );
  // print("text=$text");
  var match = RegExp(iconFontReg).firstMatch(text);
  if ((match?.groupCount ?? 0) >= 1) {
    text = text.replaceAll(RegExp(iconFontReg), '').trim();
    var x = match.group(0);
    x = x.replaceAll('&#', '').replaceAll(';', '');
    // print('match =  ${match[0]}');
    int n = int.parse('0$x');
    IconData iconData = IconData(n,fontFamily: 'MaterialIcons');
    Icon icon = Icon(iconData,);
    return Row(
      children: <Widget>[icon, Text(text)],
    );
  } else {
    return Text(text);
  }
}

typedef ComputeCallbackRunner<Q,R> = FutureOr<R> Function(Q message);

Future<R> computeRunner<Q,R>(ComputeCallbackRunner<Q,R> computeCallback,Q message) async {
  final runner = await IsolateRunner.spawn();
  return runner
    .run(computeCallback, message)
    .whenComplete(() => runner.close());
}
