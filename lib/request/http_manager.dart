import 'dart:convert';
import 'dart:developer' as Logger;

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimabao/config/project_config.dart';
import 'package:yimabao/generated/json/base/json_convert_content.dart';
import 'package:yimabao/utils/dialog.dart';
import 'package:yimabao/utils/my_router.dart';
import 'package:yimabao/utils/toast_util.dart';

class CacheDomain {
  CacheDomain({required this.httpPrefix, required this.url});
  String url;
  String httpPrefix;
}

class HttpManager {
  factory HttpManager() => _getInstance();
  static HttpManager get instance => _getInstance();
  static HttpManager? _instance;
  static Dio dio = new Dio();
  static HttpManager _getInstance() {
    if (_instance == null) {
      _instance = new HttpManager._internal();
    }
    return _instance!;
  }

  static final _baseUrlKey = "BASEURLKEY";
  static final _httpPrefixKey = "HTTPPREFIXKEY";
  CancelToken _cancelToken = CancelToken();

  HttpManager._internal() {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    // _prefs.then((value) {
    //   if (value.getString(HttpHeaders.cookieHeader) != null) {
    //     dio.options.headers[HttpHeaders.cookieHeader] =
    //         value.getString(HttpHeaders.cookieHeader);
    //   }
    //   var cacheUrl = value.getString(_baseUrlKey) ?? "";
    //   var cacheHttpPrefix = value.getString(_httpPrefixKey) ?? "";
    //   dio.options.baseUrl = ProjectConfig.BASE_URL;
    // });
    dio.options.baseUrl = ProjectConfig.BASE_URL;
    dio.options.headers = {
      'X-Requested-With': 'XMLHttpRequest',
    };
    dio.options.connectTimeout = Duration(milliseconds: 15000);
    dio.options.validateStatus =  (int? status) {
      return status == 200 || status == 201;
    };
    dio.interceptors.add(_CookieInterceptor());
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //      (client) {
    //    client.findProxy = (uri) {
    //      return "PROXY 192.168.123.96:8888";
    //      return "PROXY 192.168.123.96:8888";
    //    };
    //  };
  }
  //
  // setDomain(String httpPrefix, String url) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString(_baseUrlKey, url);
  //   prefs.setString(_httpPrefixKey, httpPrefix);
  //   dio.options.baseUrl = httpPrefix + url + "/";
  // }

  // Future<CacheDomain> getDomain() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var cacheUrl = prefs.getString(_baseUrlKey) ?? ProjectConfig.BASE_URL;
  //   // var cacheHttpPrefix = prefs.getString(_httpPrefixKey) ?? ProjectConfig.DEFAULT_HTTP_PREFIX;
  //   return CacheDomain(httpPrefix: cacheHttpPrefix, url: cacheUrl);
  // }

  Future<T> request<T>(String method, String urlPath, {Map<String, dynamic>? params, //参数
      BuildContext? buildContext, //是否处理loading
      String contentType = HttpContentType.json, //默认json提交
      String loadingProgressText = "请稍等", bool isIgnoreErrMsg = false}) async {
    LoadingDialog? _loadingDialog;
    if (buildContext != null) {
      _loadingDialog = LoadingDialog();
      _loadingDialog.showLoadingDialog(buildContext,loadingProgressText);
    }
    T t;
    Response response;
    try {
      response = await dio.request(
        urlPath,
        data: contentType == HttpContentType.json ? json.encode(params) : params,
        queryParameters: (method == Method.GET) ? params : null,
        options: Options(contentType: contentType, method: method),
        cancelToken: _cancelToken
      );
      final _dataMap = json.decode(response.toString());
      if (ProjectConfig.DEBUG) Logger.log(_dataMap.toString());
      t = JsonConvert.fromJsonAsT(_dataMap);
      await _loadingDialog?.dismissLoadingDialog();
      // MyDialog.showAlertDialog(MyRouter.navigatorKey.currentContext!, () { }, title: , message: "123");
      return t;
    } catch (error) {
      await _loadingDialog?.dismissLoadingDialog();
      String errMsg = (error is DioError) ? "${error?.message ?? ""}" : error.toString();
      if(errMsg.contains('errno = 101')) {
        errMsg = "网络异常, 请检查网络";
      }
      // String errMsg = "网络异常, 请检查网络";
      if (!isIgnoreErrMsg) showToast(errMsg);
      throw error;
    }
  }

