// entity/person.dart

import 'package:floor/floor.dart';

@entity
class Mark {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String opt;//类型
  String createAt;//添加时间
  final String dayAt;//标记的日期
  int isMerged;//是和服务器同步
  int isDeleted;//删除
  //不同类型对应属性
  String? weight;//体重信息
  String? temperature;//体温信息
  String? length;//爱爱时长
  String? measure;//爱爱措施
  String? hour;//爱爱发生时间
  String? diary;//日记
  int? isLocal;//本地脏数据


  Mark(this.id, this.opt, this.createAt, this.dayAt,
        { this.isMerged = 0,
          this.isDeleted = 0,
          this.weight = null,
          this.temperature = null,
          this.length = null,
          this.measure = null,
          this.hour = null,
          this.diary = null,
          this.isLocal = 1
        }
      );

  toMap() {
    var result = {
      "dayAt": this.dayAt,
      "createAt": this.createAt
    };
    if(this.opt == "weight") {
      result["weight"] = this.weight!;
    } else if(this.opt == "diary") {
      result["diary"] = this.diary!;
    } else if (this.opt == "love") {
      result["hour"] = this.hour!;
      result["length"] = this.length!;
      result["measure"] = this.measure!;
    } else if (this.opt == "temperature") {
      result["temperature"] = this.temperature!;
    }
    return result;
  }
}