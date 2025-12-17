import 'package:yimabao/entities/test_entity.dart';

testEntityFromJson(TestEntity data, Map<String, dynamic> json) {
	if (json['test'] != null) {
		data.test = json['test'] is String
				? int.tryParse(json['test'])
				: json['test'].toInt();
	}
	if (json['test2'] != null) {
		data.test2 = json['test2'] is String
				? int.tryParse(json['test2'])
				: json['test2'].toInt();
	}
	return data;
}

Map<String, dynamic> testEntityToJson(TestEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['test'] = entity.test;
	data['test2'] = entity.test2;
	return data;
}