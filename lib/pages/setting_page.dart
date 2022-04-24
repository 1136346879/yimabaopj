import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info/device_info.dart';
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
import 'package:yimareport/db/entities/local_record.dart';
import 'package:yimareport/entities/login_entity.dart';
import 'package:yimareport/entities/version_entity.dart';
import 'package:yimareport/generated/json/base/json_convert_content.dart';
import 'package:yimareport/pages/about_page.dart';
import 'package:yimareport/request/mine_api.dart';
import 'package:yimareport/utils/cache_util.dart';
import 'package:yimareport/utils/dialog.dart';
import 'package:yimareport/utils/toast_util.dart';
import 'package:yimareport/utils/version_update_util.dart';

import 'member_page.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late int doingVal = 7;
  late int cycleVal = 28;
  String cacheTotal = "0.0K";
  String shareLink = "https://yimabao.cn/site/activity";
  LoginData? userInfo;
  StreamSubscription? stream;
  @override
  void initState() {
    super.initState();
    userInfo = MineAPI.instance.getAccount();
    // setState(() {
    //
    // });
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      getCycle();
      getCacheTotal();
    });
    stream = weChatResponseEventHandler.distinct((a, b) => a == b).listen((res) {
      if (res is WeChatAuthResponse) {
        print("weChatResponseEventHandler");
        print(res.toString());
        login(res.code);
        // setState(() {
        //   var _result = "state :${res.state} \n code:${res.code}";
        //   print(_result);
        // });
        // MyDialog.showCustomDialog(context: context, customBody: SelectableText("${res.code}"));
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    stream?.cancel();
  }
  login(String? code) async {
    String uuid, dev_info;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      uuid = androidInfo.androidId;
      dev_info = androidInfo.model;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      uuid = iosInfo.identifierForVendor;
      dev_info = iosInfo.name;
    }

    LoginEntity entity = await MineAPI.instance.login({"code": code, "uuid": uuid, "dev_info": dev_info});
    //更新头像TODO
    await MineAPI.instance.setAccount(entity.data!);
    userInfo = entity.data!;
    setState(() {});
    await MineAPI.instance.memberLoginSyncData(buildContext: context);
    await MineAPI.instance.memberSyncCircle();
    getCycle();
    //同步信息
  }
  syncData() async {
    MineAPI.instance.memberLoginSyncData(buildContext: context);
  }
  getCacheTotal() async {
    cacheTotal = await CacheUtil.total();
    setState(() {});
  }
  getCycle() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(MineAPI.instance.getAccount() != null) {
      doingVal = sharedPreferences.getInt(ProjectConfig.doingKey) ?? 7;
      cycleVal = sharedPreferences.getInt(ProjectConfig.cycleKey) ?? 28;
    } else {
      doingVal = sharedPreferences.getInt(ProjectConfig.localDoingKey) ?? 7;
      cycleVal = sharedPreferences.getInt(ProjectConfig.localCycleKey) ?? 28;
    }
    ProjectConfig.yimaCycle = cycleVal;
    ProjectConfig.yimaDuration = doingVal;
    setState(() {});
  }
  fetchVersionInfo() async {
      VersionUpdateUtil().checkVersion(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          title: Text(""),
          // leadingWidth: 150,
          brightness: Brightness.dark,
          elevation: 0,
          backgroundColor: PS.backgroundColor,
        ),
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [

            // Material(child: Image.network('https://wx.qlogo.cn/mmopen/vi_32/6pVibWocQNNxFMjQ83sRibZDG2dPcbxelicVjQmaYxnw7FqXNn3F5t0qOYXfodr2BdQ4khiclFdsm7HtcFQ49cljjQ/132', width: 50, height: 50,color: Colors.white,), borderRadius: BorderRadius.circular(25),),
            Container(
              color: Colors.black,
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Offstage(
                    offstage: userInfo != null,
                    child: Center(
                      child: Column(
                        children: [
                          GestureDetector(onTap: () {
                            print("点击登录");
                            sendWeChatAuth(scope: "snsapi_userinfo", state: "wechat_sdk_yimabao");
                          }, child: Image.asset("images/wechat.png", width: 60, height: 60,)),
                          SizedBox(height: 10,),
                          Text("登录", style: PS.normalTextStyle(color: Colors.white))
                        ],
                      ),
                    ),
                  ),
                  Offstage(
                      offstage: userInfo == null,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                            GestureDetector(
                                onTap: () {
                                  MyDialog.showAlertDialog(context, () async{
                                    await MineAPI.instance.memberLogout(context);
                                    userInfo = null;
                                    getCycle();
                                  }, title: "提示", message: "确认退出登录？", isOnlySureBtn: false, sureBtnTitle: "退出", sureBtnTitleColor: Colors.red);

                                },
                                child: Text("退出登录", style: PS.normalTextStyle(color: Colors.white)),
                            ),
                              SizedBox(width: 10,)
                          ],),
                          Center(child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 20,),
                              Offstage(offstage: userInfo?.headimgurl != null, child: Image.asset("images/wechat.png", width: 60, height: 60,)),
                              Offstage(
                                offstage: userInfo?.headimgurl == null,
                                child: Material(
                                  clipBehavior: Clip.antiAlias,
                                  borderRadius: BorderRadius.circular(25),
                                  child: CachedNetworkImage(
                                    width: 50,
                                    height: 50,
                                    imageUrl: userInfo?.headimgurl ?? '',
                                    placeholder: (context, url) => Image.asset("images/wechat.png", width: 50, height: 50,),
                                    errorWidget: (context, url, error) => Image.asset("images/wechat.png", width: 50, height: 50,),
                                  ),
                                ),
                              ),
                              // Offstage(offstage: userInfo?.headimgurl == "", child: Material(child: Image.network(userInfo?.headimgurl ?? '', width: 50, height: 50,color: Colors.white,), borderRadius: BorderRadius.circular(25),)),
                              SizedBox(width: 10,),
                              Text("${userInfo?.nickname ?? ""}", style: PS.normalTextStyle(color: Colors.white)),

                            ],
                          ),),
                        ],
                      )
                  )
                ],
              ),
            ),
            Container(width: double.infinity, height: 10, color: Colors.grey.shade200,),
            // GestureDetector(
            //   behavior: HitTestBehavior.opaque,
            //   onTap: () async {
            //     await MineAPI.instance.clear({"user_id": MineAPI.instance.getAccount()?.user_id, "uuid": await MineAPI.instance.getUUID()});
            //     await DBAPI.sharedInstance.memberRecordDao.deleteAll();
            //     showToast("清除成功");
            //   },
            //   child: Container(
            //     padding: EdgeInsets.all(16),
            //     color: Colors.white,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text("清除服务器和本地用户数据(测试用)", style: PS.normalTextStyle(),),
            //         // Icon(Icons.chevron_right, color: Colors.grey,)
            //       ],
            //     ),
            //   ),
            // ),
            // Divider(height: 1,),

            // GestureDetector(
            //   behavior: HitTestBehavior.opaque,
            //   onTap: () async {
            //     Navigator.push(context, MaterialPageRoute(builder: (_) {
            //       return MemberPage();
            //     }));
            //   },
            //   child: Container(
            //     color: Colors.white,
            //     padding: EdgeInsets.all(16),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text("会员", style: PS.normalTextStyle(),),
            //         // Icon(Icons.chevron_right, color: Colors.grey,)
            //       ],
            //     ),
            //   ),
            // ),
            // Divider(height: 1,),
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
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("推荐给好友", style: PS.normalTextStyle(),),
                  ],
                ),
              ),
            ),
            Container(width: double.infinity, height: 10, color: Colors.grey.shade200,),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await MineAPI.instance.deleteLastRecord(context);
                setState(() {});
              },
              child: Container(
                color: Colors.white,
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
                color: Colors.white,
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
                await CacheUtil.clear();
                showToast("清除成功");
                getCacheTotal();
              },
              child: Container(
                color: Colors.white,
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
            // Divider(height: 1,),
            //
            // GestureDetector(
            //   behavior: HitTestBehavior.opaque,
            //   onTap: () async {
            //     fetchVersionInfo();
            //   },
            //   child: Container(
            //     padding: EdgeInsets.all(16),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text("检查更新", style: PS.normalTextStyle(),),
            //         // Icon(Icons.chevron_right, color: Colors.grey,)
            //       ],
            //     ),
            //   ),
            // ),
            Divider(height: 1,),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return AboutPage();
                }));
              },
              child: Container(
                color: Colors.white,
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
