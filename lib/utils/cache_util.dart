import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 缓存管理类
/// ./lib/utils/cache_util.dart
class CacheUtil {
  /// 获取缓存大小
  static Future<String> total() async {
    Directory tempDir = await getTemporaryDirectory();
    Directory? fileDir;
    if(Platform.isAndroid) {
      fileDir = await getExternalStorageDirectory();
    }
    Directory? apkDir;
    if(fileDir != null) {
      var _locatPath = fileDir.path + '/Download/';
      apkDir = Directory(_locatPath!);
    }
    // print("---------123----${tempDir}");
    if (tempDir == null && apkDir == null) return "0.0K";
    int tempTotal = await _reduce(tempDir);
    int apkTotal = apkDir == null ? 0 : await _reduce(apkDir);
    int total = tempTotal + apkTotal;
    if(total == 0) {
      return "0.0K";
    }
    double result = total / 1000.0;
    return "${result.toStringAsFixed(1)}K";
  }

  /// 清除缓存
  static Future<void> clear() async {
    Directory tempDir = await getTemporaryDirectory();
    if (tempDir == null) return;
    await _delete(tempDir);

    Directory? fileDir;
    if(Platform.isAndroid) {
      fileDir = await getExternalStorageDirectory();
    }
    Directory? apkDir;

    if(fileDir != null) {
      var _locatPath = fileDir.path + '/Download/';
      apkDir = Directory(_locatPath!);
      await apkDir.delete(recursive: true);
    }
  }

  /// 递归缓存目录，计算缓存大小
  static Future<int> _reduce(final FileSystemEntity file) async {
    /// 如果是一个文件，则直接返回文件大小
    if (file is File) {
      int length = await file.length();
      return length;
    }

    /// 如果是目录，则遍历目录并累计大小
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();

      int total = 0;

      if (children != null && children.isNotEmpty)
        for (final FileSystemEntity child in children)
          total += await _reduce(child);

      return total;
    }

    return 0;
  }

  /// 递归删除缓存目录和文件
  static Future<void> _delete(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        await _delete(child);
      }
    } else {
      await file.delete();
    }
  }
}