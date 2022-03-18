import 'package:floor/floor.dart';
import 'package:yimareport/generated/json/base/json_convert_content.dart';

// @JsonSerializable()
@entity
class MemberRecord {
  @PrimaryKey(autoGenerate: true)
  int? id;
  final String markAt;//标记时间
  final String createAt;//添加时间
  final int type;
  int isDeleted;
  int isMerged;//是和服务器同步
  int isLogout;//退出登录
  final String memberID;//会员id
  MemberRecord(this.id, this.markAt, this.createAt, this.type, this.memberID, {this.isDeleted = 0, this.isMerged = 0, this.isLogout = 0});
}