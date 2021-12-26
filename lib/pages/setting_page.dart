import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:fluwx_no_pay/fluwx_no_pay.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:package_info/package_info.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimareport/api/db_api.dart';
import 'package:yimareport/config/project_config.dart';
import 'package:yimareport/config/project_style.dart';
import 'package:yimareport/db/entities/record.dart';
import 'package:yimareport/entities/version_entity.dart';
import 'package:yimareport/pages/about_page.dart';
import 'package:yimareport/request/mine_api.dart';
import 'package:yimareport/utils/cache_util.dart';
import 'package:yimareport/utils/dialog.dart';
import 'package:yimareport/utils/toast_util.dart';
import 'package:yimareport/utils/version_update_util.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late int doingVal = 7;
  late int cycleVal = 28;
  String cacheTotal = "0.0K";
  String shareLink = "https://yimabao.cn/site/activity";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      getCycle();
      getCacheTotal();
    });
  }
  getCacheTotal() async {
    cacheTotal = await CacheUtil.total();
    setState(() {});
  }
  getCycle() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    doingVal = sharedPreferences.getInt(ProjectConfig.doingKey) ?? 7;
    cycleVal = sharedPreferences.getInt(ProjectConfig.cycleKey) ?? 28;
    ProjectConfig.yimaCycle = cycleVal;
    ProjectConfig.yimaDuration = doingVal;
    setState(() {});
  }
  fetchVersionInfo() async {
    // await [Permission.storage, Permission.requestInstallPackages].request();
    // if (await Permission.storage.isDenied || await Permission.requestInstallPackages.isDenied) {
    //   showToast('权限被禁用，请前往设置开启权限');
    // } else {
      VersionUpdateUtil().checkVersion(context);
    // }

    // PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // var _localVersion = packageInfo.version;
    // VersionEntity versionEntity = await MineAPI.instance.versionInfo({"version": _localVersion, "clienttype": Platform.isIOS ? 'ios' : 'android'});

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
        // leadingWidth: 150,
        brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: PS.backgroundColor,
      ),
      body: Container(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Container(
              color: Colors.black,
              height: 160,
              child: Column(
                children: [
                  Center(
                    child: Icon(Icons.account_circle_rounded, color: Colors.white, size: 100,),
                  ),
                ],
              ),
            ),

            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                List<Record>? _dataSource = await DBAPI.sharedInstance.recordDao.findAllRecordsContainDeleted();
                if (_dataSource.length > 0) {
                  Record record = _dataSource.last;
                  var recordOperationDateTime = DateUtil.getDateTime(record.operationTime);
                  if(ProjectConfig.now.difference(recordOperationDateTime!).inDays > 3 || record.isDeleted == 1) {
                    MyDialog.showAlertDialog(context, () {
                      // Navigator.of(context).pop();
                    }, title: "没有可以删除的记录", message: "仅支持删除四天内的最后一条数据哦", isOnlySureBtn: true, sureBtnTitle: "好", sureBtnTitleColor: Colors.blue);
                  } else {
                    MyDialog.showAlertDialog(context, () async {
                      record.isDeleted = 1;
                      await DBAPI.sharedInstance.recordDao.updateRecord(record);
                      showToast("删除记录成功");
                      // Navigator.of(context).pop();
                    }, title: "删除记录？",
                      message: "${DateUtil.formatDateStr(record.operationTime,format: "yyyy年MM月dd日")}：${record.type == 1 ? "姨妈开始" : "姨妈结束"}",
                      sureBtnTitle: "删除",
                      sureBtnTitleColor: Colors.red,
                      cancelBtnTitleColor: Colors.blue
                    );
                  }
                } else {
                  MyDialog.showAlertDialog(context, () {}, title: "没有可以删除的记录", message: "仅支持删除四天内的最后一条数据哦", isOnlySureBtn: true, sureBtnTitle: "好", sureBtnTitleColor: Colors.blue);
                }
              },
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("删除最后一条记录", style: PS.normalTextStyle(),),
                    // Icon(Icons.chevron_right, color: Colors.grey,)
                  ],
                ),
              ),
            ),
            Divider(height: 1,),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await showDialog(context: context, builder: (BuildContext context){
                  return AlertDialog(
                    contentPadding: EdgeInsets.all(15),
                    content: CycleDialogContent(),
                  );
                });
                getCycle();
              },
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("周期设置", style: PS.normalTextStyle(),),
                    Row(
                      children: [
                        Text("${doingVal}天, ${cycleVal}天", style: PS.smallTextStyle(color: Colors.grey),),
                        // Icon(Icons.chevron_right, color: Colors.grey,)
                      ],
                    )
                  ],
                ),
              ),
            ),
            Divider(height: 1,),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                // shareToWeChat(WeChatShareTextModel("source text", scene: WeChatScene.SESSION));
                showMaterialModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    top: false,
                    child: Container(
                      height: 210,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(padding: EdgeInsets.only(top: PS.marginLarge), child: Text("分享", style: PS.titleTextStyle(),)),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  shareToWeChat(WeChatShareWebPageModel(shareLink, title: "姨妈宝", description: "一款简洁干净的经期记录APP！", scene: WeChatScene.SESSION, thumbnail: WeChatImage.asset("images/flutterads_logo.png")));
                                },
                                child: Container(
                                  margin: EdgeInsets.all(PS.marginLarge),
                                  child: Column(
                                    children: [
                                      Image.asset("images/icon64_wx_logo.png", width: 50,),
                                      Text("微信")
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                              onTap: () {
                                shareToWeChat(WeChatShareWebPageModel(shareLink, title: "姨妈宝", description: "姨妈宝是一款简洁干净的经期记录软件。省去庞杂功能的烦恼。", scene: WeChatScene.TIMELINE, thumbnail: WeChatImage.asset("images/flutterads_logo.png")));
                                },
                                child: Container(
                                  margin: EdgeInsets.all(PS.marginLarge),
                                  child: Column(
                                    children: [
                                      Image.asset("images/icon_res_download_moments.png", width: 50,),
                                      Text("朋友圈")
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                color: PS.ce6e6e6,
                                // width: double.infinity,
                                // height: 50,
                                child: Center(child: Text("取消", style: PS.normalTextStyle(),)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
                // shareToWeChat(WeChatShareWebPageModel("https://yimabao.cn/app/%E5%A7%A8%E5%A6%88%E5%AE%9D.apk", title: "姨妈宝", scene: WeChatScene.SESSION));
              },
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("推荐给好友", style: PS.normalTextStyle(),),
                  ],
                ),
              ),
            ),
            Divider(height: 1,),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await CacheUtil.clear();
                showToast("清除成功");
                getCacheTotal();
              },
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("清除缓存", style: PS.normalTextStyle(),),
                    Row(
                      children: [
                        Text("${cacheTotal}", style: PS.smallTextStyle(color: Colors.grey),),
                        // Icon(Icons.chevron_right, color: Colors.grey,)
                      ],
                    )
                  ],
                ),
              ),
            ),
            Divider(height: 1,),

            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                fetchVersionInfo();
              },
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("检查更新", style: PS.normalTextStyle(),),
                    // Icon(Icons.chevron_right, color: Colors.grey,)
                  ],
                ),
              ),
            ),
            Divider(height: 1,),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return AboutPage();
                }));
              },
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("关于", style: PS.normalTextStyle(),),
                    // Icon(Icons.chevron_right, color: Colors.grey,)
                  ],
                ),
              ),
            ),
            Divider(height: 1,),
            /*
            ListTile(
              onTap: () async {
                List<Record>? _dataSource = await DBAPI.sharedInstance.recordDao.findAllRecordsContainDeleted();

                if (_dataSource.length > 0) {
                  Record record = _dataSource.last;
                  var recordOperationDateTime = DateUtil.getDateTime(record.operationTime);
                  if(ProjectConfig.now.difference(recordOperationDateTime!).inDays > 3 || record.isDeleted == 1) {
                    MyDialog.showAlertDialog(context, () {
                          // Navigator.of(context).pop();
                    }, title: "没有可以删除的记录", message: "仅支持删除四天内的最后一条数据哦");
                  } else {
                    MyDialog.showAlertDialog(context, () async {
                      record.isDeleted = 1;
                      await DBAPI.sharedInstance.recordDao.updateRecord(record);
                      showToast("删除记录成功");
                      // Navigator.of(context).pop();
                    }, title: "删除记录?", message: "${DateUtil.formatDateStr(record.operationTime,format: "yyyy年MM月dd日")}: ${record.type == 1 ? "姨妈来" : "姨妈走"}");
                  }
                }
              },
              title: Text("删除最后一条记录"),
            ),
            Divider(height: 1,),
            ListTile(
              onTap: () async {
                MyDialog.showAlertDialog(context, () async {
                  await DBAPI.sharedInstance.recordDao.deleteAll();
                  showToast("清理缓存成功");
                }, title: "清理缓存?", message: "历史记录会全部清除");

              },
              title: Text("清理缓存"),
            ),
            Divider(height: 1,),
            */
          ],
        ),
      ),
    );
  }
}
