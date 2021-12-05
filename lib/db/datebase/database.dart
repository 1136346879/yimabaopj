
// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:yimareport/db/dao/record_dao.dart';
import 'package:yimareport/db/entities/record.dart';


part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Record])
abstract class AppDatabase extends FloorDatabase {
  RecordDao get recordDao;
}