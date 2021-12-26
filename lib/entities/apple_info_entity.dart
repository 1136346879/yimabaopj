
import 'package:yimareport/generated/json/base/json_convert_content.dart';

class AppleInfoEntity with JsonConvert<AppleInfoEntity> {
	int? resultCount;
	List<AppleInfoResult>? results;
}

class AppleInfoResult with JsonConvert<AppleInfoResult> {

	String? version;

}
