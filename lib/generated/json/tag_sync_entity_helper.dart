import 'package:yimabao/entities/tag_sync_entity.dart';

tagSyncEntityFromJson(TagSyncEntity data, Map<String, dynamic> json) {
	if (json['status'] != null) {
		data.status = json['status'].toString();
	}
	if (json['message'] != null) {
		data.message = json['message'].toString();
	}
	if (json['data'] != null) {
		data.data = (json['data'] as List).map((v) => TagSyncData().fromJson(v)).toList();
	}
	return data;
}

Map<String, dynamic> tagSyncEntityToJson(TagSyncEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['status'] = entity.status;
	data['message'] = entity.message;
	data['data'] =  entity.data.map((v) => v.toJson()).toList();
	return data;
}

tagSyncDataFromJson(TagSyncData data, Map<String, dynamic> json) {
	if (json['markAt'] != null) {
		data.markAt = json['markAt'].toString();
	}
	if (json['type'] != null) {
		data.type = json['type'].toString();
	}
	if (json['createAt'] != null) {
		data.createAt = json['createAt'].toString();
	}
	return data;
}

Map<String, dynamic> tagSyncDataToJson(TagSyncData entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['markAt'] = entity.markAt;
	data['type'] = entity.type;
	data['createAt'] = entity.createAt;
	return data;
}