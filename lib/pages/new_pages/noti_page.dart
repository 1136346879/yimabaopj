import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimareport/config/project_config.dart';
import 'package:yimareport/config/project_style.dart';
import 'package:yimareport/pages/new_pages/noti_test.dart';
import 'package:yimareport/utils/local_noti_util.dart';

class NotiPage extends StatefulWidget {
  @override
  _NotiPageState createState() => _NotiPageState();
}

class _NotiPageState extends State<NotiPage> {
  bool isShowLocalNoti = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      isShowLocalNoti = sharedPreferences.getBool(ProjectConfig.localNotiKey) ?? false;
      setState(() {

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("通知与提醒"),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: PS.c353535),
      body: Container(
        padding: EdgeInsets.only(top: 5),
        color: PS.backgroundColor,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("经期提醒", style: PS.normalTextStyle(),),
                  Switch(value: isShowLocalNoti, onChanged: (val) async {
                    isShowLocalNoti = val;
                    setState(() {

                    });
                    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                    sharedPreferences.setBool(ProjectConfig.localNotiKey, val);
                    if(val) {
                      await LocalNotiUtil.instance.resetNotiQueue();
                    } else {
                      await LocalNotiUtil.instance.cancelAllNotis();
                    }

                  })
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15, right: 30, top: 10, bottom: 10),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("距离经期5天", style: PS.smallTextStyle(color: PS.c888888),),
                      Text("上午8:00", style: PS.smallTextStyle(color: PS.c888888),),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 15, right: 30, top: 10, bottom: 10),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("距离经期3天", style: PS.smallTextStyle(color: PS.c888888),),
                      Text("上午8:00", style: PS.smallTextStyle(color: PS.c888888),),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 15, right: 30, top: 10, bottom: 10),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("距离经期1天", style: PS.smallTextStyle(color: PS.c888888),),
                      Text("上午8:00", style: PS.smallTextStyle(color: PS.c888888),),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 15, right: 30, top: 10, bottom: 10),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("经期开始日", style: PS.smallTextStyle(color: PS.c888888),),
                      Text("上午8:00", style: PS.smallTextStyle(color: PS.c888888),),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 15, right: 30, top: 10, bottom: 10),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("经期结束日", style: PS.smallTextStyle(color: PS.c888888),),
                      Text("上午8:00", style: PS.smallTextStyle(color: PS.c888888),),
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return NotiTest();
                }));
              },
              child: Container( padding: EdgeInsets.all(20), child: Center(child: Text("测试--点击查看本地通知数据"),)),
            )
          ],
        ),
      ),
    );
  }
}
