import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_installer/app_installer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yimareport/config/project_config.dart';
import 'package:yimareport/entities/apple_info_entity.dart';
import 'package:yimareport/entities/version_entity.dart';
import 'package:yimareport/generated/json/base/json_convert_content.dart';
import 'package:yimareport/request/http_manager.dart';
import 'package:yimareport/request/mine_api.dart';
import 'package:yimareport/utils/toast_util.dart';
import 'dialog.dart';

class VersionUpdateConfig {
  static String _iosType = "jlb-dealer-ios";
  static String _androidType = "jlb--android";
  static String baseUrl = HttpManager.dio.options.baseUrl;
  //TODO
  static String type = Platform.isAndroid ? "1" : "2";
}

class VersionUpdateUtil {
  VersionUpdateUtil._init();
  static final _sharedInstance = VersionUpdateUtil._init();
  factory VersionUpdateUtil() {
    return _sharedInstance;
  }
  BuildContext? context;
  String? _locatPath;
  String _androidDownloadPath = "";
  String _apkName = "testapk";

  bool _isHome = false;
  Dio _dio = new Dio();
  DownloadLoadingWidgetController _downloadLoadingWidgetController = DownloadLoadingWidgetController();

  checkVersion(BuildContext context, {bool isHome = false}) async {
    this.context = context;
    this._isHome = isHome;
    if (Platform.isAndroid) {
      WidgetsFlutterBinding.ensureInitialized();
      if (_locatPath == null) {
        _locatPath = (await _findLocalPath()) + '/Download/';
        final savedDir = Directory(_locatPath!);
        bool hasExisted = await savedDir.exists();
        if (!hasExisted) {
          savedDir.create();
        }
      }
    }
    _checkVersion();
  }

  _compareVersion(String thisVersion, String serverVersion) {
    List<int> thisVersionArr = thisVersion.split('.').map((item) => int.parse(item)).toList();
    List<int> serverVersionArr = serverVersion.split('.').map((item) => int.parse(item)).toList();
    int minVersionCount = thisVersionArr.length <= serverVersionArr.length ? thisVersionArr.length : serverVersionArr.length;
    //按位去比对， 如果server中前面的版本数比本地的要大 就提示更新
    for (int i = 0; i < minVersionCount; i++) {
      if (thisVersionArr[i] < serverVersionArr[i]) {
        return true;//本地版本比server小， 则需要更新
      } else if (thisVersionArr[i] > serverVersionArr[i]) {
        return false;
      }
    }
    // 另一种情况，如 2.4.1， 和2.4.1.1 前面位数都一样 的情况
    if (serverVersionArr.length > thisVersionArr.length) {
      return true;
    }
    return false;
  }

  _checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    // Response response = await _dio.post(VersionUpdateConfig.versionUrl,
    //     queryParameters: {'version': localVersion, 'type': VersionUpdateConfig.type})
    // .catchError((error) {
    //   Fluttertoast.showToast(msg: error.toString());
    // });
    String iosServerVersion;
    bool shouldUpdate = false;
    bool isMust = false;
    if (Platform.isAndroid) {
      // VersionEntity versionEntity = await MineAPI.instance.getAppLatestVersion({'version': localVersion, 'type': VersionUpdateConfig.type}, buildContext: context);
      VersionEntity versionEntity = await MineAPI.instance.versionInfo({"version": localVersion, "clienttype": Platform.isIOS ? 'ios' : 'android'});
      // serverVersion = versionEntity.data?.version ?? "";
      shouldUpdate = versionEntity.data?.updateStatus == 0 ? false : true;
      isMust = versionEntity.data?.updateStatus == 2 ? true : false;
      // _androidDownloadPath = "${ProjectConfig.BASE_URL}${versionEntity.data?.updateUrl ?? ""}";
      _androidDownloadPath = "${versionEntity.data?.updateUrl ?? ""}";
    } else {
      Response response = await Dio().request("http://itunes.apple.com/cn/lookup?id=${ProjectConfig.IOS_APP_ID}");
      final _dataMap = json.decode(response.toString());
      AppleInfoEntity appleInfo = JsonConvert.fromJsonAsT<AppleInfoEntity>(_dataMap);
      if((appleInfo.results ?? []).length == 0) {
        shouldUpdate = false;
      } else {
        iosServerVersion = appleInfo.results?.first?.version ?? '';
        if (!(iosServerVersion == "" || !_compareVersion(localVersion, iosServerVersion))) {
          shouldUpdate = true;
        }
      }

    }

