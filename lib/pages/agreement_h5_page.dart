import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimabao/api/db_api.dart';
import 'package:yimabao/config/project_config.dart';
import 'package:yimabao/config/project_style.dart';
import 'package:yimabao/request/mine_api.dart';
import 'package:yimabao/utils/dialog.dart';

class AgreementH5Page extends StatefulWidget {
  final int index;
  final bool isShowBackout;
  @override
  _AgreementH5PageState createState() => _AgreementH5PageState();
  AgreementH5Page({Key? key, required this.index, this.isShowBackout = false}): super(key: key);
}

class _AgreementH5PageState extends State<AgreementH5Page> {
  InAppWebViewController? _controller;
  late String filePath;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    filePath = widget.index == 0 ? 'https://yimabao.cn/readtemplate/user-agreement' : 'https://yimabao.cn/readtemplate/privacy-policy';
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == 0 ? tr("user_agreement") : tr("privacy_policy")),
        // brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: PS.c353535,
        actions: [
          Offstage(offstage: !(widget.index == 1 && widget.isShowBackout), child: GestureDetector(onTap: () {
            MyDialog.showAlertDialog(context, () async {
              //清数据库数据
              await DBAPI.sharedInstance.memberRecordDao.deleteAll();
              await DBAPI.sharedInstance.recordDao.deleteAll();
              await DBAPI.sharedInstance.markDao.deleteAllLocalMarks();
              await DBAPI.sharedInstance.markDao.deleteAllMemberMarks();
              await MineAPI.instance.clearAccount();
              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
              sharedPreferences.setBool(ProjectConfig.agreementKey, false);
              SystemNavigator.pop();
            }, message: tr("revoke_agreement_warning"), sureBtnTitle: tr("revoke"), sureBtnTitleColor: Colors.red);
          }, child: Center(child: Container(
            padding: EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                Text(tr("revoke_agreement"), style: PS.normalTextStyle(color: Colors.red),),
                SizedBox(width: 15,)
              ],
            ),
          ))))
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(filePath)),
              initialSettings: InAppWebViewSettings(
                isInspectable: kDebugMode,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                iframeAllowFullscreen: true,
                useHybridComposition: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                clearCache: true,
                safeBrowsingEnabled: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                // 忽略 SSL 证书错误，解决证书过期或不被信任导致的白屏问题
                return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
              },
              onLoadStart: (controller, url) {
                debugPrint("WebView started loading: $url");
              },
              onLoadStop: (controller, url) async {
                debugPrint("WebView finished loading: $url");
              },
              onReceivedError: (controller, request, error) {
                debugPrint("WebView error: ${error.description}, code: ${error.type}");
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
            ),
            progress < 1.0
                ? LinearProgressIndicator(value: progress, color: Colors.amber,)
                : Container(
              height: 2,
              color: Colors.red
            ),
          ],
        ),
      ),
    );
  }
}
