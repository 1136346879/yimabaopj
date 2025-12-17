import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimabao/api/db_api.dart';
import 'package:yimabao/config/project_config.dart';
import 'package:yimabao/db/entities/local_record.dart';
import 'package:yimabao/db/entities/mark.dart';
import 'package:yimabao/db/entities/member_record.dart';
import 'package:yimabao/entities/cycle_entity.dart';
import 'package:yimabao/entities/login_entity.dart';
import 'package:yimabao/entities/login_sync_entity.dart';
import 'package:yimabao/entities/mark_sync_entity.dart';
import 'package:yimabao/entities/tag_sync_entity.dart';
import 'package:yimabao/entities/version_entity.dart';
import 'package:yimabao/request/mine_api.dart';
import 'package:yimabao/utils/dialog.dart';
import 'package:yimabao/utils/toast_util.dart';

import 'http_manager.dart';

class MarkAPI {
  factory MarkAPI() => _getInstance();
  static MarkAPI get instance => _getInstance();
  static MarkAPI? _instance;
  MarkAPI._internal();
  static MarkAPI _getInstance() {
    if (_instance == null) {
      _instance = new MarkAPI._internal();
      SharedPreferences.getInstance().then((value) => prefs = value);
    }
    return _instance!;
  }
  static SharedPreferences? prefs;

  // 添加mark
  final ADDMARK = "/mark-sync/add";
  Future<VersionEntity> _addMark(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    VersionEntity entity = await HttpManager.instance.request<VersionEntity>(Method.POST, ADDMARK, params: params, buildContext: buildContext, contentType: HttpContentType.json);
    return entity;
  }

  // 删除mark
  final DELMARK = "/mark-sync/del";
  Future<VersionEntity> delMark(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    VersionEntity entity = await HttpManager.instance.request<VersionEntity>(Method.POST, DELMARK, params: params, buildContext: buildContext, contentType: HttpContentType.json);
    return entity;
  }

  // 下载同步marks
  final LOADMARK = "/mark-sync/load";
  Future<MarkSyncEntity> loadMarks(Map<String, dynamic> params,{BuildContext? buildContext}) async {
    MarkSyncEntity entity = await HttpManager.instance.request<MarkSyncEntity>(Method.POST, LOADMARK, params: params, buildContext: buildContext, contentType: HttpContentType.json);
    return entity;
  }

  // // 同步删除经期非经期数据接口
  // final PERIODDELSYNC = "/data-sync/period-del-sync";
  // Future<LoginEntity> periodDelSync(Map<String, dynamic> params,{BuildContext? buildContext}) async {
  //   //
  //   LoginEntity entity = await HttpManager.instance.request<LoginEntity>(Method.POST, PERIODDELSYNC, params: params, buildContext: buildContext, contentType: HttpContentType.json);
  //   return entity;
  // }
  //
  _recordToMap(record) {
    if(record == null) return null;
    return {
      "markAt": record.markAt,
      "createAt": record.createAt,
      "type": record.type
    };
  }