    if (!shouldUpdate) {
      // if (!_isHome) {
      //   MyDialog.showWith(context,
      //       barrierDismissible: false,
      //       message: "已是最新版本",
      //       sureBtnAction: () {
      //       }, isOnlysureBtn: true);
      // }
      showToast('已是最新版本');
      return;
    } else {
      if (Platform.isIOS) {
        //ios跳转到appstore
        MyDialog.showWith(context!,
            barrierDismissible: false,
            isOnlysureBtn: isMust,
            onWillPopValue: false,
            message:
            "检测到有新版本可以更新，是否立即更新?",
            sureBtnAction: () {
              AppInstaller.goStore("", "${ProjectConfig.IOS_APP_ID}", review: true);
              // InstallPlugin.gotoAppStore(
              //     "https://itunes.apple.com/cn/app/id${ProjectConfig.IOS_APP_ID}");
            });
      } else if (Platform.isAndroid) {
        MyDialog.showWith(context!,
            barrierDismissible: false,
            isOnlysureBtn: isMust,
            onWillPopValue: false,
            message:
            "检测到有新版本可以更新，是否立即更新？",
            sureBtnAction: () {
              _downloadApk();
            });
      }
    }
  }

  //下载apk
  _downloadApk() async {
    _showDownloadLoadingDialog();
    print("本地地址： ${_locatPath}/${_apkName}/");
    print(_androidDownloadPath);
    _downloadFile(_androidDownloadPath, _locatPath! + "/${_apkName}/",
        progressCallback: (int count, int total) {
          double progress = count / total;
          _downloadLoadingWidgetController.setProgress(progress);
        }).then((_) {
      _closeDownloadLoadingDialog();
      _installAPK();
    });
  }

  Future<void> _downloadFile(String urlPath, String savePath,
      {ProgressCallback? progressCallback}) async {
    String fileName = urlPath.substring(urlPath.lastIndexOf('/'));
    // String fileName = "app_release.apk";
    try {
      // await _dio.download(urlPath, savePath + fileName,
      // await HttpManager.dio.download(urlPath, savePath + fileName,
      await _dio.download(urlPath, savePath + fileName,
          onReceiveProgress: progressCallback);
    } catch (error) {
      if (error is DioError) {
        Fluttertoast.showToast(msg: "errorType: ${error.type ?? ""}  errorMsg: ${error.message ?? ""}");
      } else {
        Fluttertoast.showToast(msg: error.toString());
      }
    }
  }

  //安装apk
  _installAPK() async {
    // https://github.com/hui-z/flutter_install_plugin
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String packageName = packageInfo.packageName;
    // _locatPath + "/$_apkName/" + (_androidDownloadPath.split("/").last ?? ""), packageName)
    print("intall path： ${_locatPath! + "/$_apkName/" + (_androidDownloadPath.split("/")?.last ?? "")}");
    await AppInstaller.installApk(_locatPath! + "/$_apkName/" + (_androidDownloadPath.split("/")?.last ?? ""));
    // Directory(_locatPath!).deleteSync(recursive: true);
    // InstallPlugin.installApk(
    //     // _locatPath + "/app_release.apk", packageName)
    //     _locatPath! + "/$_apkName/" + (_androidDownloadPath.split("/")?.last ?? ""), packageName)
    //     .then((result) {
    //   //安装成功
    //   print('install apk $result');
    // }).catchError((error) {
    //   print('install apk error: $error');
    //   Navigator.pop(context!); //关闭安装提示
    //   MyDialog.showWith(context!,
    //       message: 'install apk error: $error',
    //       sureBtnAction: ()=>{},
    //       isOnlysureBtn: true);
    // });
  }

  //下载安装路径 https://github.com/flutter/plugins/tree/master/packages/path_provider
  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();
    // final directory = await getTemporaryDirectory();
    return directory?.path ?? '';
    // var path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    // return path;
  }

  //同步数据Loaing
  _showDownloadLoadingDialog() {
    showDialog(
      context: context!,
      barrierDismissible: false, //点击遮罩不关闭对话框
      builder: (context) {
        return DownloadLoadingWidget(controller: _downloadLoadingWidgetController,);
      },
    );
  }

  _closeDownloadLoadingDialog() {
    Navigator.of(context!).pop();
  }

}

class DownloadLoadingWidgetController {
  _DownloadLoadingWidgetState? state;
  bindState(_DownloadLoadingWidgetState state) {
    this.state = state;
  }
  setProgress(double p) {
    state?.progressInt = (p * 100).toInt();
    state?.progress = p;
    state?.setState(() {});
  }
}

class DownloadLoadingWidget extends StatefulWidget {
  final DownloadLoadingWidgetController controller;
  @override
  State<StatefulWidget> createState() => _DownloadLoadingWidgetState();
  DownloadLoadingWidget({Key? key, required this.controller}): super(key: key);
}

class _DownloadLoadingWidgetState extends State<DownloadLoadingWidget> {
  double progress = 0.0;
  int progressInt = 0;
  StreamSubscription? loginSubscription;
  @override
  void initState() {
    super.initState();
    widget.controller.bindState(this);
  }

  @override
  void dispose() {
    super.dispose();
    if (loginSubscription != null) {
      loginSubscription?.cancel();
      loginSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "正在更新",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                )
              ],
            ),
            // SizedBox(
            //   height: 5,
            // ),
            //
            // Row(
            //   children: <Widget>[
            //     Text(
            //       "正在下载",
            //       style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            //     )
            //   ],
            // ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: LinearProgressIndicator(value: progress),
                )
              ],
            ),

            SizedBox(
              height: 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("$progressInt%"),
//                Text("${progressInt}/100")
              ],
            )
          ],
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
