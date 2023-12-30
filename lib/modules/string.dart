import 'package:studystore_app/constants/lang.dart' as lang;

String getStringFromDate(DateTime datetime) {
  return datetime.year.toString().padLeft(4, '0') +
      '/' +
      datetime.month.toString().padLeft(2, '0') +
      '/' +
      datetime.day.toString().padLeft(2, '0');
}

String getStringFromMonth(DateTime datetime) {
  List<String> months = [
    lang.january[lang.langMode],
    lang.february[lang.langMode],
    lang.march[lang.langMode],
    lang.april[lang.langMode],
    lang.may[lang.langMode],
    lang.june[lang.langMode],
    lang.july[lang.langMode],
    lang.august[lang.langMode],
    lang.september[lang.langMode],
    lang.october[lang.langMode],
    lang.november[lang.langMode],
    lang.december[lang.langMode]
  ];

  return months[datetime.month - 1] + ' ' + datetime.year.toString().padLeft(4, '0');
}

String getStringFromTime(DateTime datetime) {
  return datetime.hour.toString().padLeft(2, '0') +
      ':' +
      datetime.minute.toString().padLeft(2, '0');
}

String getStringFromDateTime(DateTime datetime) {
  return datetime.year.toString().padLeft(4, '0') +
      '/' +
      datetime.month.toString().padLeft(2, '0') +
      '/' +
      datetime.day.toString().padLeft(2, '0') +
      ' ' +
      datetime.hour.toString().padLeft(2, '0') +
      ':' +
      datetime.minute.toString().padLeft(2, '0') +
      ':' +
      datetime.second.toString().padLeft(2, '0');
}
