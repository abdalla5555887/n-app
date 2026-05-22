
import 'dart:convert';
import 'package:intl/intl.dart';
import 'models.dart';

class ScheduleLogic {
  static List<String> defaultWorkers = [
    "خالد قاسم", "نرمين طارق", "جيهان نصر", "بسمة محمد", 
    "الاء عبد النبي", "الاء قاسم", "مها والي", "عبد الله احمد", 
    "اسماعيل العماوي", "احمد محمود", "حسام حسن", "وفاء النمر", "احمد الحسيني"
  ];

  static List<ShiftAssignment> generateMonthDays(int year, int month) {
    List<ShiftAssignment> days = [];
    int daysInMonth = DateTime(year, month + 1, 0).day;
    
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(year, month, i);
      String dayName = _getDayNameArabic(date.weekday);
      days.add(ShiftAssignment(
        date: DateFormat('yyyy-MM-dd').format(date),
        dayName: dayName,
      ));
    }
    return days;
  }

  static String _getDayNameArabic(int weekday) {
    switch (weekday) {
      case DateTime.saturday: return "السبت";
      case DateTime.sunday: return "الأحد";
      case DateTime.monday: return "الإثنين";
      case DateTime.tuesday: return "الثلاثاء";
      case DateTime.wednesday: return "الأربعاء";
      case DateTime.thursday: return "الخميس";
      case DateTime.friday: return "الجمعة";
      default: return "";
    }
  }

  static Map<String, dynamic> calculateStats(List<ShiftAssignment> assignments, List<String> workers) {
    Map<String, Map<String, dynamic>> stats = {};
    for (var worker in workers) {
      stats[worker] = {
        'morning_evening': 0,
        'night': 0,
        'total_shifts': 0,
        'total_hours': 0,
      };
    }

    for (var day in assignments) {
      for (var w in day.morningWorkers) {
        if (stats.containsKey(w)) {
          stats[w]!['morning_evening'] += 1;
          stats[w]!['total_shifts'] += 1;
          stats[w]!['total_hours'] += 6;
        }
      }
      for (var w in day.eveningWorkers) {
        if (stats.containsKey(w)) {
          stats[w]!['morning_evening'] += 1;
          stats[w]!['total_shifts'] += 1;
          stats[w]!['total_hours'] += 6;
        }
      }
      for (var w in day.nightWorkers) {
        if (stats.containsKey(w)) {
          stats[w]!['night'] += 1;
          stats[w]!['total_shifts'] += 2; // Night counts as 2
          stats[w]!['total_hours'] += 12;
        }
      }
    }
    return stats;
  }
}
