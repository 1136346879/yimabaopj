import 'package:floor/floor.dart';
import 'package:yimareport/db/datebase/database.dart';

class DBAPI {
  DBAPI._();
  static AppDatabase? _instance;
  static final dbName = 'wyeth_database.db';
  static AppDatabase get sharedInstance  =>  _getInstance();
  static AppDatabase _getInstance() {
    return _instance!;
  }
  // create migration
  static final migration1to2 = Migration(1, 2, (database) async {
    print("建表");
    await database.execute(
        'CREATE TABLE IF NOT EXISTS `LocalRecord` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `markAt` TEXT NOT NULL, `createAt` TEXT NOT NULL, `type` INTEGER NOT NULL, `isDeleted` INTEGER NOT NULL)');
    await database.execute(
        'CREATE TABLE IF NOT EXISTS `MemberRecord` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `markAt` TEXT NOT NULL, `createAt` TEXT NOT NULL, `type` INTEGER NOT NULL, `isDeleted` INTEGER NOT NULL, `isMerged` INTEGER NOT NULL, `isLogout` INTEGER NOT NULL, `memberID` TEXT NOT NULL)');
  });
  static load() async{
    if (_instance == null) {
      _instance = await $FloorAppDatabase
          .databaseBuilder(dbName)
          .addMigrations([migration1to2])
          .build();
    }
  }

}