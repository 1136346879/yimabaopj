import 'package:yimabao/entities/login_entity.dart';

loginEntityFromJson(LoginEntity data, Map<String, dynamic> json) {
	if (json['status'] != null) {
		data.status = json['status'].toString();
	}
	if (json['message'] != null) {
		data.message = json['message'].toString();
	}
	if (json['data'] != null) {
		data.data = LoginData().fromJson(json['data']);
	}
	return data;
}

Map<String, dynamic> loginEntityToJson(LoginEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['status'] = entity.status;
	data['message'] = entity.message;
	data['data'] = entity.data?.toJson();
	return data;
}

loginDataFromJson(LoginData data, Map<String, dynamic> json) {
	if (json['user_id'] != null) {
		data.user_id = json['user_id'].toString();
	}
	if (json['nickname'] != null) {
		data.nickname = json['nickname'].toString();
	}
	if (json['headimgurl'] != null) {
		data.headimgurl = json['headimgurl'].toString();
	}
	return data;
}

Map<String, dynamic> loginDataToJson(LoginData entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['user_id'] = entity.user_id;
	data['nickname'] = entity.nickname;
	data['headimgurl'] = entity.headimgurl;
	return data;
}