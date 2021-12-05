import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimareport/api/db_api.dart';
import 'package:yimareport/config/project_config.dart';
import 'package:yimareport/config/project_style.dart';
import 'package:yimareport/db/entities/record.dart';
import 'package:yimareport/pages/about_page.dart';
import 'package:yimareport/utils/cache_util.dart';
import 'package:yimareport/utils/dialog.dart';
import 'package:yimareport/utils/toast_util.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late int doingVal = 7;
  late int cycleVal = 28;
  String cacheTotal = "0.0K";

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
                CacheUtil.clear();
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

            // GestureDetector(
            //   behavior: HitTestBehavior.opaque,
            //   onTap: () async {
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
            // Divider(height: 1,),
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
