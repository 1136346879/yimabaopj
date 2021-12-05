import 'package:yimareport/db/datebase/database.dart';

class DBAPI {
  DBAPI._();
  static AppDatabase? _instance;
  static final dbName = 'wyeth_database.db';
  static AppDatabase get sharedInstance  =>  _getInstance();
  static AppDatabase _getInstance() {
    return _instance!;
  }
  static load() async{
    if (_instance == null) {
      _instance = await $FloorAppDatabase
          .databaseBuilder(dbName)
          .build();
    }
  }

}