
// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:yimareport/db/dao/local_record_dao.dart';
import 'package:yimareport/db/dao/member_record_dao.dart';
import 'package:yimareport/db/dao/record_dao.dart';
import 'package:yimareport/db/entities/local_record.dart';
import 'package:yimareport/db/entities/member_record.dart';
import 'package:yimareport/db/entities/record.dart';


part 'database.g.dart'; // the generated code will be there

@Database(version: 2, entities: [Record, LocalRecord, MemberRecord])
abstract class AppDatabase extends FloorDatabase {
  RecordDao get recordDao;
  LocalRecordDao get localRecordDao;
  MemberRecordDao get memberRecordDao;
}