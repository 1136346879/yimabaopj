
import 'package:floor/floor.dart';
import 'package:yimareport/db/entities/mark.dart';

@dao
abstract class MarkDao {
  // @Query('SELECT * FROM Mark ORDER BY dayAt ASC')
  // Future<List<Mark>> findMarks();
  @Query('SELECT * FROM Mark WHERE isLocal = 0 ORDER BY dayAt ASC')
  Future<List<Mark>> findAllMemberMarks();
  @Query('SELECT * FROM Mark WHERE isLocal = 1 ORDER BY dayAt ASC')
  Future<List<Mark>> findAllLocalMarks();

  @Query('SELECT * FROM Mark WHERE opt == diary')
  Future<List<Mark>> findAllDiaryMarks();
  // @Query('SELECT * FROM Mark WHERE opt = :opt ORDER BY dayAt desc')
  // Future<List<Mark>> findMarksByOpt(String opt);

  @Query('SELECT * FROM Mark WHERE isLocal = 0 AND opt = :opt ORDER BY dayAt desc')
  Future<List<Mark>> findMemberMarksByOpt(String opt);
  @Query('SELECT * FROM Mark WHERE isLocal = 1 AND opt = :opt ORDER BY dayAt desc')
  Future<List<Mark>> findLocalMarksByOpt(String opt);

  @Query('SELECT * FROM Mark WHERE isDeleted = 1')
  Future<List<Mark>> findMarksNeedDelete();
  @Insert()
  Future<int> insert(Mark mark);

  Future<void> insertMark(Mark mark) async{
    mark.id = await insert(mark);
  }
  @Insert()
  Future<void> batchInsertMarks(List<Mark> marks);

  // @Query('DELETE FROM Mark')
  // Future<void> deleteAll();
  @Query('DELETE FROM Mark WHERE isLocal = 0')
  Future<void> deleteAllMemberMarks();
  @Query('DELETE FROM Mark WHERE isLocal = 1')
  Future<void> deleteAllLocalMarks();

  @Query('DELETE FROM Mark where id = :id')
  Future<void> deleteById(int id);

  @update
  Future<void> updateMark(Mark mark);

  @update
  Future<void> updateMarks(List<Mark> marks);
  @delete
  Future<void> deleteMarks(List<Mark> marks);

}