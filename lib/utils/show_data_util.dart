

// DateTime _lastDayOfMonth(DateTime month) {
//   final date = month.month < 12
//       ? DateTime.utc(month.year, month.month + 1, 1)
//       : DateTime.utc(month.year + 1, 1, 1);
//   return date.subtract(const Duration(days: 1));
// }
//
// DateTime _firstDayOfMonth(DateTime month) {
//   return DateTime.utc(month.year, month.month, 1);
// }
//
//
// List<DateTime> daysInRange(DateTime first, DateTime last) {
//   final dayCount = last.difference(first).inDays + 1;
//   return List.generate(
//     dayCount,
//         (index) => DateTime.utc(first.year, first.month, first.day + index),
//   );
// }

import 'package:yimabao/db/entities/mark.dart';

class ShowDataEntry {
  bool? isYMbegin;//是否标记姨妈来了
  bool? isYNend;//是否标记姨妈走了
  bool? isShowYMbegin;//是否显示标记姨妈来了
  bool? isShowYNend;//是否显示标记姨妈走了
  Map? recordInfo;
  List<Mark>? marks;
}