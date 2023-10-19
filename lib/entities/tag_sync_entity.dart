import 'package:yimabao/generated/json/base/json_convert_content.dart';

class TagSyncEntity with JsonConvert<TagSyncEntity> {
	late String status;
	late String message;
	late List<TagSyncData> data;
}

class TagSyncData with JsonConvert<TagSyncData> {
	late String markAt;
	late String type;
	late String createAt;
}