  /*
  //上传
  Future<Map<String, dynamic>> upload(
      {@required String urlPath,
      @required String filePath,
      Map<String, dynamic> queryParameters,
      BuildContext context,
      String fileName = "Img_from_Flutter.jpg",
      String loadingProgressText = "上传中，请稍等...",
      ProgressCallback onSendProgress}) async {
    LoadingDialog _loadingDialog;
    if (context != null) {
      _loadingDialog = LoadingDialog();
      _loadingDialog.showLoadingDialog(context,loadingProgressText);
    }
    Response response;
    Map<String, dynamic> _dataMap;
    try {
      Map<String, dynamic> formMap = {
        "imgFile": await MultipartFile.fromFile(filePath, filename: fileName, contentType: MediaType("image", "jpg"))
      };
      response = await dio.post(urlPath,
          queryParameters: queryParameters,
          data: FormData.fromMap(formMap),
          onSendProgress: onSendProgress);
      _dataMap = json.decode(response.toString());
      await _loadingDialog?.dismissLoadingDialog();
      return _dataMap;
    } catch (error) {
      String errMsg = (error is DioError) ? "${error?.message ?? ""}" : error.toString();
      await _loadingDialog?.dismissLoadingDialog();
      showToast(errMsg);
      throw error;
    }
  }

  //上传
  Future<Map<String, dynamic>> uploadData(
      {@required String urlPath,
        @required List<int> values,
        Map<String, dynamic> queryParameters,
        BuildContext context,
        String fileName = "Img_from_Flutter.jpg",
        String loadingProgressText = "上传中，请稍等...",
        ProgressCallback onSendProgress}) async {
    LoadingDialog _loadingDialog;
    if (context != null) {
      _loadingDialog = LoadingDialog();
      _loadingDialog.showLoadingDialog(context,loadingProgressText);
    }
    Response response;
    Map<String, dynamic> _dataMap;
    try {
      Map<String, dynamic> formMap = {
        "imgFile": await MultipartFile.fromBytes(values, filename: fileName, contentType: MediaType("image", "jpg"))
      };
      response = await dio.post(urlPath,
          queryParameters: queryParameters,
          data: FormData.fromMap(formMap),
          onSendProgress: onSendProgress);
      _dataMap = json.decode(response.toString());
      await _loadingDialog?.dismissLoadingDialog();
      return _dataMap;
    } catch (error) {
      String errMsg = (error is DioError) ? "${error?.message ?? ""}" : error.toString();
      await _loadingDialog?.dismissLoadingDialog();
      showToast(errMsg);
      throw error;
    }
  }

  Future<void> downloadFile(String urlPath, String savePath,
      {ProgressCallback progressCallback}) async {
    String fileName = urlPath.substring(urlPath.lastIndexOf('/'));
    try {
      await dio.download(urlPath, savePath + fileName,
          onReceiveProgress: progressCallback);
    } catch (error) {
      if (error is DioError) {
        showToast("errorType: ${error?.type ?? ""}  errorMsg: ${error?.message ?? ""}");
      } else {
        showToast(error.toString());
      }
      throw error;
    }
    Logger.log("文件下载成功，路径" + savePath + fileName);
  }
*/
}


class _CookieInterceptor extends Interceptor {
  _CookieInterceptor();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    //接口code判断全拦截？
    if (response.statusCode == 200 && response.data["status"] != 'success') {
      var exceptionMsg = "${response.data["message"] ?? ""}";
      print("code: ${response.data["status"] ?? ""} message: ${exceptionMsg}");
      var serverException = DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: exceptionMsg,
        type: DioExceptionType.badResponse,
      );
      handler.reject(serverException);
      return;
    }
    // List<String>? headers = response.headers[HttpHeaders.setCookieHeader];
    // if (headers != null && response.requestOptions.path == MineAPI.instance.USERINFO) {
    //   headers.forEach((header) {
    //     if (header.startsWith(ProjectConfig.COOKIE_KEY)) {
    //       Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    //       _prefs.then(
    //           (value) => value.setString(HttpHeaders.cookieHeader, header));
    //       HttpManager.dio.options.headers[HttpHeaders.cookieHeader] = header;
    //       return;
    //     }
    //   });
    // }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    super.onError(err, handler);
    if (err.response?.statusCode == 401) {
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        message: "会话超时，请重新登录",
        type: err.type,
      ));
      return;
    }
  }
}

class Method {
  static const String GET = 'GET';
  static const String POST = 'POST';
  static const String PUT = 'PUT';
  static const String HEAD = 'HEAD';
  static const String DELETE = 'DELETE';
  static const String PATCH = 'PATCH';
}

class HttpContentType {
  static const form = Headers.formUrlEncodedContentType + "; charset=utf-8"; //From提交
  static const json = Headers.jsonContentType; //json提交
}
