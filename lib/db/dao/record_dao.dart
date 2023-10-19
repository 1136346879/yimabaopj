
import 'package:floor/floor.dart';
import 'package:yimabao/db/entities/record.dart';

@dao
abstract class RecordDao {
  @Query('SELECT * FROM Record WHERE isDeleted = 0')
  Future<List<Record>> findAllRecords();
  @Query('SELECT * FROM Record')
  Future<List<Record>> findAllRecordsContainDeleted();

  @Query('SELECT * FROM Record WHERE id = :id')
  Future<Record?> findRecordById(int id);
  @Query('SELECT * FROM Record WHERE isDeleted = 0 ORDER BY id DESC LIMIT 1')
  Future<Record?> findLastRecord();

  @insert
  Future<void> insertRecord(Record record);

  @Query('DELETE FROM Record')
  Future<void> deleteAll();

  @Query('DELETE FROM Record where id = :id')
  Future<void> deleteById(int id);

  @update
  Future<void> updateRecord(Record record);

}