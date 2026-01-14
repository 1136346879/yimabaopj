import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimabao/api/db_api.dart';
import 'package:yimabao/config/project_config.dart';
import 'package:yimabao/config/project_style.dart';
import 'package:yimabao/request/mine_api.dart';
import 'package:yimabao/utils/dialog.dart';
import 'package:yimabao/utils/local_noti_util.dart';
import 'package:yimabao/utils/toast_util.dart';

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
          title: Text(tr("contact_us")),
          // leadingWidth: 150,
          // brightness: Brightness.dark,
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
                  }, title: tr("apply_delete_account"), message: tr("delete_account_confirm_msg"),
                      sureBtnTitle: tr("delete_account_confirm_btn"));
                }, title: tr("notice"), message: tr("delete_account_notice_msg"),
                    sureBtnTitle: tr("apply_cancellation"),);
              }, child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr("delete_account"), style: PS.normalTextStyle(),),
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
                        Text(tr("customer_service"), style: PS.normalTextStyle(),),
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
