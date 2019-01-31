

const String urlPrefix = 'https://www.hongxiu.com/';

const String topNavRegOutter = '(?:left-nav fl).*?>(.*?)</div>';
const String topNavRegInner = '(?:.*?)<a[^"]+href="([^"]+)".*?>(.*?)</a';

const String bookRegOutter = '(?:right-book-list).*?>(.*?)</ul>';

// 1: href 2: title 3: imageUrl 4: author 5: 连载中 6: intro
const String bookRegInner =
    '(?:.*?)<a[^"]+href="([^"]+)".*?title="([^"]+)".*?>(?:.*?)src="([^"]+)"'
    '.*?default">([^<]+)'
    '.*?pink">([^<]+)'
    '.*?intro">([^<]+)';

// <p class="btn">
// <a class="border-btn J-getJumpUrl " href="//www.hongxiu.com/chapter/8766036503130303/23641907659131842" id="readBtn" data-firstchapterjumpurl="//www.hongxiu.com/chapter/8766036503130303/23641907659131842" data-uid="//www.hongxiu.com/chapter/8766036503130303/">免费试读</a>
const String readLinkReg = '(?:border-btn J-getJumpUrl).*?href="([^"]+)"';

// <div class="read-content j_readContent"> <p>xxx<p>sss </div>
const String bookContentReg = '(?:read-content j_readContent).*?>(.*?)</div>';
/*
<div class="chapter-control dib-wrap" data-l1="3">
    
    <a id="j_chapterPrev" class="disabled"  href="javascript:void(0);">上一章</a><span>|</span>
    <a href="//www.hongxiu.com/book/8766036503130303#Catalog" target="_blank">目录</a><span>|</span>
    <a id="j_chapterNext" href="//www.hongxiu.com/chapter/8766036503130303/23641913833474117">下一章</a>
</div>
 */
const String bookContentNextChapterReg = '.*?(?:j_chapterNext).*?href="([^"]+)"'; 

const String bookContentAndNextReg = '$bookContentReg$bookContentNextChapterReg';
// final String bookContentChaptListReg = '(?:j_chapterNext).*?href="([^"]+)"'; 
// final String bookContentPrevChapterReg = '(?:j_chapterPrev).*?href="([^"]+)"'; 

const String trimTags = '<[^>]+>';