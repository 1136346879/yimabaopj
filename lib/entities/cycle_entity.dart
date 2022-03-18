import 'package:yimareport/generated/json/base/json_convert_content.dart';

class CycleEntity with JsonConvert<CycleEntity> {
	late String status;
	late String message;
	late CycleData data;
}

class CycleData with JsonConvert<CycleData> {
	late int periodDays;
	late int nonPeriodDays;
	late String createAt;
}
