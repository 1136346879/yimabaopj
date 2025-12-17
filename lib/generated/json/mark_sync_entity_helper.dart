import 'package:yimabao/entities/mark_sync_entity.dart';

markSyncEntityFromJson(MarkSyncEntity data, Map<String, dynamic> json) {
	if (json['status'] != null) {
		data.status = json['status'].toString();
	}
	if (json['message'] != null) {
		data.message = json['message'].toString();
	}
	if (json['data'] != null) {
		data.data = (json['data'] as List).map((v) => MarkSyncData().fromJson(v)).toList();
	}
	return data;
}

Map<String, dynamic> markSyncEntityToJson(MarkSyncEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['status'] = entity.status;
	data['message'] = entity.message;
	data['data'] =  entity.data.map((v) => v.toJson()).toList();
	return data;
}

markSyncDataFromJson(MarkSyncData data, Map<String, dynamic> json) {
	if (json['dayAt'] != null) {
		data.dayAt = json['dayAt'].toString();
	}
	if (json['hour'] != null) {
		data.hour = json['hour'].toString();
	}
	if (json['length'] != null) {
		data.length = json['length'].toString();
	}
	if (json['measure'] != null) {
		data.measure = json['measure'].toString();
	}
	if (json['createAt'] != null) {
		data.createAt = json['createAt'].toString();
	}
	if (json['weight'] != null) {
		data.weight = json['weight'].toString();
	}
	if (json['temperature'] != null) {
		data.temperature = json['temperature'].toString();
	}
	if (json['diary'] != null) {
		data.diary = json['diary'].toString();
	}
	if (json['opt'] != null) {
		data.opt = json['opt'].toString();
	}
	if (json['level'] != null) {
		data.level = json['level'].toString();
	}
	if (json['isMerged'] != null) {
		data.isMerged = json['isMerged'] is String
				? int.tryParse(json['isMerged'])
				: json['isMerged'].toInt();
	}
	return data;
}

Map<String, dynamic> markSyncDataToJson(MarkSyncData entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['dayAt'] = entity.dayAt;
	data['hour'] = entity.hour;
	data['length'] = entity.length;
	data['measure'] = entity.measure;
	data['createAt'] = entity.createAt;
	data['weight'] = entity.weight;
	data['temperature'] = entity.temperature;
	data['diary'] = entity.diary;
	data['opt'] = entity.opt;
	data['level'] = entity.level;
	data['isMerged'] = entity.isMerged;
	return data;
}