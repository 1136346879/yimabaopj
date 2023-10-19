import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimabao/api/db_api.dart';
import 'package:yimabao/config/project_config.dart';
import 'package:yimabao/db/entities/local_record.dart';
import 'package:yimabao/db/entities/member_record.dart';
import 'package:yimabao/entities/cycle_entity.dart';
import 'package:yimabao/entities/is_login_entity.dart';
import 'package:yimabao/entities/login_entity.dart';
import 'package:yimabao/entities/login_sync_entity.dart';
import 'package:yimabao/entities/tag_sync_entity.dart';
import 'package:yimabao/entities/version_entity.dart';
import 'package:yimabao/request/mark_api.dart';
import 'package:yimabao/utils/dialog.dart';
import 'package:yimabao/utils/toast_util.dart';

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
  final VERSIONINFO = "/deploy/appver";
  Future<VersionEntity> versionInfo(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    // var personId = userinfo.personId;
    VersionEntity entity = await HttpManager.instance.request<VersionEntity>(Method.GET, VERSIONINFO, params: params, buildContext: buildContext, contentType: HttpContentType.form);
    return entity;
  }

  // 登录
  final LOGIN = "/wechat/login";
  Future<LoginEntity> login(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    LoginEntity entity = await HttpManager.instance.request<LoginEntity>(Method.GET, LOGIN, params: params, buildContext: buildContext, contentType: HttpContentType.form);
    return entity;
  }
  // 登录验证
  final ISLOGIN = "/wechat/is-login";
  Future<IsLoginEntity> isLogin(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    IsLoginEntity entity = await HttpManager.instance.request<IsLoginEntity>(Method.GET, ISLOGIN, params: params, buildContext: buildContext, contentType: HttpContentType.form);
    return entity;
  }
  // 退出登录
  final LOGOUT = "/wechat/logout";
  Future<LoginEntity> logout(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    LoginEntity entity = await HttpManager.instance.request<LoginEntity>(Method.GET, LOGOUT, params: params, buildContext: buildContext, contentType: HttpContentType.form);
    return entity;
  }
  // 清除用户数据
  final CLEAR = "/data-sync/del-all-period";
  Future<LoginEntity> clear(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    LoginEntity entity = await HttpManager.instance.request<LoginEntity>(Method.POST, CLEAR, params: params, buildContext: buildContext, contentType: HttpContentType.json);
    return entity;
  }
  // 同步设置经期非经期接口
  final PERIODSETSYNC = "/data-sync/period-set-sync";
  Future<CycleEntity> periodSetSync(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    CycleEntity entity = await HttpManager.instance.request<CycleEntity>(Method.POST, PERIODSETSYNC, params: params, buildContext: buildContext, contentType: HttpContentType.json);
    return entity;
  }
  // 登录同步标记数据接口
  final PERIODSYNCFORLOGIN = "/data-sync/period-sync-for-login";
  Future<LoginSyncEntity> periodSyncForLogin(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    //
    LoginSyncEntity entity = await HttpManager.instance.request<LoginSyncEntity>(Method.POST, PERIODSYNCFORLOGIN, params: params, buildContext: buildContext, contentType: HttpContentType.json);
    return entity;
  }
  // 除登录外其他情况下触发的同步经期非经期信息接口
  final PERIODSYNC = "/data-sync/period-sync";
  Future<TagSyncEntity> periodSync(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    //
    TagSyncEntity entity = await HttpManager.instance.request<TagSyncEntity>(Method.POST, PERIODSYNC, params: params, buildContext: buildContext, contentType: HttpContentType.json);
    return entity;
  }

  // 同步删除经期非经期数据接口
  final PERIODDELSYNC = "/data-sync/period-del-sync";
  Future<LoginEntity> periodDelSync(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    //
    LoginEntity entity = await HttpManager.instance.request<LoginEntity>(Method.POST, PERIODDELSYNC, params: params, buildContext: buildContext, contentType: HttpContentType.json);
    return entity;
  }

  // 注销账号
  final DESTROY = "/destroy";
  Future<LoginEntity> destroy(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    LoginEntity entity = await HttpManager.instance.request<LoginEntity>(Method.GET, DESTROY, params: params, buildContext: buildContext, contentType: HttpContentType.json);
    return entity;
  }

 _recordToMap(record) {
    if(record == null) return null;
    return {
      "markAt": record.markAt,
      "createAt": record.createAt,
      "type": record.type
    };
 }
  _recordToMapWithId(record) {
    if(record == null) return null;
    return {
      "markAt": record.markAt,
      "createAt": record.createAt,
      "type": record.type,
      "id": record.id
    };
  }
 getUUID() async {
    // return "36a6a32e32ce65de";
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
   return uuid;
 }
 //登录校验 如果没登录则返回true
  checkLogin() async{
    var account = getAccount();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String lastUserId = sharedPreferences.getString("LASTUSERID") ?? '';
    String userId = account?.user_id ?? lastUserId;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      if(userId != '') {
        IsLoginEntity res =  await isLogin({"uuid": await getUUID(), "user_id": userId,});
        var result = res.data.isLogin ?? false;
        if(!result) {
          //删本地数据
          await DBAPI.sharedInstance.memberRecordDao.deleteAll();
          await DBAPI.sharedInstance.markDao.deleteAllMemberMarks();
          //删除本地登录缓存
          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          sharedPreferences.remove("LASTUSERID");
          await clearAccount();
        }
        return res.data.isLogin ?? false;
      }
    }
    return true;
  }
 //同步周期数据方法
 memberSyncCircle() async{
    var isCheck = await checkLogin();
    if(!isCheck) return;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      var account = getAccount();
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      var isNeedSync = sharedPreferences.getInt(ProjectConfig.cycleNeedSyncKey);
      if(account != null) {
        if(isNeedSync == null) {
          CycleEntity entity = await periodSetSync({"user_id": getAccount()?.user_id,
            "uuid": await getUUID(),
            "periodDays": null,
            "nonPeriodDays": null,
            "createAt": null,
          });
          sharedPreferences.setInt(ProjectConfig.doingKey, entity?.data?.periodDays ?? 7);
          sharedPreferences.setInt(ProjectConfig.cycleKey, entity?.data?.nonPeriodDays ?? 28);
          return;
        } else {
          var doingVal = sharedPreferences.getInt(ProjectConfig.doingKey) ?? 7;
          var cycleVal = sharedPreferences.getInt(ProjectConfig.cycleKey) ?? 28;
          CycleEntity entity = await periodSetSync({"user_id": getAccount()?.user_id,
            "uuid": await getUUID(),
            "periodDays": doingVal,
            "nonPeriodDays": cycleVal,
            "createAt": isNeedSync,
          });
          sharedPreferences.setInt(ProjectConfig.doingKey, entity?.data?.periodDays ?? 7);
          sharedPreferences.setInt(ProjectConfig.cycleKey, entity?.data?.nonPeriodDays ?? 28);
          sharedPreferences.remove(ProjectConfig.cycleNeedSyncKey);
        }
      }
    } else {

    }
    //
  }
  //会员登录同步数据 能登录成功代表有网状态 先提交数据  无冲突则清空脏数据表并写本地会员表 有冲突则保留脏数据表， 写入会员表
  memberLoginSyncData({BuildContext? buildContext}) async {
      //获取脏数据表数据
    List<LocalRecord>? _dataSource = await DBAPI.sharedInstance.localRecordDao.findAllRecords();
    //过滤掉删除操作
    List<LocalRecord> _filterData = _dataSource.where((element) => element.isDeleted == 0).toList();
    //同步数据
    var jsonArr = _filterData.map((e) => _recordToMap(e)).toList();
    var account = getAccount();
    var params = {
      "user_id": account?.user_id,
      "data": jsonArr,
      "uuid": await getUUID()
    };
    LoginSyncEntity entity =  await periodSyncForLogin(params, buildContext: buildContext);
    bool isRmLocData = entity.data.isRmLocData;
    List<LoginSyncDataData> serverData = entity.data.data;
    //接口返回数据写入本地会员表
    var userId = account?.user_id ?? "";
    var memberData = serverData.map((e) => MemberRecord(null, e.markAt, e.createAt, e.type, userId, isMerged: 1)).toList();
    await DBAPI.sharedInstance.memberRecordDao.batchInsertRecords(memberData);
    if(isRmLocData) {
      //清空脏数据表
      await DBAPI.sharedInstance.localRecordDao.deleteAll();
      //同步野数据
      await MarkAPI.instance.markLoginSyncData(buildContext: buildContext);
      //清空本地野数据
      await DBAPI.sharedInstance.markDao.deleteAllLocalMarks();
    }

    //测试
    // MyDialog.showAlertDialog(buildContext!, () { }, title: "调试提示", message: "服务器isRmLocData字段为${isRmLocData ? 'true. 会删除野数据' : 'false. 会保留野数据'}");
  }
  //返回未同步代表删除的后2条数据（只允许操作4天内的 2条够了）
  _findMemberNeedSyncDeleteRecord() async {
    List<MemberRecord>? needDel = await DBAPI.sharedInstance.memberRecordDao.findFirstDelRecord();
    return needDel ?? [];
  }
  //会员同步数据 1， 检查网络 2，有网 先提交数据  有操作则写本地会员表， 调接口 清空本地并写入 2， 无网 写本地
  memberSyncData({BuildContext? buildContext}) async {
    // var account = getAccount();
    // if(account == null) return;
    var isCheck = await checkLogin();
    if(!isCheck) return;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      //获取本地会员数据（没有merged的）
      List<MemberRecord>? _dataSource = await DBAPI.sharedInstance.memberRecordDao.findAllRecordsContainLogout();
      if(_dataSource.length == 0) return;//如果无数据return
      //判断第一条是不是删除数据
      List<MemberRecord> delItemArr = await _findMemberNeedSyncDeleteRecord();
      if(delItemArr.length > 0 && delItemArr.first.isDeleted != 0) {
        for(int i = 0; i < delItemArr.length; i++) {
          var delI = delItemArr[i];
          //调删除接口
          await periodDelSync({"user_id": delI.memberID, "markAt": delI.markAt, "type": delI.type, "createAt": delI.createAt, "uuid": await getUUID()});
        }
        // //调删除接口
        // await periodDelSync({"user_id": delItemArr.first.memberID, "markAt": delItemArr.first.markAt, "type": delItemArr.first.type, "createAt": delItemArr.first.createAt, "uuid": await getUUID()});
      }
      //需要同步的数据
      List<MemberRecord> _filterData = _dataSource.where((element) => element.isDeleted == 0 && element.isLogout == 0).toList();
      //同步数据
      List<TagSyncData>? serverData;
      var unmergeItems = _dataSource.where((element) => element.isDeleted == 0 && element.isLogout == 0 && element.isMerged == 0).toList();
      if(unmergeItems.length > 0) {
        var jsonArr = _filterData.map((e) => _recordToMap(e)).toList();
        var params = {
          "user_id": _dataSource.first.memberID,
          "data": jsonArr,
          "uuid": await getUUID()
        };
        TagSyncEntity entity =  await periodSync(params, buildContext: buildContext);
        serverData = entity.data;
      }


      //判断最后一条是不是退出登录
      // MemberRecord lastItem = _dataSource.last;
      MemberRecord? lastItem = await DBAPI.sharedInstance.memberRecordDao.findLastOne();
      if((lastItem?.isLogout ?? 0) != 0) {
        String memberID = lastItem!.memberID;
        //退出接口
        await logout({ "uuid": await getUUID(), "user_id": memberID});
        //清空本地会员表数据
        await DBAPI.sharedInstance.memberRecordDao.deleteAll();
      } else {
        if(serverData == null) return;
        //接口返回数据写入本地会员表
        await DBAPI.sharedInstance.memberRecordDao.deleteAll();
        var userId = getAccount()?.user_id ?? "";
        var memberData = serverData.map((e) => MemberRecord(null, e.markAt, e.createAt, int.parse(e.type), userId, isMerged: 1)).toList();
        await DBAPI.sharedInstance.memberRecordDao.batchInsertRecords(memberData);
        //判断最后一条是不是删除， 并比较时间戳， 如果是时间最新一条的话追加上去
        // var memberLastRecord = await DBAPI.sharedInstance.memberRecordDao.findLastRecord();
        // if((lastItem?.isDeleted ?? 0) != 0 && memberLastRecord != null && int.parse(lastItem!.createAt) > int.parse(memberLastRecord.createAt)) {
        //   lastItem.id = null;
        //   await DBAPI.sharedInstance.memberRecordDao.insertRecord(lastItem);
        // }
      }
    } else {
      //无网不做处理
    }
  }
  //会员退出登录  有网 同步数据 清会员表， 显示脏数据表 无网 写入退出操作到会员表，切换显示脏数据表
  memberLogout(BuildContext buildContext) async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      //同步数据
      await memberSyncData(buildContext: buildContext);
      //同步新标记数据
      await MarkAPI.instance.markSyncData();
      //调退出登录接口
      await logout({ "uuid": await getUUID(), "user_id": getAccount()?.user_id}, buildContext: buildContext);
      //清空本地会员表数据
      await DBAPI.sharedInstance.memberRecordDao.deleteAll();
      //清除新标记
      await DBAPI.sharedInstance.markDao.deleteAllMemberMarks();
    } else {
      //无网会员表写入一条退出登录记录， 等待下次同步时（memberSyncData）处理
      await DBAPI.sharedInstance.memberRecordDao.insertRecord(MemberRecord(null, "0", "0", 0, getAccount()?.user_id ?? '', isLogout: 1));
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("LASTUSERID", getAccount()?.user_id ?? '');
    await clearAccount();
  }
  //插入标记数据， 姨妈来了 姨妈走了
  insertRecord(record, {BuildContext? buildContext}) async {
    var account = this.getAccount();
    if(account != null) {
      //登录状态 插入会员表
      MemberRecord memberRecord = MemberRecord(
        null,
        record.markAt,
        record.createAt,
        record.type,
        account.user_id!,
        // isLogout: record.isLogout ?? 0
      );
      await DBAPI.sharedInstance.memberRecordDao.insertRecord(memberRecord);
      //同步数据
      await memberSyncData(buildContext: buildContext);

    } else {
      LocalRecord localRecord = LocalRecord(
          null,
          record.markAt,
          record.createAt,
          record.type,
      );
      //插入脏数据表
      await DBAPI.sharedInstance.localRecordDao.insertRecord(localRecord);
    }
  }
  //新版的删除记录
  newDeleteRecord({required BuildContext buildContext, required int id}) async {
    var account = this.getAccount();
    if(account != null) {
      //登录状态 删除会员表
      MemberRecord? delItem = await DBAPI.sharedInstance.memberRecordDao.findRecordById(id);
      if(delItem != null) {
        if(delItem.isMerged == 0) {//没merge 直接删
          await DBAPI.sharedInstance.memberRecordDao.deleteById(id);
        } else {
          delItem.isDeleted = 1;
          await DBAPI.sharedInstance.memberRecordDao.updateRecord(delItem);
          //判断该记录是否merged， 如果merged过需要调接口
          var connectivityResult = await (Connectivity().checkConnectivity());
          var isConnected = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
          if( isConnected) {
            //删远程
            await periodDelSync({"user_id": getAccount()?.user_id!, "markAt": delItem.markAt, "type": delItem.type, "createAt": delItem.createAt, "uuid": await getUUID()});
            //再同步
            // await memberSyncData(buildContext: buildContext);
          }
        }
      }
    } else {
      //脏数据表 直接删
      await DBAPI.sharedInstance.localRecordDao.deleteById(id);
    }
  }
  //删除最后一条数据
  deleteLastRecord(BuildContext buildContext) async {
    var account = this.getAccount();
    if(account != null) {
      //登录状态 删除会员表
      List<MemberRecord>? _dataSource = await DBAPI.sharedInstance.memberRecordDao.findAllRecordsContainDeleted();
      //是否允许删除逻辑
      if (_dataSource.length > 0) {
        MemberRecord record = _dataSource.last;
        var recordOperationDateTime = DateUtil.getDateTimeByMs(int.parse(record.markAt));
        if(ProjectConfig.now.difference(recordOperationDateTime).inDays > 3 || record.isDeleted == 1) {
          MyDialog.showAlertDialog(buildContext, () {
          }, title: "没有可以删除的记录", message: "仅支持删除四天内的最后一条数据哦", isOnlySureBtn: true, sureBtnTitle: "好", sureBtnTitleColor: Colors.blue);
        } else {
          // await MyDialog.showAlertDialog(buildContext, () async {
            record.isDeleted = 1;
            await DBAPI.sharedInstance.memberRecordDao.updateRecord(record);
            //判断该记录是否merged， 如果merged过需要调接口
            var connectivityResult = await (Connectivity().checkConnectivity());
            var isConnected = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
            if(record.isMerged != 0 && isConnected) {
              //删远程
              await periodDelSync({"user_id": getAccount()?.user_id!, "markAt": record.markAt, "type": record.type, "createAt": record.createAt, "uuid": await getUUID()});
              //删本地
              // await DBAPI.sharedInstance.memberRecordDao.deleteById(record.id!);
              //再同步
              await memberSyncData(buildContext: buildContext);
            }
            showToast("删除记录成功");
          // }, title: "删除记录？",
          //     message: "${DateUtil.formatDateMs(int.parse(record.markAt),format: "yyyy年MM月dd日")}：${record.type == 1 ? "姨妈开始" : "姨妈结束"}",
          //     sureBtnTitle: "删除",
          //     sureBtnTitleColor: Colors.red,
          //     cancelBtnTitleColor: Colors.blue
          // );
        }
      } else {
        MyDialog.showAlertDialog(buildContext, () {}, title: "没有可以删除的记录", message: "仅支持删除四天内的最后一条数据哦", isOnlySureBtn: true, sureBtnTitle: "好", sureBtnTitleColor: Colors.blue);
      }
      // await DBAPI.sharedInstance.memberRecordDao.insertRecord(memberRecord);
      //同步数据
      // await memberSyncData(buildContext: buildContext);

    } else {
      //脏数据表
      List<LocalRecord>? _dataSource = await DBAPI.sharedInstance.localRecordDao.findAllRecordsContainDeleted();
      if (_dataSource.length > 0) {
        LocalRecord record = _dataSource.last;
        var recordOperationDateTime = DateUtil.getDateTimeByMs(int.parse(record.markAt));
        if(ProjectConfig.now.difference(recordOperationDateTime!).inDays > 3 || record.isDeleted == 1) {
          MyDialog.showAlertDialog(buildContext, () {
            // Navigator.of(context).pop();
          }, title: "没有可以删除的记录", message: "仅支持删除四天内的最后一条数据哦", isOnlySureBtn: true, sureBtnTitle: "好", sureBtnTitleColor: Colors.blue);
        } else {
          // MyDialog.showAlertDialog(buildContext, () async {
            record.isDeleted = 1;
            await DBAPI.sharedInstance.localRecordDao.updateRecord(record);
            showToast("删除记录成功");
            // Navigator.of(context).pop();
          // }, title: "删除记录？",
          //     message: "${DateUtil.formatDateMs(int.parse(record.markAt),format: "yyyy年MM月dd日")}：${record.type == 1 ? "姨妈开始" : "姨妈结束"}",
          //     sureBtnTitle: "删除",
          //     sureBtnTitleColor: Colors.red,
          //     cancelBtnTitleColor: Colors.blue
          // );
        }
      } else {
        MyDialog.showAlertDialog(buildContext, () {}, title: "没有可以删除的记录", message: "仅支持删除四天内的最后一条数据哦", isOnlySureBtn: true, sureBtnTitle: "好", sureBtnTitleColor: Colors.blue);
      }

    }
  }

  getAllRecord() async {
    var account = this.getAccount();
    if(account != null) {
      List<MemberRecord>? _dataSource = await DBAPI.sharedInstance.memberRecordDao.findAllRecords();
      return _dataSource.map((e) => _recordToMap(e)).toList();
    } else {
      List<LocalRecord>? _dataSource = await DBAPI.sharedInstance.localRecordDao.findAllRecords();
      return _dataSource.map((e) => _recordToMap(e)).toList();
    }
  }
  getLastRecord() async {
    var account = this.getAccount();
    if(account != null) {
      MemberRecord? last = await DBAPI.sharedInstance.memberRecordDao.findLastRecord();
      return _recordToMapWithId(last);
    } else {
      LocalRecord? last = await DBAPI.sharedInstance.localRecordDao.findLastRecord();
      return _recordToMapWithId(last);
    }

  }

  final _ACCOUNT_KEY = "ACCOUNT_KEY";
  setAccount(LoginData userInfoData) async {
    await prefs?.setString(_ACCOUNT_KEY, json.encode(userInfoData));
  }

  LoginData? getAccount() {
    var dataStr = prefs?.getString(_ACCOUNT_KEY);
    if (dataStr == null) {
      return null;
    }
    var map = json.decode(dataStr);
    LoginData userInfoData = LoginData().fromJson(map);
    return userInfoData;
  }

  clearAccount() async {
    await prefs?.remove(_ACCOUNT_KEY);
  }



//
//  Future<VersionEntity> downloadAPK(Map<String, dynamic> params,  {BuildContext buildContext}) async {
//    VersionEntity entity = await HttpManager.instance.downloadFile(urlPath, savePath, progressCallback: );
//    return entity;
//  }

}