  //会员登录同步数据 能登录成功代表有网状态 先提交数据  无冲突则清空脏数据表并写本地会员表 有冲突则保留脏数据表， 写入会员表
  // memberMarkSyncData({BuildContext? buildContext}) async {
  //   //获取脏数据表数据
  //   List<Mark>? _dataSource = await DBAPI.sharedInstance.markDao.findMarks();
  //   //过滤掉删除操作
  //   List<Mark> _filterData = _dataSource.where((element) => element.isDeleted == 0).toList();
  //   //同步数据 TODO
  //   var jsonArr = _filterData.map((e) => _recordToMap(e)).toList();
  //   var account = MineAPI.instance.getAccount();
  //   var params = {
  //     "user_id": account?.user_id,
  //     "data": jsonArr,
  //   };
  //   LoginSyncEntity entity =  await periodSyncForLogin(params, buildContext: buildContext);
  //   bool isRmLocData = entity.data.isRmLocData;
  //   List<LoginSyncDataData> serverData = entity.data.data;
  //   //接口返回数据写入本地会员表
  //   var userId = account?.user_id ?? "";
  //   var memberData = serverData.map((e) => MemberRecord(null, e.markAt, e.createAt, e.type, userId, isMerged: 1)).toList();
  //   await DBAPI.sharedInstance.memberRecordDao.batchInsertRecords(memberData);
  //   if(isRmLocData) {
  //     //清空脏数据表
  //     await DBAPI.sharedInstance.localRecordDao.deleteAll();
  //   }
  //   //测试
  //   // MyDialog.showAlertDialog(buildContext!, () { }, title: "调试提示", message: "服务器isRmLocData字段为${isRmLocData ? 'true. 会删除野数据' : 'false. 会保留野数据'}");
  // }
  // //返回未同步代表删除的第一条数据
  // _findMemberNeedSyncDeleteRecord() async {
  //   List<MemberRecord>? needDel = await DBAPI.sharedInstance.memberRecordDao.findFirstDelRecord();
  //   return needDel ?? [];
  // }
  // //会员同步数据 1， 检查网络 2，有网 先提交数据  有操作则写本地会员表， 调接口 清空本地并写入 2， 无网 写本地
  markSyncData({BuildContext? buildContext, bool isOnlyPush = true}) async {
    bool isCheck = await MineAPI.instance.checkLogin();
    if(!isCheck) return;
    var account = MineAPI.instance.getAccount();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String lastUserId = sharedPreferences.getString("LASTUSERID") ?? '';
    String userId = account?.user_id ?? lastUserId;
    if(userId == '') return;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      //获取本地会员数据（没有merged的）
      List<Mark> _dataSource = await DBAPI.sharedInstance.markDao.findAllMemberMarks();
      // if(_dataSource.length == 0) return;//如果无数据return
      //判断需要删除的数据
      List<Mark> delItemArr = _dataSource.where((element) => element.isDeleted == 1).toList();
      if(delItemArr.length > 0 && delItemArr.first.isDeleted != 0) {
        //调删除接口
        //分类
        List<Mark> loves = delItemArr.where((element) => element.opt == "love").toList();
        List<Mark> weights = delItemArr.where((element) => element.opt == "weight").toList();
        List<Mark> temperaturies = delItemArr.where((element) => element.opt == "temperature").toList();
        List<Mark> diaries = delItemArr.where((element) => element.opt == "diary").toList();
        //新增的3个标签
        List<Mark> sleeps = delItemArr.where((element) => element.opt == "sleep").toList();
        List<Mark> pains = delItemArr.where((element) => element.opt == "period_pain").toList();
        List<Mark> flows = delItemArr.where((element) => element.opt == "period_flow").toList();

        if(loves.length > 0) {
          var delMaps = loves.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "love",
            "data": delMaps
          };
          await delMark(params, buildContext: buildContext);
          await DBAPI.sharedInstance.markDao.deleteMarks(loves);
        }
        if(weights.length > 0) {
          var delMaps = weights.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "weight",
            "data": delMaps
          };
          await delMark(params, buildContext: buildContext);
          await DBAPI.sharedInstance.markDao.deleteMarks(weights);
        }
        if(temperaturies.length > 0) {
          var delMaps = temperaturies.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "temperature",
            "data": delMaps
          };
          await delMark(params, buildContext: buildContext);
          await DBAPI.sharedInstance.markDao.deleteMarks(temperaturies);
        }
        if(diaries.length > 0) {
          var delMaps = diaries.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "diary",
            "data": delMaps
          };
          await delMark(params, buildContext: buildContext);
          await DBAPI.sharedInstance.markDao.deleteMarks(diaries);
        }
        if(sleeps.length > 0) {
          var delMaps = sleeps.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "sleep",
            "data": delMaps
          };
          await delMark(params, buildContext: buildContext);
          await DBAPI.sharedInstance.markDao.deleteMarks(sleeps);
        }
        if(pains.length > 0) {
          var delMaps = pains.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "period_pain",
            "data": delMaps
          };
          await delMark(params, buildContext: buildContext);
          await DBAPI.sharedInstance.markDao.deleteMarks(pains);
        }
        if(flows.length > 0) {
          var delMaps = flows.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "period_flow",
            "data": delMaps
          };
          await delMark(params, buildContext: buildContext);
          await DBAPI.sharedInstance.markDao.deleteMarks(flows);
        }

      }
      //需要同步的数据
      List<Mark> _filterData = _dataSource.where((element) => element.isDeleted == 0 && element.isMerged == 0).toList();
      if(_filterData.length > 0) {
        List<Mark> loves = _filterData.where((element) => element.opt == "love").toList();
        List<Mark> weights = _filterData.where((element) => element.opt == "weight").toList();
        List<Mark> temperaturies = _filterData.where((element) => element.opt == "temperature").toList();
        List<Mark> diaries = _filterData.where((element) => element.opt == "diary").toList();
        //新增的3个标签
        List<Mark> sleeps = _filterData.where((element) => element.opt == "sleep").toList();
        List<Mark> pains = _filterData.where((element) => element.opt == "period_pain").toList();
        List<Mark> flows = _filterData.where((element) => element.opt == "period_flow").toList();

        if(loves.length > 0) {
          var maps = loves.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "love",
            "data": maps
          };
          await _addMark(params, buildContext: buildContext);
          loves.forEach((element) {element.isMerged = 1;});
          await DBAPI.sharedInstance.markDao.updateMarks(loves);
        }
        if(weights.length > 0) {
          var maps = weights.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "weight",
            "data": maps
          };
          await _addMark(params, buildContext: buildContext);
          weights.forEach((element) {element.isMerged = 1;});
          await DBAPI.sharedInstance.markDao.updateMarks(weights);
        }
        if(temperaturies.length > 0) {
          var maps = temperaturies.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "temperature",
            "data": maps
          };
          await _addMark(params, buildContext: buildContext);
          temperaturies.forEach((element) {element.isMerged = 1;});
          await DBAPI.sharedInstance.markDao.updateMarks(temperaturies);
        }
        if(diaries.length > 0) {
          var maps = diaries.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "diary",
            "data": maps
          };
          await _addMark(params, buildContext: buildContext);
          diaries.forEach((element) {element.isMerged = 1;});
          await DBAPI.sharedInstance.markDao.updateMarks(diaries);
        }
        if(sleeps.length > 0) {
          var maps = sleeps.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "sleep",
            "data": maps
          };
          await _addMark(params, buildContext: buildContext);
          sleeps.forEach((element) {element.isMerged = 1;});
          await DBAPI.sharedInstance.markDao.updateMarks(sleeps);
        }
        if(pains.length > 0) {
          var maps = pains.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "period_pain",
            "data": maps
          };
          await _addMark(params, buildContext: buildContext);
          pains.forEach((element) {element.isMerged = 1;});
          await DBAPI.sharedInstance.markDao.updateMarks(pains);
        }
        if(flows.length > 0) {
          var maps = flows.map((e) => e.toMap()).toList();
          var params = {
            "user_id": userId,
            "uuid": await MineAPI.instance.getUUID(),
            "opt": "period_flow",
            "data": maps
          };
          await _addMark(params, buildContext: buildContext);
          flows.forEach((element) {element.isMerged = 1;});
          await DBAPI.sharedInstance.markDao.updateMarks(flows);
        }
      }
      if(isOnlyPush) return;
      var downloadParams = {
        "user_id": userId,
        "opt": "love",
        "uuid": await MineAPI.instance.getUUID(),
      };
      //下载所有标签
      MarkSyncEntity serveLoves = await loadMarks(downloadParams, buildContext: buildContext);
      List<Mark> serveLovesMark = serveLoves.data.map((element) {
        return Mark(null, "love", element.createAt, element.dayAt, hour: element.hour, length: element.length, measure: element.measure, isMerged: 1, isLocal: 0);
      }).toList();
      downloadParams["opt"] = "weight";
      MarkSyncEntity serveWeights = await loadMarks(downloadParams, buildContext: buildContext);
      List<Mark> serveWeightsMark = serveWeights.data.map((element) {
        return Mark(null, "weight", element.createAt, element.dayAt, weight: element.weight, isMerged: 1, isLocal: 0);
      }).toList();
      downloadParams["opt"] = "temperature";
      MarkSyncEntity serveTemperaturies = await loadMarks(downloadParams, buildContext: buildContext);
      List<Mark> serveTemperaturiesMark = serveTemperaturies.data.map((element) {
        return Mark(null, "temperature", element.createAt, element.dayAt, temperature: element.temperature, isMerged: 1, isLocal: 0);
      }).toList();
      downloadParams["opt"] = "diary";
      MarkSyncEntity serveDiaries = await loadMarks(downloadParams, buildContext: buildContext);
      List<Mark> serveDiariesMark = serveDiaries.data.map((element) {
        return Mark(null, "diary", element.createAt, element.dayAt, diary: element.diary, isMerged: 1, isLocal: 0);
      }).toList();
      //新增3个标签
      downloadParams["opt"] = "sleep";
      MarkSyncEntity serveSleeps = await loadMarks(downloadParams, buildContext: buildContext);
      List<Mark> serveSleepsMark = serveSleeps.data.map((element) {
        return Mark(null, "sleep", element.createAt, element.dayAt, length: element.length, isMerged: 1, isLocal: 0);
      }).toList();

      downloadParams["opt"] = "period_pain";
      MarkSyncEntity servePains = await loadMarks(downloadParams, buildContext: buildContext);
      List<Mark> servePainsMark = servePains.data.map((element) {
        return Mark(null, "period_pain", element.createAt, element.dayAt, level: element.level, isMerged: 1, isLocal: 0);
      }).toList();

      downloadParams["opt"] = "period_flow";
      MarkSyncEntity serveflows = await loadMarks(downloadParams, buildContext: buildContext);
      List<Mark> serveFlowsMark = serveflows.data.map((element) {
        return Mark(null, "period_flow", element.createAt, element.dayAt, level: element.level, isMerged: 1, isLocal: 0);
      }).toList();
      //替换数据库
      await DBAPI.sharedInstance.markDao.deleteAllMemberMarks();
      await DBAPI.sharedInstance.markDao.batchInsertMarks(serveLovesMark);
      await DBAPI.sharedInstance.markDao.batchInsertMarks(serveWeightsMark);
      await DBAPI.sharedInstance.markDao.batchInsertMarks(serveTemperaturiesMark);
      await DBAPI.sharedInstance.markDao.batchInsertMarks(serveDiariesMark);

      await DBAPI.sharedInstance.markDao.batchInsertMarks(serveSleepsMark);
      await DBAPI.sharedInstance.markDao.batchInsertMarks(servePainsMark);
      await DBAPI.sharedInstance.markDao.batchInsertMarks(serveFlowsMark);
    } else {
      //无网不做处理
    }
  }
  // //登录同步野数据 1， 检查网络 2，有网 先提交数据  有操作则写本地会员表， 调接口 清空本地并写入 2， 无网 写本地
  markLoginSyncData({BuildContext? buildContext}) async {
    //获取本地野数据
    List<Mark> _dataSource = await DBAPI.sharedInstance.markDao.findAllLocalMarks();
    if(_dataSource.length == 0) return;//如果无数据return
    //需要同步的数据
    List<Mark> _filterData = _dataSource.where((element) => element.isDeleted == 0).toList();
    if(_filterData.length > 0) {
      List<Mark> loves = _filterData.where((element) => element.opt == "love").toList();
      List<Mark> weights = _filterData.where((element) => element.opt == "weight").toList();
      List<Mark> temperaturies = _filterData.where((element) => element.opt == "temperature").toList();
      List<Mark> diaries = _filterData.where((element) => element.opt == "diary").toList();
      //
      List<Mark> sleeps = _filterData.where((element) => element.opt == "sleep").toList();
      List<Mark> pains = _filterData.where((element) => element.opt == "period_pain").toList();
      List<Mark> flows = _filterData.where((element) => element.opt == "period_flow").toList();
      if(loves.length > 0) {
        var maps = loves.map((e) => e.toMap()).toList();
        var params = {
          "user_id": MineAPI.instance.getAccount()?.user_id!,
          "uuid": await MineAPI.instance.getUUID(),
          "opt": "love",
          "data": maps
        };
        await _addMark(params, buildContext: buildContext);
      }
      if(weights.length > 0) {
        var maps = weights.map((e) => e.toMap()).toList();
        var params = {
          "user_id": MineAPI.instance.getAccount()?.user_id!,
          "uuid": await MineAPI.instance.getUUID(),
          "opt": "weight",
          "data": maps
        };
        await _addMark(params, buildContext: buildContext);
      }
      if(temperaturies.length > 0) {
        var maps = temperaturies.map((e) => e.toMap()).toList();
        var params = {
          "user_id": MineAPI.instance.getAccount()?.user_id!,
          "uuid": await MineAPI.instance.getUUID(),
          "opt": "temperature",
          "data": maps
        };
        await _addMark(params, buildContext: buildContext);
      }
      if(diaries.length > 0) {
        var maps = diaries.map((e) => e.toMap()).toList();
        var params = {
          "user_id": MineAPI.instance.getAccount()?.user_id!,
          "uuid": await MineAPI.instance.getUUID(),
          "opt": "diary",
          "data": maps
        };
        await _addMark(params, buildContext: buildContext);
      }
      //新增的3个标签
      if(sleeps.length > 0) {
        var maps = sleeps.map((e) => e.toMap()).toList();
        var params = {
          "user_id": MineAPI.instance.getAccount()?.user_id!,
          "uuid": await MineAPI.instance.getUUID(),
          "opt": "sleep",
          "data": maps
        };
        await _addMark(params, buildContext: buildContext);
      }
      if(pains.length > 0) {
        var maps = pains.map((e) => e.toMap()).toList();
        var params = {
          "user_id": MineAPI.instance.getAccount()?.user_id!,
          "uuid": await MineAPI.instance.getUUID(),
          "opt": "period_pain",
          "data": maps
        };
        await _addMark(params, buildContext: buildContext);
      }
      if(flows.length > 0) {
        var maps = sleeps.map((e) => e.toMap()).toList();
        var params = {
          "user_id": MineAPI.instance.getAccount()?.user_id!,
          "uuid": await MineAPI.instance.getUUID(),
          "opt": "period_flow",
          "data": maps
        };
        await _addMark(params, buildContext: buildContext);
      }
    }
  }
  // //会员退出登录  有网 同步数据 清会员表， 显示脏数据表 无网 写入退出操作到会员表，切换显示脏数据表
  // memberLogout(BuildContext buildContext) async{
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
  //     //同步数据
  //     await memberSyncData(buildContext: buildContext);
  //     //调退出登录接口
  //     await logout({ "uuid": await getUUID(), "user_id": getAccount()?.user_id}, buildContext: buildContext);
  //     //清空本地会员表数据
  //     await DBAPI.sharedInstance.memberRecordDao.deleteAll();
  //   } else {
  //     //无网会员表写入一条退出登录记录， 等待下次同步时（memberSyncData）处理
  //     await DBAPI.sharedInstance.memberRecordDao.insertRecord(MemberRecord(null, "0", "0", 0, getAccount()?.user_id ?? '', isLogout: 1));
  //   }
  //   await clearAccount();
  // }
  //插入标记数据，
  insertMark(Mark markBean, {BuildContext? buildContext}) async {
    var isCheck = await MineAPI.instance.checkLogin();
    if(!isCheck) return;
    var account = MineAPI.instance.getAccount();
    if(account != null) {
      await DBAPI.sharedInstance.markDao.insertMark(markBean..isLocal = 0);
      var connectivityResult = await (Connectivity().checkConnectivity());
      var isConnected = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
      if(isConnected) {
        var params = {
          "user_id": MineAPI.instance.getAccount()?.user_id!,
          "uuid": await MineAPI.instance.getUUID(),
          "data": [markBean.toMap()],
          "opt": markBean.opt
        };
        await _addMark(params, buildContext: buildContext);
        markBean.isMerged = 1;
        await DBAPI.sharedInstance.markDao.updateMark(markBean);
        // //再同步
        // await markSyncData();
      }
    } else {
      await DBAPI.sharedInstance.markDao.insertMark(markBean);
    }
  }
  //更新标记数据，
  updateMark(markBean, {BuildContext? buildContext}) async {
    var isCheck = await MineAPI.instance.checkLogin();
    if(!isCheck) return;
    var account = MineAPI.instance.getAccount();
    if(account != null) {
      await DBAPI.sharedInstance.markDao.updateMark(markBean..isLocal = 0);
      var connectivityResult = await (Connectivity().checkConnectivity());
      var isConnected = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
      if(isConnected) {
        var params = {
          "user_id": MineAPI.instance.getAccount()?.user_id!,
          "uuid": await MineAPI.instance.getUUID(),
          "data": [markBean.toMap()],
          "opt": markBean.opt
        };
        await _addMark(params, buildContext: buildContext);
      }
    } else {
      await DBAPI.sharedInstance.markDao.updateMark(markBean);
    }
  }

  //插入或保存标记数据 日记，
  insertOrUpdateMark(Mark markBean, {BuildContext? buildContext}) async {
    var isCheck = await MineAPI.instance.checkLogin();
    if(!isCheck) return;
    var account = MineAPI.instance.getAccount();
    List<Mark> allDiary = await DBAPI.sharedInstance.markDao.findAllDiaryMarks();
    List<Mark> targetDiarys = allDiary.where((element) => element.dayAt == markBean.dayAt).toList();
    bool hasFind = targetDiarys.length > 0;
    if(account != null) {
      if(hasFind) {
        var updateItem = targetDiarys.first;
        updateItem..diary=markBean.diary..createAt=markBean.createAt;
        await DBAPI.sharedInstance.markDao.updateMark(updateItem..isLocal=0);
      } else {
        await DBAPI.sharedInstance.markDao.insertMark(markBean..isLocal=0);
      }
      var connectivityResult = await (Connectivity().checkConnectivity());
      var isConnected = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
      if(isConnected) {
        var params = {
          "user_id": MineAPI.instance.getAccount()?.user_id!,
          "uuid": await MineAPI.instance.getUUID(),
          "data": [markBean.toMap()],
          "opt": markBean.opt
        };
        await _addMark(params, buildContext: buildContext);
        //再同步 TODO
      }
    } else {
      if(hasFind) {
        var updateItem = targetDiarys.first;
        updateItem..diary=markBean.diary..createAt=markBean.createAt;
        await DBAPI.sharedInstance.markDao.updateMark(updateItem);
      } else {
        await DBAPI.sharedInstance.markDao.insertMark(markBean);
      }
    }
  }
  delete(Mark mark, {BuildContext? buildContext}) async {
    var isCheck = await MineAPI.instance.checkLogin();
    if(!isCheck) return;
    var account = MineAPI.instance.getAccount();
    if(account != null) {
      //登录状态 删除会员表
      if(mark.isMerged == 0) {//没merge 直接删
        await DBAPI.sharedInstance.markDao.deleteById(mark.id!);
      } else {
        mark.isDeleted = 1;
        await DBAPI.sharedInstance.markDao.updateMark(mark);
        //判断该记录是否merged， 如果merged过需要调接口
        var connectivityResult = await (Connectivity().checkConnectivity());
        var isConnected = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
        if( isConnected) {
          //删远程
          var params = {
            "user_id": MineAPI.instance.getAccount()?.user_id!,
            "uuid": await MineAPI.instance.getUUID(),
            "data": [mark.toMap()],
            "opt": mark.opt
          };
          await delMark(params, buildContext: buildContext);
          await DBAPI.sharedInstance.markDao.deleteById(mark.id!);
          // //再同步
          // await memberSyncData(buildContext: buildContext);
        }
      }
    } else {
      //脏数据表 直接删
      await DBAPI.sharedInstance.markDao.deleteById(mark.id!);
    }
  }

  allMarks() async {
    var account = MineAPI.instance.getAccount();
    List<Mark> allMarks;
    if(account != null) {
      allMarks = await DBAPI.sharedInstance.markDao.findAllMemberMarks();
    } else {
      allMarks = await DBAPI.sharedInstance.markDao.findAllLocalMarks();
    }
    return allMarks.where((element) => element.isDeleted == 0).toList();
  }



  // //删除最后一条数据
  // deleteLastRecord(BuildContext buildContext) async {
  //   var account = this.getAccount();
  //   if(account != null) {
  //     //登录状态 删除会员表
  //     List<MemberRecord>? _dataSource = await DBAPI.sharedInstance.memberRecordDao.findAllRecordsContainDeleted();
  //     //是否允许删除逻辑
  //     if (_dataSource.length > 0) {
  //       MemberRecord record = _dataSource.last;
  //       var recordOperationDateTime = DateUtil.getDateTimeByMs(int.parse(record.markAt));
  //       if(ProjectConfig.now.difference(recordOperationDateTime).inDays > 3 || record.isDeleted == 1) {
  //         MyDialog.showAlertDialog(buildContext, () {
  //         }, title: "没有可以删除的记录", message: "仅支持删除四天内的最后一条数据哦", isOnlySureBtn: true, sureBtnTitle: "好", sureBtnTitleColor: Colors.blue);
  //       } else {
  //         MyDialog.showAlertDialog(buildContext, () async {
  //           record.isDeleted = 1;
  //           await DBAPI.sharedInstance.memberRecordDao.updateRecord(record);
  //           //判断该记录是否merged， 如果merged过需要调接口
  //           var connectivityResult = await (Connectivity().checkConnectivity());
  //           var isConnected = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
  //           if(record.isMerged != 0 && isConnected) {
  //             //删远程
  //             await periodDelSync({"user_id": getAccount()?.user_id!, "markAt": record.markAt, "type": record.type, "createAt": record.createAt, "uuid": await getUUID()});
  //             //删本地
  //             // await DBAPI.sharedInstance.memberRecordDao.deleteById(record.id!);
  //             //再同步
  //             await memberSyncData(buildContext: buildContext);
  //           }
  //           showToast("删除记录成功");
  //         }, title: "删除记录？",
  //             message: "${DateUtil.formatDateMs(int.parse(record.markAt),format: "yyyy年MM月dd日")}：${record.type == 1 ? "姨妈开始" : "姨妈结束"}",
  //             sureBtnTitle: "删除",
  //             sureBtnTitleColor: Colors.red,
  //             cancelBtnTitleColor: Colors.blue
  //         );
  //       }
  //     } else {
  //       MyDialog.showAlertDialog(buildContext, () {}, title: "没有可以删除的记录", message: "仅支持删除四天内的最后一条数据哦", isOnlySureBtn: true, sureBtnTitle: "好", sureBtnTitleColor: Colors.blue);
  //     }
  //     // await DBAPI.sharedInstance.memberRecordDao.insertRecord(memberRecord);
  //     //同步数据
  //     // await memberSyncData(buildContext: buildContext);
  //
  //   } else {
  //     //脏数据表
  //     List<LocalRecord>? _dataSource = await DBAPI.sharedInstance.localRecordDao.findAllRecordsContainDeleted();
  //     if (_dataSource.length > 0) {
  //       LocalRecord record = _dataSource.last;
  //       var recordOperationDateTime = DateUtil.getDateTimeByMs(int.parse(record.markAt));
  //       if(ProjectConfig.now.difference(recordOperationDateTime!).inDays > 3 || record.isDeleted == 1) {
  //         MyDialog.showAlertDialog(buildContext, () {
  //           // Navigator.of(context).pop();
  //         }, title: "没有可以删除的记录", message: "仅支持删除四天内的最后一条数据哦", isOnlySureBtn: true, sureBtnTitle: "好", sureBtnTitleColor: Colors.blue);
  //       } else {
  //         MyDialog.showAlertDialog(buildContext, () async {
  //           record.isDeleted = 1;
  //           await DBAPI.sharedInstance.localRecordDao.updateRecord(record);
  //           showToast("删除记录成功");
  //           // Navigator.of(context).pop();
  //         }, title: "删除记录？",
  //             message: "${DateUtil.formatDateMs(int.parse(record.markAt),format: "yyyy年MM月dd日")}：${record.type == 1 ? "姨妈开始" : "姨妈结束"}",
  //             sureBtnTitle: "删除",
  //             sureBtnTitleColor: Colors.red,
  //             cancelBtnTitleColor: Colors.blue
  //         );
  //       }
  //     } else {
  //       MyDialog.showAlertDialog(buildContext, () {}, title: "没有可以删除的记录", message: "仅支持删除四天内的最后一条数据哦", isOnlySureBtn: true, sureBtnTitle: "好", sureBtnTitleColor: Colors.blue);
  //     }
  //
  //   }
  // }
  //
  // getAllRecord() async {
  //   var account = this.getAccount();
  //   if(account != null) {
  //     List<MemberRecord>? _dataSource = await DBAPI.sharedInstance.memberRecordDao.findAllRecords();
  //     return _dataSource.map((e) => _recordToMap(e)).toList();
  //   } else {
  //     List<LocalRecord>? _dataSource = await DBAPI.sharedInstance.localRecordDao.findAllRecords();
  //     return _dataSource.map((e) => _recordToMap(e)).toList();
  //   }
  // }
  // getLastRecord() async {
  //   var account = this.getAccount();
  //   if(account != null) {
  //     MemberRecord? last = await DBAPI.sharedInstance.memberRecordDao.findLastRecord();
  //     return _recordToMap(last);
  //   } else {
  //     LocalRecord? last = await DBAPI.sharedInstance.localRecordDao.findLastRecord();
  //     return _recordToMap(last);
  //   }
  //
  // }
  //
  // final _ACCOUNT_KEY = "ACCOUNT_KEY";
  // setAccount(LoginData userInfoData) async {
  //   await prefs?.setString(_ACCOUNT_KEY, json.encode(userInfoData));
  // }
  //
  // LoginData? getAccount() {
  //   var dataStr = prefs?.getString(_ACCOUNT_KEY);
  //   if (dataStr == null) {
  //     return null;
  //   }
  //   var map = json.decode(dataStr);
  //   LoginData userInfoData = LoginData().fromJson(map);
  //   return userInfoData;
  // }
  //
  // clearAccount() async {
  //   await prefs?.remove(_ACCOUNT_KEY);
  // }



//
//  Future<VersionEntity> downloadAPK(Map<String, dynamic> params,  {BuildContext buildContext}) async {
//    VersionEntity entity = await HttpManager.instance.downloadFile(urlPath, savePath, progressCallback: );
//    return entity;
//  }

}
