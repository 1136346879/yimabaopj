import 'package:yimabao/generated/json/base/json_convert_content.dart';

class LoginEntity with JsonConvert<LoginEntity> {
	String? status;
	String? message;
	LoginData? data;
}

class LoginData with JsonConvert<LoginData> {
	String? user_id;
	String? nickname;
	String? headimgurl;
}
