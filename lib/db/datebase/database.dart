
// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:yimabao/db/dao/local_record_dao.dart';
import 'package:yimabao/db/dao/mark_dao.dart';
import 'package:yimabao/db/dao/member_record_dao.dart';
import 'package:yimabao/db/dao/record_dao.dart';
import 'package:yimabao/db/entities/local_record.dart';
import 'package:yimabao/db/entities/mark.dart';
import 'package:yimabao/db/entities/member_record.dart';
import 'package:yimabao/db/entities/record.dart';


part 'database.g.dart'; // the generated code will be there

@Database(version: 4, entities: [Record, LocalRecord, MemberRecord, Mark])
abstract class AppDatabase extends FloorDatabase {
  RecordDao get recordDao;
  LocalRecordDao get localRecordDao;
  MemberRecordDao get memberRecordDao;
  MarkDao get markDao;
}