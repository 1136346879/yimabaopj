import 'package:yimabao/entities/version_entity.dart';

versionEntityFromJson(VersionEntity data, Map<String, dynamic> json) {
	if (json['status'] != null) {
		data.status = json['status'].toString();
	}
	if (json['message'] != null) {
		data.message = json['message'].toString();
	}
	if (json['data'] != null) {
		data.data = VersionData().fromJson(json['data']);
	}
	return data;
}

Map<String, dynamic> versionEntityToJson(VersionEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['status'] = entity.status;
	data['message'] = entity.message;
	data['data'] = entity.data?.toJson();
	return data;
}

versionDataFromJson(VersionData data, Map<String, dynamic> json) {
	if (json['updateStatus'] != null) {
		data.updateStatus = json['updateStatus'] is String
				? int.tryParse(json['updateStatus'])
				: json['updateStatus'].toInt();
	}
	if (json['updateDesc'] != null) {
		data.updateDesc = json['updateDesc'];
	}
	if (json['updateUrl'] != null) {
		data.updateUrl = json['updateUrl'];
	}
	return data;
}

Map<String, dynamic> versionDataToJson(VersionData entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['updateStatus'] = entity.updateStatus;
	data['updateDesc'] = entity.updateDesc;
	data['updateUrl'] = entity.updateUrl;
	return data;
}