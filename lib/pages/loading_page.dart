import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unionad/flutter_unionad.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimareport/api/db_api.dart';
import 'package:yimareport/config/project_config.dart';
import 'package:yimareport/pages/home_page.dart';

import 'agreement_page.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with SingleTickerProviderStateMixin {
  bool _init = false;
  bool isAdShowed = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    // _requestPermission();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      _privacy();
      _initRegister();
      await DBAPI.load();
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      ProjectConfig.yimaCycle = sharedPreferences.getInt(ProjectConfig.doingKey) ?? 7;
      ProjectConfig.yimaDuration = sharedPreferences.getInt(ProjectConfig.cycleKey) ?? 28;
    });
  }
  goToNextPage() async {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool hasAgree = sharedPreferences.getBool(ProjectConfig.agreementKey) ?? false;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
      return hasAgree ? HomePage() : AgreementPage();
    }));
  }
  @override
  void dispose() {
    super.dispose();
  }

  //注册
  void _initRegister() async {
    _init = await FlutterUnionad.register(
        androidAppId: "${ProjectConfig.adAndroidAppId}",
        //穿山甲广告 Android appid 必填
        iosAppId: "5098580",
        //穿山甲广告 ios appid 必填
        useTextureView: true,
        //使用TextureView控件播放视频,默认为SurfaceView,当有SurfaceView冲突的场景，可以使用TextureView 选填
        appName: "unionad_test",
        //appname 必填
        allowShowNotify: true,
        //是否允许sdk展示通知栏提示 选填
        allowShowPageWhenScreenLock: true,
        //是否在锁屏场景支持展示广告落地页 选填
        debug: false,
        //是否显示debug日志
        supportMultiProcess: false,
        //是否支持多进程，true支持 选填
        directDownloadNetworkType: [
          FlutterUnionadNetCode.NETWORK_STATE_2G,
          FlutterUnionadNetCode.NETWORK_STATE_3G,
          FlutterUnionadNetCode.NETWORK_STATE_4G,
          FlutterUnionadNetCode.NETWORK_STATE_WIFI
        ]); //允许直接下载的网络状态集合 选填
    print("sdk初始化 $_init");
    await FlutterUnionad.getSDKVersion();

    setState(() {});
  }

  // void _requestPermission() async {
  //   await [Permission.storage, Permission.phone].request();
  //   if (await Permission.storage.isDenied) {
  //     // showToast('权限被禁用，部分功能可能无法使用');
  //   }
  // }

  //隐私权限
  void _privacy() async {
    if (Platform.isAndroid) {
      await FlutterUnionad.andridPrivacy(
        isCanUseLocation: false,
        //是否允许SDK主动使用地理位置信息 true可以获取，false禁止获取。默认为true
        lat: 1.0,
        //当isCanUseLocation=false时，可传入地理位置信息，穿山甲sdk使用您传入的地理位置信息lat
        lon: 1.0,
        //当isCanUseLocation=false时，可传入地理位置信息，穿山甲sdk使用您传入的地理位置信息lon
        isCanUsePhoneState: false,
        //是否允许SDK主动使用手机硬件参数，如：imei
        imei: "123",
        //当isCanUsePhoneState=false时，可传入imei信息，穿山甲sdk使用您传入的imei信息
        isCanUseWifiState: false,
        //是否允许SDK主动使用ACCESS_WIFI_STATE权限
        isCanUseWriteExternal: false,
        //是否允许SDK主动使用WRITE_EXTERNAL_STORAGE权限
        oaid: "111", //开发者可以传入oaid
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    Widget contentView() {
      if(_init) {
        return Column(
          children: [
            Offstage(
              offstage: !isAdShowed,
              child: FlutterUnionad.splashAdView(
                //是否使用个性化模版  设定widget宽高
                mIsExpress: true,
                //android 开屏广告广告id 必填
                androidCodeId: "${ProjectConfig.adAndroidId}",
                //ios 开屏广告广告id 必填
                iosCodeId: "887367774",
                //是否支持 DeepLink 选填
                supportDeepLink: true,
                // 期望view 宽度 dp 选填 mIsExpress=true必填
                expressViewWidth: MediaQuery.of(context).size.width,
                //期望view高度 dp 选填 mIsExpress=true必填
                expressViewHeight: MediaQuery.of(context).size.height,
                callBack: FlutterUnionadSplashCallBack(
                  onShow: () {
                    print("开屏广告显示");
                    isAdShowed = true;
                    setState((){});
                  },
                  onClick: () {
                    print("开屏广告点击");
                    // Navigator.pop(context);
                  },
                  onFail: (error) {
                    goToNextPage();
                  },
                  onFinish: () {
                    print("开屏广告倒计时结束");
                    goToNextPage();
                  },
                  onSkip: () {
                    print("开屏广告跳过");
                    goToNextPage();
                  },
                  onTimeOut: () {
                    goToNextPage();
                  },
                ),
              ),
            ),
            Expanded(child: Container(color: Colors.black, child: Image.asset("images/cp_sp.png", width: double.infinity, height: MediaQuery.of(context).size.height, fit: BoxFit.fill,)))
          ],
        );
      } else {
        return Container(color: Colors.black, child: Image.asset("images/cp_sp.png", width: double.infinity, height: MediaQuery.of(context).size.height, fit: BoxFit.fill,));
      }
    }
    return Scaffold(
      body: Container(
        child: contentView(),
      ),
    );
  }
}
