import 'package:floor/floor.dart';
import 'package:yimareport/generated/json/base/json_convert_content.dart';

// @JsonSerializable()
@entity
class LocalRecord {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String markAt;//标记时间
  final String createAt;//添加时间
  final int type;
  int isDeleted;
  LocalRecord(this.id, this.markAt, this.createAt, this.type, {this.isDeleted = 0});
}