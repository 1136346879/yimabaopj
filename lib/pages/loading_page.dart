import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unionad/flutter_unionad.dart';
import 'package:fluwx_no_pay/fluwx_no_pay.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimareport/api/db_api.dart';
import 'package:yimareport/config/project_config.dart';
import 'package:yimareport/db/entities/local_record.dart';
import 'package:yimareport/db/entities/record.dart';
import 'package:yimareport/pages/home_page.dart';
import 'package:yimareport/pages/main_page.dart';
import 'package:yimareport/request/mine_api.dart';
import 'package:yimareport/utils/local_noti_util.dart';


import 'agreement_page.dart';

class LoadingPage extends StatefulWidget {
  final bool isIgnoreUnionad;
  LoadingPage({Key? key, this.isIgnoreUnionad = false}): super(key: key);
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with SingleTickerProviderStateMixin {
  bool _init = false;
  bool isAdShowed = false;

  @override
  void initState() {
    super.initState();
    // JPush jpush = new JPush();
    // jpush.setup(
    //   appKey: "06cd8173691fac83e795e819",
    //   channel: "theChannel",
    //   production: false,
    //   debug: false, // 设置是否打印 debug 日志
    // );
    SystemChrome.setEnabledSystemUIOverlays([]);
    // _requestPermission();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      registerWxApi(appId: "wxfa505eddadc31630",universalLink: "https://www.yimabao.cn/apple-app-site-association");
      _privacy();
      _initRegister();
      await DBAPI.load();
      await LocalNotiUtil.instance.load();
      MineAPI();
      // await Future.delayed(const Duration(milliseconds: 1000));
      await dbMigration();
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      ProjectConfig.yimaCycle = sharedPreferences.getInt(ProjectConfig.doingKey) ?? 7;
      ProjectConfig.yimaDuration = sharedPreferences.getInt(ProjectConfig.cycleKey) ?? 28;
      if(widget.isIgnoreUnionad) {
        goToNextPage();
      }
    });
  }
  Future<void> initPlatformState() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    // androidInfo.androidId //android唯一标识
    // androidInfo.model; //android设备名
    // xx.identifierForVendor//ios 唯一标识
    // xx.name//ios设备名
    print('Running on ${androidInfo.model}');  // e.g. "Moto G (4)"
  }
  goToNextPage() async {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool hasAgree = sharedPreferences.getBool(ProjectConfig.agreementKey) ?? false;
    // if(Platform.isAndroid) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
        return hasAgree ? MainPage() : AgreementPage();
      }));
    // } else {
    //   Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) {
    //     return hasAgree ? HomePage() : AgreementPage();
    //   }));
    // }

  }
  dbMigration() async {
    print("转移数据");
    //数据导到新表， 更改字段及类型
    List<Record>? _dataSource = await DBAPI.sharedInstance.recordDao.findAllRecords();
    print("数据长度-- ${_dataSource.length}");
    if(_dataSource.length == 0) return;
    List<LocalRecord> _localData = _dataSource.map((item) {
      LocalRecord localRecord = LocalRecord(
          null,
          "${DateUtil.getDateTime(item.operationTime)!.millisecondsSinceEpoch}",
          "${DateUtil.getDateTime(item.addTime)!.millisecondsSinceEpoch}",
          item.type,
          isDeleted: item.isDeleted
      );
      // LocalRecord localRecord = LocalRecord()..markAt = DateUtil.getDateTime(item.operationTime)!.millisecondsSinceEpoch..createAt = DateUtil.getDateTime(item.addTime)!.millisecondsSinceEpoch..type = item.type..isDeleted = item.isDeleted;
      return localRecord;
    }).toList();
    await DBAPI.sharedInstance.localRecordDao.batchInsertRecords(_localData);
    await DBAPI.sharedInstance.recordDao.deleteAll();
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
        iosAppId: "${ProjectConfig.adIosAppId}",
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
  //   await [Permission.storage, Permission.requestInstallPackages].request();
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
                iosCodeId: "${ProjectConfig.adIosId}",
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
                    if(Platform.isIOS){ // 设置状态栏背景及颜色
                      goToNextPage();
                    }

                    // Navigator.pop(context);
                  },
                  onFail: (error) async {
                    print("开屏广告fail: ${error.toString()}");
                    await Future.delayed(const Duration(milliseconds: 1000));
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
                    print("开屏超时");
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
        color: Colors.black,
        child: contentView(),
      ),
    );
  }
}
