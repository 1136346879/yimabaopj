import 'package:yimabao/entities/cycle_entity.dart';

cycleEntityFromJson(CycleEntity data, Map<String, dynamic> json) {
	if (json['status'] != null) {
		data.status = json['status'].toString();
	}
	if (json['message'] != null) {
		data.message = json['message'].toString();
	}
	if (json['data'] != null) {
		data.data = CycleData().fromJson(json['data']);
	}
	return data;
}

Map<String, dynamic> cycleEntityToJson(CycleEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['status'] = entity.status;
	data['message'] = entity.message;
	data['data'] = entity.data.toJson();
	return data;
}

cycleDataFromJson(CycleData data, Map<String, dynamic> json) {
	if (json['periodDays'] != null) {
		data.periodDays = json['periodDays'] is String
				? int.tryParse(json['periodDays'])
				: json['periodDays'].toInt();
	}
	if (json['nonPeriodDays'] != null) {
		data.nonPeriodDays = json['nonPeriodDays'] is String
				? int.tryParse(json['nonPeriodDays'])
				: json['nonPeriodDays'].toInt();
	}
	if (json['createAt'] != null) {
		data.createAt = json['createAt'].toString();
	}
	return data;
}

Map<String, dynamic> cycleDataToJson(CycleData entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['periodDays'] = entity.periodDays;
	data['nonPeriodDays'] = entity.nonPeriodDays;
	data['createAt'] = entity.createAt;
	return data;
}