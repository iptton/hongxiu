import 'package:firebase_admob/firebase_admob.dart';

// banner_add_unit_id: ca-app-pub-0952977100607873/2089628447
// FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-0952977100607873~4883312742');

final String _adUnitId = 'ca-app-pub-0952977100607873/2089628447';
final String _adAppId = 'ca-app-pub-0952977100607873~4883312742';

bool _debug = false;

initAd(){
  FirebaseAdMob.instance.initialize(appId: _adAppId);
}

MobileAdTargetingInfo _info = MobileAdTargetingInfo(
  // keywords: <String>['programe', 'network','apple','vpn'],
  childDirected:true,
);
BannerAd _banner = BannerAd(
  adUnitId:_debug?BannerAd.testAdUnitId: _adUnitId,
  size: AdSize.banner,
  targetingInfo: _info,
  listener: (event){
    print('banner event is $event');
  },
);

InterstitialAd _interstitialAd = InterstitialAd(
  adUnitId: _debug? InterstitialAd.testAdUnitId : _adUnitId,
  targetingInfo: _info,
  listener: (event){
    print('interstitialAd event $event');
  },
);

// single instance
BannerAd get banner => _banner;
InterstitialAd get interstitialAd => _interstitialAd;