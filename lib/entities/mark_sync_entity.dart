import 'package:yimabao/generated/json/base/json_convert_content.dart';

class MarkSyncEntity with JsonConvert<MarkSyncEntity> {
	late String status;
	late String message;
	late List<MarkSyncData> data;
}

class MarkSyncData with JsonConvert<MarkSyncData> {
	late String dayAt;
	late String hour;
	late String length;
	late String measure;
	late String createAt;
	late String weight;
	late String temperature;
	late String diary;
	late String opt;
	late String level;
	int isMerged = 1;
}
