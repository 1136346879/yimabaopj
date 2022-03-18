
import 'package:floor/floor.dart';
import 'package:yimareport/db/entities/local_record.dart';

@dao
abstract class LocalRecordDao {
  @Query('SELECT * FROM LocalRecord WHERE isDeleted = 0')
  Future<List<LocalRecord>> findAllRecords();
  @Query('SELECT * FROM LocalRecord')
  Future<List<LocalRecord>> findAllRecordsContainDeleted();

  @Query('SELECT * FROM LocalRecord WHERE id = :id')
  Future<LocalRecord?> findRecordById(int id);
  @Query('SELECT * FROM LocalRecord WHERE isDeleted = 0 ORDER BY id DESC LIMIT 1')
  Future<LocalRecord?> findLastRecord();

  @insert
  Future<void> insertRecord(LocalRecord record);
  @Insert()
  Future<void> batchInsertRecords(List<LocalRecord> records);

  @Query('DELETE FROM LocalRecord')
  Future<void> deleteAll();

  @Query('DELETE FROM LocalRecord where id = :id')
  Future<void> deleteById(int id);

  @update
  Future<void> updateRecord(LocalRecord record);

}