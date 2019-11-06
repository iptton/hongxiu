import 'package:test_api/test_api.dart';

import '../lib/consts.dart';
import '../lib/model.dart' as model;

main() {
  group('nav', () {
    test('get top nav items', () async {
      List<model.Link> list = await model.getTopNavs();

      expect(list, isNotNull);
      expect(list?.length ?? 0, isNonZero);
      expect(list, isNotNull);

      List<model.BookItem> list2 = await model.getBooks(urlPrefix + 'all');
      // print('list=$list2');
      expect(list2, isNotNull);
      expect(list2?.length ?? 0, isNonZero);

      model.BookChapter chapter =
          await model.getContent(list2[0].url, fromBookList: true);
//      print(chapter.content);
      expect(chapter, isNotNull);

      String nextUrl = chapter.nextPageUrl;
//      print(nextUrl);
      model.BookChapter chapter2 = await model.getContent(nextUrl);
      expect(chapter2, isNotNull);
      print(chapter2?.content);
    });
  });
}
