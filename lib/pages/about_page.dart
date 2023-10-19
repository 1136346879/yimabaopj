import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:yimabao/config/project_style.dart';
import 'package:yimabao/pages/new_pages/contact_page.dart';
import 'package:yimabao/request/mine_api.dart';
import 'package:yimabao/utils/cache_util.dart';
import 'package:yimabao/utils/dialog.dart';
import 'package:yimabao/utils/local_noti_util.dart';
import 'package:yimabao/utils/toast_util.dart';
import 'package:yimabao/utils/version_update_util.dart';

import 'agreement_h5_page.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}


class _AboutPageState extends State<AboutPage> {
  String _localVersion = "";
  String cacheTotal = "0.0K";
  var userInfo;
  @override
  void initState() {
    super.initState();
    getLocalVersion();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      getCacheTotal();
      userInfo = MineAPI.instance.getAccount();
    });
  }
  getLocalVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _localVersion = packageInfo.version;
    setState(() {});
  }
  fetchVersionInfo() async {
    VersionUpdateUtil().checkVersion(context);
  }
  getCacheTotal() async {
    cacheTotal = await CacheUtil.total();
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
        // leadingWidth: 150,
        brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: PS.c353535
      ),
      body: Container(
        padding: EdgeInsets.only(top: 5),
        color: PS.backgroundColor,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return AgreementH5Page(index: 0,);
                }));
              },
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("用户协议", style: PS.normalTextStyle(),),
                    Icon(Icons.chevron_right, color: Colors.grey,)
                  ],
                ),
              ),
            ),
            Divider(height: 1,),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return AgreementH5Page(index: 1, isShowBackout: true,);
                }));
              },
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("隐私政策", style: PS.normalTextStyle(),),
                    Icon(Icons.chevron_right, color: Colors.grey,)
                  ],
                ),
              ),
            ),
            Divider(height: 1,),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("版本", style: PS.normalTextStyle(),),
                  Row(
                    children: [
                      Text("v${_localVersion}", style: PS.smallTextStyle(color: Colors.grey),),
                    ],
                  )
                ],
              ),
            ),

            Divider(height: 1,),

            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                fetchVersionInfo();
              },
              child: Container(
                color: Colors.white,
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
                await Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return ContactPage();
                }));
                userInfo = MineAPI.instance.getAccount();
                setState(() {});
              },
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("联系我们", style: PS.normalTextStyle(),),
                        // SizedBox(width: 10,),
                        // Text("（注销账号）", style: PS.normalTextStyle(color: Colors.red),),
                      ],
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey,)
                  ],
                ),
              ),
            ),
            // Divider(height: 1,),
            // GestureDetector(
            //   behavior: HitTestBehavior.opaque,
            //   onTap: () async {
            //   },
            //   child: Container(
            //     color: Colors.white,
            //     padding: EdgeInsets.all(16),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text("注销账户", style: PS.normalTextStyle(),),
            //       ],
            //     ),
            //   ),
            // ),

            Container(width: double.infinity, height: 10,),
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

            Container(width: double.infinity, height: 30,),
            Offstage(
              offstage: userInfo == null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  MyDialog.showAlertDialog(context, () async{
                    await MineAPI.instance.memberLogout(context);
                    userInfo = MineAPI.instance.getAccount();
                    LocalNotiUtil.instance.resetNotiQueue();
                    setState(() {

                    });
                  }, title: "提示", message: "确认退出登录？", isOnlySureBtn: false, sureBtnTitle: "退出", sureBtnTitleColor: Colors.red);

                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("退出登录", style: PS.normalTextStyle(color: Colors.red),),
                    ],
                  ),
                ),
              ),
            ),
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
