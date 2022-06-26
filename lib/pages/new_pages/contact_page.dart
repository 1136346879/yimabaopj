import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimareport/api/db_api.dart';
import 'package:yimareport/config/project_config.dart';
import 'package:yimareport/config/project_style.dart';
import 'package:yimareport/request/mine_api.dart';
import 'package:yimareport/utils/dialog.dart';
import 'package:yimareport/utils/local_noti_util.dart';
import 'package:yimareport/utils/toast_util.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  var account;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    account = MineAPI.instance.getAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("联系我们"),
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
            Offstage(
              offstage: account == null,
              child: GestureDetector(onTap: () {
                MyDialog.showAlertDialog(context, () async {
                  MyDialog.showAlertDialog(context, () async {
                    await MineAPI.instance.destroy({"user_id": account?.user_id ?? '', "uuid": await MineAPI.instance.getUUID()}, buildContext: context);
                    //清数据库数据
                    await DBAPI.sharedInstance.memberRecordDao.deleteAll();
                    // await DBAPI.sharedInstance.recordDao.deleteAll();
                    // await DBAPI.sharedInstance.markDao.deleteAllLocalMarks();
                    await DBAPI.sharedInstance.markDao.deleteAllMemberMarks();
                    await MineAPI.instance.clearAccount();
                    account = MineAPI.instance.getAccount();
                    LocalNotiUtil.instance.resetNotiQueue();
                    setState(() {});
                    // showToast("注销账号已申请");
                    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                    // sharedPreferences.setBool(ProjectConfig.agreementKey, false);
                    // SystemNavigator.pop();
                  }, title: '申请注销账号', message: '确定要注销账号吗？\n\n您的用户数据我们将继续为您保留12个月。如需继续使用姨妈宝APP，可以在12个月以内登录姨妈宝APP，数据还会恢复哦~\n',
                      sureBtnTitle: "注销账号");
                }, title: '注意', message: '1、申请注销账号后，账号信息将继续在服务器留存12个月。期间如果用户再次登录，则视为放弃账号注销，本app将继续为用户提供服务。\n\n2、申请注销账号后，用户连续12个月未登录，服务器将定期集中清理注销账号所有数据。用户数据被清理后将彻底丢失且无法恢复。\n\n3、如果有任何疑问请联系客服咨询。\n',
                    sureBtnTitle: "申请注销",);
              }, child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("注销账号", style: PS.normalTextStyle(),),
                        // Icon(Icons.chevron_right, color: Colors.grey,)
                      ],
                    ),
                ),
        ),
            ),

            // GestureDetector(
            //   behavior: HitTestBehavior.opaque,
            //   onTap: () async {
            //
            //   },
            //   child: Container(
            //     color: Colors.white,
            //     padding: EdgeInsets.all(16),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text("注销账号", style: PS.normalTextStyle(),),
            //         // Icon(Icons.chevron_right, color: Colors.grey,)
            //       ],
            //     ),
            //   ),
            // ),
            // Divider(height: 1,),
            Container(width: double.infinity, height: 5,),

            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {

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
                        Text("客服", style: PS.normalTextStyle(),),
                      ],
                    ),
                    // Icon(Icons.chevron_right, color: Colors.grey,)
                    Text("QQ:1350799918", style: PS.smallTextStyle(color: Colors.grey),),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
