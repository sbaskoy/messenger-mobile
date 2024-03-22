import 'package:intl/intl.dart';

extension StringExtension on String? {
  String relativeDate({bool showToday = false}) {
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    DateTime lastWeek = DateTime(now.year, now.month, now.day - 7);

    DateTime? dateToDisplay = DateTime.tryParse(this ?? "")?.toLocal();
    if (dateToDisplay == null) return "";

    String formattedDate = '';

    if (dateToDisplay.year == now.year && dateToDisplay.month == now.month && dateToDisplay.day == now.day) {
      formattedDate = showToday == true ? "Bugün" : DateFormat("HH:mm").format(dateToDisplay);
    } else if (dateToDisplay.year == yesterday.year &&
        dateToDisplay.month == yesterday.month &&
        dateToDisplay.day == yesterday.day) {
      formattedDate = 'Dün';
    } else if (dateToDisplay.isAfter(lastWeek)) {
      formattedDate = DateFormat.EEEE().format(dateToDisplay); // Gün adı (Pazartesi, Salı, vs.)
    } else {
      formattedDate = DateFormat.yMMMMd().format(dateToDisplay); // Tarih (13 Mart 2024)
    }
    return formattedDate;
  }

  String dateFormat([String? formatStr]) {
    var format = DateFormat(formatStr ?? "yyyy-MM-dd");
    var date = DateTime.tryParse(this ?? "")?.toLocal();
    if (date == null) return "";
    return format.format(date);
  }

  DateTime? tryParseDateTime() => this == null ? null : (DateTime.tryParse(toString())?.toLocal());
}
