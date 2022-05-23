import 'package:yimareport/generated/json/base/json_convert_content.dart';

class IsLoginEntity with JsonConvert<IsLoginEntity> {
	late String status;
	late String message;
	late IsLoginData data;
}

class IsLoginData with JsonConvert<IsLoginData> {
	late bool isLogin;
}
