import 'package:yimabao/entities/login_sync_entity.dart';

loginSyncEntityFromJson(LoginSyncEntity data, Map<String, dynamic> json) {
	if (json['status'] != null) {
		data.status = json['status'].toString();
	}
	if (json['message'] != null) {
		data.message = json['message'].toString();
	}
	if (json['data'] != null) {
		data.data = LoginSyncData().fromJson(json['data']);
	}
	return data;
}

Map<String, dynamic> loginSyncEntityToJson(LoginSyncEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['status'] = entity.status;
	data['message'] = entity.message;
	data['data'] = entity.data.toJson();
	return data;
}

loginSyncDataFromJson(LoginSyncData data, Map<String, dynamic> json) {
	if (json['isRmLocData'] != null) {
		data.isRmLocData = json['isRmLocData'];
	}
	if (json['data'] != null) {
		data.data = (json['data'] as List).map((v) => LoginSyncDataData().fromJson(v)).toList();
	}
	return data;
}

Map<String, dynamic> loginSyncDataToJson(LoginSyncData entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['isRmLocData'] = entity.isRmLocData;
	data['data'] =  entity.data.map((v) => v.toJson()).toList();
	return data;
}

loginSyncDataDataFromJson(LoginSyncDataData data, Map<String, dynamic> json) {
	if (json['markAt'] != null) {
		data.markAt = json['markAt'].toString();
	}
	if (json['createAt'] != null) {
		data.createAt = json['createAt'].toString();
	}
	if (json['type'] != null) {
		data.type = json['type'] is String
				? int.tryParse(json['type'])
				: json['type'].toInt();
	}
	return data;
}

Map<String, dynamic> loginSyncDataDataToJson(LoginSyncDataData entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['markAt'] = entity.markAt;
	data['createAt'] = entity.createAt;
	data['type'] = entity.type;
	return data;
}