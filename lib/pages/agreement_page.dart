import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluwx_no_pay/fluwx_no_pay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimareport/config/project_config.dart';
import 'package:yimareport/config/project_style.dart';
import 'package:yimareport/pages/loading_page.dart';
import 'package:yimareport/pages/main_page.dart';

import 'agreement_h5_page.dart';
import 'home_page.dart';

class AgreementPage extends StatefulWidget {
  @override
  _AgreementPageState createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }
  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 150),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(children: [
              Container(color: PS.secondaryColor, width: 3, height: 20,),
              SizedBox(width: 20,),
              Text("个人信息保护提示", style: TextStyle(fontSize: 23, fontWeight: FontWeight.w400),)
            ],),
            Container(
              padding: EdgeInsets.all(PS.marginLarge),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10,),
                  Text("感谢使用姨妈宝APP！", style: PS.normalTextStyle(),),
                  SizedBox(height: 25,),
                  Text("我们非常重视您的个人信息和隐私保护，为了更好的保障您的个人权益。在使用我们的产品之前，请您务必审慎阅读、充分理解《用户协议》《隐私政策》各条款，我们会按照上述协议收集、使用您的个人信息。", style: PS.normalTextStyle(),),
                  SizedBox(height: 10,),
                  RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                        style: PS.normalTextStyle(),
                      children: [
                        TextSpan(text: "您可以查看"),
                        TextSpan(text: "《用户协议》", style: PS.normalTextStyle(color: PS.secondaryColor), recognizer: TapGestureRecognizer()..onTap = () async {
                          SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
                          await Navigator.push(context, MaterialPageRoute(builder: (_) {
                            return AgreementH5Page(index: 0,);
                          }));
                          SystemChrome.setEnabledSystemUIOverlays([]);
                        }),
                        TextSpan(text: "《隐私政策》", style: PS.normalTextStyle(color: PS.secondaryColor), recognizer: TapGestureRecognizer()..onTap = () async {
                          SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
                          await Navigator.push(context, MaterialPageRoute(builder: (_) {
                            return AgreementH5Page(index: 1,);
                          }));
                          SystemChrome.setEnabledSystemUIOverlays([]);
                        }),
                      ]
                    ),
                  ),
                  Text("如您同意上述协议，请点击“同意”并开始接受我们的服务。", style: PS.normalTextStyle(),),
                  SizedBox(height: 20,),
                  Text("为了更好的提供服务，我们将在您同意《隐私政策》后，正常使用应用时申请获取以下权限：", style: PS.normalTextStyle(),),
                  Text("“读取手机信息”：获取设备的信息，包含ip、设备型号等。", style: PS.normalTextStyle(),),
                  Text("“存储与读取”；存放并使用本应用产生的数据。", style: PS.normalTextStyle(),),
                  // Text("“网络数据”；提供应用服务。", style: PS.normalTextStyle(),),

                ],
              ),
            ),
            // SizedBox(height: 100,),
            Expanded(child: Container()),
            Container(
                padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
                width: double.infinity,
                height: 85,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(PS.secondaryColor),
                        elevation: MaterialStateProperty.all(0),
                        shape: MaterialStateProperty.all(
                            StadiumBorder(
                                side: BorderSide(
                                  //设置 界面效果
                                  style: BorderStyle.solid,
                                  color: PS.secondaryColor,
                                )
                            )
                        ),//圆角弧度
                    ),
                    onPressed: () async {
                      registerWxApi(appId: "wxfa505eddadc31630",universalLink: "https://www.yimabao.cn/apple-app-site-association");
                      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      sharedPreferences.setBool(ProjectConfig.agreementKey, true);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
                        return MainPage(isShowCircleDialog: true,);
                        // return LoadingPage(isIgnoreUnionad: true);
                      }));
                    },
                    child: Text("同意并继续使用")
                )
            ),
            Offstage(
              offstage: Platform.isIOS,
              child: GestureDetector(
                  onTap: (){
                    SystemNavigator.pop();
                  },
                  child: Text("不同意并退出",)
              ),
            ),
            SizedBox(height: 150,)
          ],
        ),
      ),
    );
  }
}

