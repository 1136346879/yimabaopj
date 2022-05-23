
import 'package:floor/floor.dart';
import 'package:yimareport/db/entities/member_record.dart';

@dao
abstract class MemberRecordDao {
  @Query('SELECT * FROM MemberRecord WHERE isDeleted = 0 AND isLogout = 0')
  Future<List<MemberRecord>> findAllRecords();
  @Query('SELECT * FROM MemberRecord WHERE isDeleted = 0')
  Future<List<MemberRecord>> findAllRecordsContainLogout();
  @Query('SELECT * FROM MemberRecord WHERE isLogout = 0')
  Future<List<MemberRecord>> findAllRecordsContainDeleted();
  @Query('SELECT * FROM MemberRecord WHERE isMerged != 0')
  Future<List<MemberRecord>> findAllUnMergedRecords();
  @Query('SELECT * FROM MemberRecord WHERE id = :id')
  Future<MemberRecord?> findRecordById(int id);
  @Query('SELECT * FROM MemberRecord WHERE isDeleted = 0 AND isLogout = 0 ORDER BY id DESC LIMIT 1')
  Future<MemberRecord?> findLastRecord();
  @Query('SELECT * FROM MemberRecord ORDER BY id DESC LIMIT 1')
  Future<MemberRecord?> findLastOne();
  @Query('SELECT * FROM MemberRecord WHERE isDeleted = 1 AND isMerged = 1 ORDER BY id DESC LIMIT 2')
  Future<List<MemberRecord>?> findFirstDelRecord();

  @insert
  Future<void> insertRecord(MemberRecord record);
  @Insert()
  Future<void> batchInsertRecords(List<MemberRecord> records);

  @Query('DELETE FROM MemberRecord')
  Future<void> deleteAll();

  @Query('DELETE FROM MemberRecord where id = :id')
  Future<void> deleteById(int id);

  @update
  Future<void> updateRecord(MemberRecord record);

}