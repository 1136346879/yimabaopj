import 'package:yimabao/generated/json/base/json_convert_content.dart';

class VersionEntity with JsonConvert<VersionEntity> {
	String? status;
	String? message;
	VersionData? data;
}

class VersionData with JsonConvert<VersionData> {
	int? updateStatus;
	dynamic updateDesc;
	dynamic updateUrl;
}
