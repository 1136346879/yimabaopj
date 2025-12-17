import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  late WebViewController _controller;
  late String filePath;

  @override
  void initState() {
    super.initState();
    filePath = widget.index == 0 ? 'https://yimabao.cn/readtemplate/user-agreement' : 'https://yimabao.cn/readtemplate/privacy-policy';
    _initController();
  }

  _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(filePath));
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == 0 ? "用户协议" : "隐私政策"),
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
            }, message: '撤销协议会清除所有数据，app恢复至首次安装状态', sureBtnTitle: "撤销", sureBtnTitleColor: Colors.red);
          }, child: Center(child: Container(
            padding: EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                Text("撤销协议", style: PS.normalTextStyle(color: Colors.red),),
                SizedBox(width: 15,)
              ],
            ),
          ))))
        ],
      ),
      body: Container(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
