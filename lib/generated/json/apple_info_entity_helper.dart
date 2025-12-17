import 'package:yimabao/entities/apple_info_entity.dart';

appleInfoEntityFromJson(AppleInfoEntity data, Map<String, dynamic> json) {
	if (json['resultCount'] != null) {
		data.resultCount = json['resultCount'] is String
				? int.tryParse(json['resultCount'])
				: json['resultCount'].toInt();
	}
	if (json['results'] != null) {
		data.results = (json['results'] as List).map((v) => AppleInfoResult().fromJson(v)).toList();
	}
	return data;
}

Map<String, dynamic> appleInfoEntityToJson(AppleInfoEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['resultCount'] = entity.resultCount;
	data['results'] =  entity.results?.map((v) => v.toJson())?.toList();
	return data;
}

appleInfoResultFromJson(AppleInfoResult data, Map<String, dynamic> json) {
	if (json['version'] != null) {
		data.version = json['version'].toString();
	}
	return data;
}

Map<String, dynamic> appleInfoResultToJson(AppleInfoResult entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['version'] = entity.version;
	return data;
}