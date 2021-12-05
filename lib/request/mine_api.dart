import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimareport/entities/version_entity.dart';

import 'http_manager.dart';

class MineAPI {
  factory MineAPI() => _getInstance();
  static MineAPI get instance => _getInstance();
  static MineAPI? _instance;
  MineAPI._internal();
  static MineAPI _getInstance() {
    if (_instance == null) {
      _instance = new MineAPI._internal();
      SharedPreferences.getInstance().then((value) => prefs = value);
    }
    return _instance!;
  }
  static SharedPreferences? prefs;

  // //获取版本信息
  final VERSIONINFO = "/version/update";
  Future<VersionEntity> versionInfo(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    // var personId = userinfo.personId;
    VersionEntity entity = await HttpManager.instance.request<VersionEntity>(Method.POST, VERSIONINFO, params: params, buildContext: buildContext);
    return entity;
  }

  /*
  //发送验证码
  final SENDVALIDCODE = "/app/user/sendValidCode";
  Future<BaseEntity> sendValidCode(Map<String, dynamic> params,{BuildContext buildContext}) async {
    // BaseEntity fakeEntity =  JsonConvert.fromJsonAsT(userinfo);
    // return fakeEntity;
    BaseEntity entity = await HttpManager.instance.request<BaseEntity>(Method.POST, SENDVALIDCODE, params: params,buildContext: buildContext);
    return entity;
  }


  //发送人员认证验证码
  final SENDAUTHENTICATIONVALIDCODE = "/app/user/sendAuthenticationValidCode";
  Future<BaseEntity> sendAuthenticationValidCode(Map<String, dynamic> params,{BuildContext buildContext}) async {
    // BaseEntity fakeEntity =  JsonConvert.fromJsonAsT(userinfo);
    // return fakeEntity;
    BaseEntity entity = await HttpManager.instance.request<BaseEntity>(Method.POST, SENDAUTHENTICATIONVALIDCODE, params: params,buildContext: buildContext);
    return entity;
  }

  //修改头像
  final UPDATEHEADIM = "/app/user/updateHeadImg";
  Future<Map<String, dynamic>> updateHeadImg(String filePath,{BuildContext context,ProgressCallback onSendProgress, Map<String, dynamic> queryParameters}) async {
    // BaseEntity fakeEntity =  JsonConvert.fromJsonAsT(userinfo);
    // return fakeEntity.toJson();
    Map<String, dynamic> map = await HttpManager.instance.upload(urlPath: UPDATEHEADIM, filePath: filePath, context: context, onSendProgress:onSendProgress, queryParameters: queryParameters);
    return map;
  }

  //修改用户名
  final UPDATEUSERNAME = "/app/user/updateUserName";
  Future<BaseEntity> updateUserName(Map<String, dynamic> params,{BuildContext buildContext}) async {
    BaseEntity entity = await HttpManager.instance.request<BaseEntity>(Method.POST, UPDATEUSERNAME, params: params,buildContext: buildContext);
    return entity;
  }
  //上传图片
  final UPLOADIMG = "/app/user/uploadImg";
  Future<Map<String, dynamic>> uploadImg(String filePath,{BuildContext context,ProgressCallback onSendProgress, Map<String, dynamic> queryParameters}) async {
    Map<String, dynamic> map = await HttpManager.instance.upload(urlPath: UPLOADIMG, filePath: filePath, context: context, onSendProgress:onSendProgress, queryParameters: queryParameters);
    return map;
  }
  Future<Map<String, dynamic>> uploadData(List<int> values,{BuildContext context,ProgressCallback onSendProgress, Map<String, dynamic> queryParameters}) async {
    Map<String, dynamic> map = await HttpManager.instance.uploadData(urlPath: UPLOADIMG, values: values, context: context, onSendProgress:onSendProgress, queryParameters: queryParameters);
    return map;
  }
  //人员认证
  final USERAUTHENTICATION = "/app/user/userAuthentication";
  Future<BaseEntity> userAuthentication(Map<String, dynamic> params,{BuildContext buildContext}) async {
    BaseEntity entity = await HttpManager.instance.request<BaseEntity>(Method.POST, USERAUTHENTICATION, params: params,buildContext: buildContext, contentType: HttpContentType.json);
    return entity;
  }
  //退出登陆
  final LOGOUT = "/app/user/logout";
  Future<BaseEntity> logout(Map<String, dynamic> params,{BuildContext buildContext}) async {
    BaseEntity entity = await HttpManager.instance.request<BaseEntity>(Method.POST, LOGOUT, params: params,buildContext: buildContext);
    return entity;
  }

  //手机号和验证码是否符合
  final CHECKVALIDCODE = "/app/user/checkValidCode";
  Future<LoginEntity> checkValidCode(Map<String, dynamic> params,{BuildContext buildContext}) async {
    // BaseEntity fakeEntity =  JsonConvert.fromJsonAsT(userinfo);
    // return fakeEntity;
    LoginEntity entity = await HttpManager.instance.request<LoginEntity>(Method.POST, CHECKVALIDCODE, params: params,buildContext: buildContext);
    return entity;
  }


  //添加成员
  final ADDUSER = "/app/user/addMember";
  Future<LoginEntity> addMember(Map<String, dynamic> params,{BuildContext buildContext}) async {
    LoginEntity entity = await HttpManager.instance.request<LoginEntity>(Method.POST, ADDUSER, params: params,buildContext: buildContext, contentType: HttpContentType.json);
    return entity;
  }

  //移除成员
  final DELETEMEMBER = "/app/user/deleteMember";
  Future<LoginEntity> deleteMember(Map<String, dynamic> params,{BuildContext buildContext}) async {
    LoginEntity entity = await HttpManager.instance.request<LoginEntity>(Method.POST, DELETEMEMBER, params: params,buildContext: buildContext);
    return entity;
  }

  //移除成员2
  final DELETEREL = "/app/user/deleteRel";
  Future<LoginEntity> deleteRel(Map<String, dynamic> params,{BuildContext buildContext}) async {
    LoginEntity entity = await HttpManager.instance.request<LoginEntity>(Method.POST, DELETEREL, params: params,buildContext: buildContext);
    return entity;
  }

  //家属认证申请时租客列表接口
  final ROOMLIVEUSERLIST = "/app/user/roomLiveUserList";
  Future<RoomLiveUserEntity> roomLiveUserList(Map<String, dynamic> params,{BuildContext buildContext}) async {
    RoomLiveUserEntity entity = await HttpManager.instance.request<RoomLiveUserEntity>(Method.POST, ROOMLIVEUSERLIST, params: params,buildContext: buildContext);
    return entity;
  }

  //业主审核认证成员
  final AUDITMEMBER = "/app/user/auditMember";
  Future<RoomLiveUserEntity> auditMember(Map<String, dynamic> params,{BuildContext buildContext}) async {
    RoomLiveUserEntity entity = await HttpManager.instance.request<RoomLiveUserEntity>(Method.POST, AUDITMEMBER, params: params,buildContext: buildContext);
    return entity;
  }

  //业主驳回认证成员
  final REJECTMEMBER = "/app/user/rejectMember";
  Future<RoomLiveUserEntity> rejectMember(Map<String, dynamic> params,{BuildContext buildContext}) async {
    RoomLiveUserEntity entity = await HttpManager.instance.request<RoomLiveUserEntity>(Method.POST, REJECTMEMBER, params: params,buildContext: buildContext);
    return entity;
  }

  //成员数据信息
  final CHILDUSERINFO = "/app/user/childUserInfo";
  Future<ChildUserInfoEntity> childUserInfo(Map<String, dynamic> params,{BuildContext buildContext}) async {
    ChildUserInfoEntity entity = await HttpManager.instance.request<ChildUserInfoEntity>(Method.POST, CHILDUSERINFO, params: params,buildContext: buildContext);
    return entity;
  }

  //获取版本号
  final GETAPPLATESTVERSION = "/app/user/getAppLatestVersion";
  Future<VersionEntity> getAppLatestVersion(Map<String, dynamic> params,{BuildContext buildContext}) async {
    VersionEntity entity = await HttpManager.instance.request<VersionEntity>(Method.POST, GETAPPLATESTVERSION, params: params,buildContext: buildContext);
    return entity;
  }

  //物业通知未读数
  final NOREADNOTICECOUNT = "/app/manager/noReadNoticeCount";
  Future<BaseEntity> noReadNoticeCount(Map<String, dynamic> params,{BuildContext buildContext}) async {
    BaseEntity entity = await HttpManager.instance.request<BaseEntity>(Method.POST, NOREADNOTICECOUNT, params: params,buildContext: buildContext);
    return entity;
  }

  //未阅读智能提醒数量
  final NOREADREMINDCOUNT = "/app/manager/noReadRemindCount";
  Future<BaseEntity> noReadRemindCount(Map<String, dynamic> params,{BuildContext buildContext}) async {
    BaseEntity entity = await HttpManager.instance.request<BaseEntity>(Method.POST, NOREADREMINDCOUNT, params: params,buildContext: buildContext);
    return entity;
  }

  //物业通知改为已读
  final READNOTICE = "/app/manager/readNotice";
  Future<ChildUserInfoEntity> readNotice(Map<String, dynamic> params,{BuildContext buildContext}) async {
    ChildUserInfoEntity entity = await HttpManager.instance.request<ChildUserInfoEntity>(Method.POST, READNOTICE, params: params,buildContext: buildContext);
    return entity;
  }

  //智能提醒已读
  final READREMIND = "/app/manager/readRemind";
  Future<ChildUserInfoEntity> readRemind(Map<String, dynamic> params,{BuildContext buildContext}) async {
    ChildUserInfoEntity entity = await HttpManager.instance.request<ChildUserInfoEntity>(Method.POST, READREMIND, params: params,buildContext: buildContext);
    return entity;
  }

  //物业通知列表
  final NOTICELIST = "/app/manager/noticeList";
  Future<MessageNoticeEntity> noticeList(Map<String, dynamic> params,{BuildContext buildContext, bool isIgnoreErrMsg = false}) async {
    MessageNoticeEntity entity = await HttpManager.instance.request<MessageNoticeEntity>(Method.POST, NOTICELIST, params: params,buildContext: buildContext, isIgnoreErrMsg: isIgnoreErrMsg);
    return entity;
  }

  //智能提醒
  final REMINDLIST = "/app/manager/remindList";
  Future<MessageNoticeEntity> remindList(Map<String, dynamic> params,{BuildContext buildContext, bool isIgnoreErrMsg = false}) async {
    MessageNoticeEntity entity = await HttpManager.instance.request<MessageNoticeEntity>(Method.POST, REMINDLIST, params: params,buildContext: buildContext, isIgnoreErrMsg: isIgnoreErrMsg);
    return entity;
  }

  //一键已读
  final READALLDATA = "/app/manager/readAllData";
  Future<MessageNoticeEntity> readAllData(Map<String, dynamic> params,{BuildContext buildContext}) async {
    MessageNoticeEntity entity = await HttpManager.instance.request<MessageNoticeEntity>(Method.POST, READALLDATA, params: params,buildContext: buildContext);
    return entity;
  }

  //缴费通知列表
  final PAYMENTLIST = "/app/manager/paymentList";
  Future<MessageNoticeEntity> paymentList(Map<String, dynamic> params,{BuildContext buildContext, bool isIgnoreErrMsg = false}) async {
    MessageNoticeEntity entity = await HttpManager.instance.request<MessageNoticeEntity>(Method.POST, PAYMENTLIST, params: params,buildContext: buildContext, isIgnoreErrMsg: isIgnoreErrMsg);
    return entity;
  }

  //缴费通知已读
  final READPAYMENT = "/app/manager/readPayment";
  Future<ChildUserInfoEntity> readPayment(Map<String, dynamic> params,{BuildContext buildContext}) async {
    ChildUserInfoEntity entity = await HttpManager.instance.request<ChildUserInfoEntity>(Method.POST, READPAYMENT, params: params,buildContext: buildContext);
    return entity;
  }

  //未阅读缴费通知数量
  final NOREADPAYMENTCOUNT = "/app/manager/noReadPaymentCount";
  Future<BaseEntity> noReadPaymentCount(Map<String, dynamic> params,{BuildContext buildContext}) async {
    BaseEntity entity = await HttpManager.instance.request<BaseEntity>(Method.POST, NOREADPAYMENTCOUNT, params: params,buildContext: buildContext);
    return entity;
  }





  final _ACCOUNT_KEY = "ACCOUNT_KEY";
  void setAccount(UserInfoData userInfoData) async {
    await prefs.setString(_ACCOUNT_KEY, json.encode(userInfoData));
  }

  UserInfoData getAccount() {
    var dataStr = prefs.getString(_ACCOUNT_KEY);
    if (dataStr == null) {
      return null;
    }
    var map = json.decode(dataStr);
    UserInfoData userInfoData = UserInfoData().fromJson(map);
    return userInfoData;
  }

  void clearAccount() async {
    prefs.remove(_ACCOUNT_KEY);
  }
  */


//
//  Future<VersionEntity> downloadAPK(Map<String, dynamic> params,  {BuildContext buildContext}) async {
//    VersionEntity entity = await HttpManager.instance.downloadFile(urlPath, savePath, progressCallback: );
//    return entity;
//  }

}