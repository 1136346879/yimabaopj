// entity/person.dart

import 'package:floor/floor.dart';

@entity
class Record {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String operationTime;//标记时间
  final String addTime;//添加时间
  final int type;
  int isDeleted;
  Record(this.id, this.operationTime, this.addTime, this.type, {this.isDeleted = 0});
}