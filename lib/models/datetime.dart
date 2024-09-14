extension DatetimeFormatter on DateTime {
  static const List<String> months = <String>[ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ];
  static const List<String> days = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String formatListTile() {
    final today = DateTime.now();
    final todaysDate = "${today.year}-${today.month}-${today.day}";
    final itemsDate = "${year}-${month}-${day}";
    if (todaysDate == itemsDate) {
      return "Today";
    }
    if (itemsDate == "${today.year}-${today.month}-${today.day - 1}") return "Yesterday";
    final weekdayName = days.elementAt(weekday - 1);
    final monthName = months.elementAt(month - 1);
    final yearName = year == today.year ? '' : year;
    return "${day} ${monthName} $yearName";
  }
}