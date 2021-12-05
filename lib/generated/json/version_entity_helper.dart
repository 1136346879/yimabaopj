import 'package:yimareport/entities/version_entity.dart';

versionEntityFromJson(VersionEntity data, Map<String, dynamic> json) {
	if (json['updateStatus'] != null) {
		data.updateStatus = json['updateStatus'] is String
				? int.tryParse(json['updateStatus'])
				: json['updateStatus'].toInt();
	}
	if (json['updateUrl'] != null) {
		data.updateUrl = json['updateUrl'].toString();
	}
	return data;
}

Map<String, dynamic> versionEntityToJson(VersionEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['updateStatus'] = entity.updateStatus;
	data['updateUrl'] = entity.updateUrl;
	return data;
}