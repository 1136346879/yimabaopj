import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:yimareport/config/project_style.dart';

import 'agreement_h5_page.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}


class _AboutPageState extends State<AboutPage> {
  String _localVersion = "";
  @override
  void initState() {
    super.initState();
    getLocalVersion();
  }
  getLocalVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _localVersion = packageInfo.version;
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("关于"),
        // leadingWidth: 150,
        brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: PS.backgroundColor,
      ),
      body: Container(
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
                  return AgreementH5Page(index: 1,);
                }));
              },
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("隐私协议", style: PS.normalTextStyle(),),
                    Icon(Icons.chevron_right, color: Colors.grey,)
                  ],
                ),
              ),
            ),
            Divider(height: 1,),
            Container(
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
              },
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("联系我们", style: PS.normalTextStyle(),),
                    Text("QQ:1350799918", style: PS.smallTextStyle(color: Colors.grey),),
                  ],
                ),
              ),
            ),
            Divider(height: 1,)
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
