import 'package:yimabao/entities/is_login_entity.dart';

isLoginEntityFromJson(IsLoginEntity data, Map<String, dynamic> json) {
	if (json['status'] != null) {
		data.status = json['status'].toString();
	}
	if (json['message'] != null) {
		data.message = json['message'].toString();
	}
	if (json['data'] != null) {
		data.data = IsLoginData().fromJson(json['data']);
	}
	return data;
}

Map<String, dynamic> isLoginEntityToJson(IsLoginEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['status'] = entity.status;
	data['message'] = entity.message;
	data['data'] = entity.data.toJson();
	return data;
}

isLoginDataFromJson(IsLoginData data, Map<String, dynamic> json) {
	if (json['isLogin'] != null) {
		data.isLogin = json['isLogin'];
	}
	return data;
}

Map<String, dynamic> isLoginDataToJson(IsLoginData entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['isLogin'] = entity.isLogin;
	return data;
}