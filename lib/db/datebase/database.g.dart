// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  RecordDao? _recordDaoInstance;

  LocalRecordDao? _localRecordDaoInstance;

  MemberRecordDao? _memberRecordDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Record` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `operationTime` TEXT NOT NULL, `addTime` TEXT NOT NULL, `type` INTEGER NOT NULL, `isDeleted` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `LocalRecord` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `markAt` TEXT NOT NULL, `createAt` TEXT NOT NULL, `type` INTEGER NOT NULL, `isDeleted` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `MemberRecord` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `markAt` TEXT NOT NULL, `createAt` TEXT NOT NULL, `type` INTEGER NOT NULL, `isDeleted` INTEGER NOT NULL, `isMerged` INTEGER NOT NULL, `isLogout` INTEGER NOT NULL, `memberID` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  RecordDao get recordDao {
    return _recordDaoInstance ??= _$RecordDao(database, changeListener);
  }

  @override
  LocalRecordDao get localRecordDao {
    return _localRecordDaoInstance ??=
        _$LocalRecordDao(database, changeListener);
  }

  @override
  MemberRecordDao get memberRecordDao {
    return _memberRecordDaoInstance ??=
        _$MemberRecordDao(database, changeListener);
  }
}

class _$RecordDao extends RecordDao {
  _$RecordDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _recordInsertionAdapter = InsertionAdapter(
            database,
            'Record',
            (Record item) => <String, Object?>{
                  'id': item.id,
                  'operationTime': item.operationTime,
                  'addTime': item.addTime,
                  'type': item.type,
                  'isDeleted': item.isDeleted
                }),
        _recordUpdateAdapter = UpdateAdapter(
            database,
            'Record',
            ['id'],
            (Record item) => <String, Object?>{
                  'id': item.id,
                  'operationTime': item.operationTime,
                  'addTime': item.addTime,
                  'type': item.type,
                  'isDeleted': item.isDeleted
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Record> _recordInsertionAdapter;

  final UpdateAdapter<Record> _recordUpdateAdapter;

  @override
  Future<List<Record>> findAllRecords() async {
    return _queryAdapter.queryList('SELECT * FROM Record WHERE isDeleted = 0',
        mapper: (Map<String, Object?> row) => Record(
            row['id'] as int?,
            row['operationTime'] as String,
            row['addTime'] as String,
            row['type'] as int,
            isDeleted: row['isDeleted'] as int));
  }

  @override
  Future<List<Record>> findAllRecordsContainDeleted() async {
    return _queryAdapter.queryList('SELECT * FROM Record',
        mapper: (Map<String, Object?> row) => Record(
            row['id'] as int?,
            row['operationTime'] as String,
            row['addTime'] as String,
            row['type'] as int,
            isDeleted: row['isDeleted'] as int));
  }

  @override
  Future<Record?> findRecordById(int id) async {
    return _queryAdapter.query('SELECT * FROM Record WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Record(
            row['id'] as int?,
            row['operationTime'] as String,
            row['addTime'] as String,
            row['type'] as int,
            isDeleted: row['isDeleted'] as int),
        arguments: [id]);
  }

  @override
  Future<Record?> findLastRecord() async {
    return _queryAdapter.query(
        'SELECT * FROM Record WHERE isDeleted = 0 ORDER BY id DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => Record(
            row['id'] as int?,
            row['operationTime'] as String,
            row['addTime'] as String,
            row['type'] as int,
            isDeleted: row['isDeleted'] as int));
  }

  @override
  Future<void> deleteAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Record');
  }

  @override
  Future<void> deleteById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM Record where id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertRecord(Record record) async {
    await _recordInsertionAdapter.insert(record, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateRecord(Record record) async {
    await _recordUpdateAdapter.update(record, OnConflictStrategy.abort);
  }
}

class _$LocalRecordDao extends LocalRecordDao {
  _$LocalRecordDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _localRecordInsertionAdapter = InsertionAdapter(
            database,
            'LocalRecord',
            (LocalRecord item) => <String, Object?>{
                  'id': item.id,
                  'markAt': item.markAt,
                  'createAt': item.createAt,
                  'type': item.type,
                  'isDeleted': item.isDeleted
                }),
        _localRecordUpdateAdapter = UpdateAdapter(
            database,
            'LocalRecord',
            ['id'],
            (LocalRecord item) => <String, Object?>{
                  'id': item.id,
                  'markAt': item.markAt,
                  'createAt': item.createAt,
                  'type': item.type,
                  'isDeleted': item.isDeleted
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<LocalRecord> _localRecordInsertionAdapter;

  final UpdateAdapter<LocalRecord> _localRecordUpdateAdapter;

  @override
  Future<List<LocalRecord>> findAllRecords() async {
    return _queryAdapter.queryList(
        'SELECT * FROM LocalRecord WHERE isDeleted = 0',
        mapper: (Map<String, Object?> row) => LocalRecord(
            row['id'] as int?,
            row['markAt'] as String,
            row['createAt'] as String,
            row['type'] as int,
            isDeleted: row['isDeleted'] as int));
  }

  @override
  Future<List<LocalRecord>> findAllRecordsContainDeleted() async {
    return _queryAdapter.queryList('SELECT * FROM LocalRecord',
        mapper: (Map<String, Object?> row) => LocalRecord(
            row['id'] as int?,
            row['markAt'] as String,
            row['createAt'] as String,
            row['type'] as int,
            isDeleted: row['isDeleted'] as int));
  }

  @override
  Future<LocalRecord?> findRecordById(int id) async {
    return _queryAdapter.query('SELECT * FROM LocalRecord WHERE id = ?1',
        mapper: (Map<String, Object?> row) => LocalRecord(
            row['id'] as int?,
            row['markAt'] as String,
            row['createAt'] as String,
            row['type'] as int,
            isDeleted: row['isDeleted'] as int),
        arguments: [id]);
  }

  @override
  Future<LocalRecord?> findLastRecord() async {
    return _queryAdapter.query(
        'SELECT * FROM LocalRecord WHERE isDeleted = 0 ORDER BY id DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => LocalRecord(
            row['id'] as int?,
            row['markAt'] as String,
            row['createAt'] as String,
            row['type'] as int,
            isDeleted: row['isDeleted'] as int));
  }

  @override
  Future<void> deleteAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM LocalRecord');
  }

  @override
  Future<void> deleteById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM LocalRecord where id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> insertRecord(LocalRecord record) async {
    await _localRecordInsertionAdapter.insert(record, OnConflictStrategy.abort);
  }

  @override
  Future<void> batchInsertRecords(List<LocalRecord> records) async {
    await _localRecordInsertionAdapter.insertList(
        records, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateRecord(LocalRecord record) async {
    await _localRecordUpdateAdapter.update(record, OnConflictStrategy.abort);
  }
}

class _$MemberRecordDao extends MemberRecordDao {
  _$MemberRecordDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _memberRecordInsertionAdapter = InsertionAdapter(
            database,
            'MemberRecord',
            (MemberRecord item) => <String, Object?>{
                  'id': item.id,
                  'markAt': item.markAt,
                  'createAt': item.createAt,
                  'type': item.type,
                  'isDeleted': item.isDeleted,
                  'isMerged': item.isMerged,
                  'isLogout': item.isLogout,
                  'memberID': item.memberID
                }),
        _memberRecordUpdateAdapter = UpdateAdapter(
            database,
            'MemberRecord',
            ['id'],
            (MemberRecord item) => <String, Object?>{
                  'id': item.id,
                  'markAt': item.markAt,
                  'createAt': item.createAt,
                  'type': item.type,
                  'isDeleted': item.isDeleted,
                  'isMerged': item.isMerged,
                  'isLogout': item.isLogout,
                  'memberID': item.memberID
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MemberRecord> _memberRecordInsertionAdapter;

  final UpdateAdapter<MemberRecord> _memberRecordUpdateAdapter;

  @override
  Future<List<MemberRecord>> findAllRecords() async {
    return _queryAdapter.queryList(
        'SELECT * FROM MemberRecord WHERE isDeleted = 0 AND isLogout = 0',
        mapper: (Map<String, Object?> row) => MemberRecord(
            row['id'] as int?,
            row['markAt'] as String,
            row['createAt'] as String,
            row['type'] as int,
            row['memberID'] as String,
            isDeleted: row['isDeleted'] as int,
            isMerged: row['isMerged'] as int,
            isLogout: row['isLogout'] as int));
  }

  @override
  Future<List<MemberRecord>> findAllRecordsContainLogout() async {
    return _queryAdapter.queryList(
        'SELECT * FROM MemberRecord WHERE isDeleted = 0',
        mapper: (Map<String, Object?> row) => MemberRecord(
            row['id'] as int?,
            row['markAt'] as String,
            row['createAt'] as String,
            row['type'] as int,
            row['memberID'] as String,
            isDeleted: row['isDeleted'] as int,
            isMerged: row['isMerged'] as int,
            isLogout: row['isLogout'] as int));
  }

  @override
  Future<List<MemberRecord>> findAllRecordsContainDeleted() async {
    return _queryAdapter.queryList(
        'SELECT * FROM MemberRecord WHERE isLogout = 0',
        mapper: (Map<String, Object?> row) => MemberRecord(
            row['id'] as int?,
            row['markAt'] as String,
            row['createAt'] as String,
            row['type'] as int,
            row['memberID'] as String,
            isDeleted: row['isDeleted'] as int,
            isMerged: row['isMerged'] as int,
            isLogout: row['isLogout'] as int));
  }

  @override
  Future<List<MemberRecord>> findAllUnMergedRecords() async {
    return _queryAdapter.queryList(
        'SELECT * FROM MemberRecord WHERE isMerged != 0',
        mapper: (Map<String, Object?> row) => MemberRecord(
            row['id'] as int?,
            row['markAt'] as String,
            row['createAt'] as String,
            row['type'] as int,
            row['memberID'] as String,
            isDeleted: row['isDeleted'] as int,
            isMerged: row['isMerged'] as int,
            isLogout: row['isLogout'] as int));
  }

  @override
  Future<MemberRecord?> findRecordById(int id) async {
    return _queryAdapter.query('SELECT * FROM MemberRecord WHERE id = ?1',
        mapper: (Map<String, Object?> row) => MemberRecord(
            row['id'] as int?,
            row['markAt'] as String,
            row['createAt'] as String,
            row['type'] as int,
            row['memberID'] as String,
            isDeleted: row['isDeleted'] as int,
            isMerged: row['isMerged'] as int,
            isLogout: row['isLogout'] as int),
        arguments: [id]);
  }

  @override
  Future<MemberRecord?> findLastRecord() async {
    return _queryAdapter.query(
        'SELECT * FROM MemberRecord WHERE isDeleted = 0 AND isLogout = 0 ORDER BY id DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => MemberRecord(
            row['id'] as int?,
            row['markAt'] as String,
            row['createAt'] as String,
            row['type'] as int,
            row['memberID'] as String,
            isDeleted: row['isDeleted'] as int,
            isMerged: row['isMerged'] as int,
            isLogout: row['isLogout'] as int));
  }

  @override
  Future<MemberRecord?> findLastOne() async {
    return _queryAdapter.query(
        'SELECT * FROM MemberRecord ORDER BY id DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => MemberRecord(
            row['id'] as int?,
            row['markAt'] as String,
            row['createAt'] as String,
            row['type'] as int,
            row['memberID'] as String,
            isDeleted: row['isDeleted'] as int,
            isMerged: row['isMerged'] as int,
            isLogout: row['isLogout'] as int));
  }

  @override
  Future<List<MemberRecord>?> findFirstDelRecord() async {
    return _queryAdapter.queryList(
        'SELECT * FROM MemberRecord WHERE isDeleted = 1 AND isMerged = 1 ORDER BY id DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => MemberRecord(
            row['id'] as int?,
            row['markAt'] as String,
            row['createAt'] as String,
            row['type'] as int,
            row['memberID'] as String,
            isDeleted: row['isDeleted'] as int,
            isMerged: row['isMerged'] as int,
            isLogout: row['isLogout'] as int));
  }

  @override
  Future<void> deleteAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM MemberRecord');
  }

  @override
  Future<void> deleteById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM MemberRecord where id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> insertRecord(MemberRecord record) async {
    await _memberRecordInsertionAdapter.insert(
        record, OnConflictStrategy.abort);
  }

  @override
  Future<void> batchInsertRecords(List<MemberRecord> records) async {
    await _memberRecordInsertionAdapter.insertList(
        records, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateRecord(MemberRecord record) async {
    await _memberRecordUpdateAdapter.update(record, OnConflictStrategy.abort);
  }
}
