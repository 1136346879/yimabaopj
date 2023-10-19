import 'package:yimabao/generated/json/base/json_convert_content.dart';

class LoginSyncEntity with JsonConvert<LoginSyncEntity> {
	late String status;
	late String message;
	late LoginSyncData data;
}

class LoginSyncData with JsonConvert<LoginSyncData> {
	late bool isRmLocData;
	late List<LoginSyncDataData> data;
}

class LoginSyncDataData with JsonConvert<LoginSyncDataData> {
	late String markAt;
	late String createAt;
	late int type;
}
