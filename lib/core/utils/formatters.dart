import 'package:flutter/material.dart';

const List<String> _monthsUz = [
  'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
  'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr',
];

const List<String> _monthsRu = [
  'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
  'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
];

const List<String> _monthsRuGen = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];

const List<String> _monthsShortUz = [
  'yan', 'fev', 'mar', 'apr', 'may', 'iyn', 'iyl', 'avg', 'sen', 'okt', 'noy', 'dek',
];

const List<String> _monthsShortRu = [
  'янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
];

const List<String> _weekdaysUz = [
  'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba',
];

const List<String> _weekdaysRu = [
  'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье',
];

const List<String> _weekdaysShortUz = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

const List<String> _weekdaysShortRu = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

String groupDigits(int value) {
  final s = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    buf.write(s[i]);
    final remaining = s.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) buf.write(' ');
  }
  return value < 0 ? '-${buf.toString()}' : buf.toString();
}

String currencySuffix(bool uz) => uz ? "so'm" : 'сум';

String formatMoney(int amount, {required bool uz}) =>
    '${groupDigits(amount)} ${currencySuffix(uz)}';

String formatMoneyShort(int amount, {required bool uz}) {
  final suffix = currencySuffix(uz);
  final a = amount.abs();
  final sign = amount < 0 ? '-' : '';
  if (a >= 1000000000) {
    return '$sign${(a / 1000000000).toStringAsFixed(1)} ${uz ? 'mlrd' : 'млрд'} $suffix';
  }
  if (a >= 1000000) {
    return '$sign${(a / 1000000).toStringAsFixed(1)} ${uz ? 'mln' : 'млн'} $suffix';
  }
  if (a >= 10000) {
    return '$sign${(a / 1000).toStringAsFixed(1)} ${uz ? 'ming' : 'тыс.'} $suffix';
  }
  return '$sign${groupDigits(a)} $suffix';
}

String formatDate(DateTime d, {required bool uz}) =>
    '${d.day} ${uz ? _monthsUz[d.month - 1] : _monthsRuGen[d.month - 1]} ${d.year}';

String formatDateShort(DateTime d, {required bool uz}) =>
    '${d.day} ${uz ? _monthsShortUz[d.month - 1] : _monthsShortRu[d.month - 1]}';

String monthTitle(int year, int month, {required bool uz}) =>
    uz ? '${_monthsUz[month - 1]} $year' : '${_monthsRu[month - 1]} $year';

String shortMonth(int month, {required bool uz}) =>
    uz ? _monthsShortUz[month - 1] : _monthsShortRu[month - 1];

String weekdayName(DateTime d, {required bool uz}) {
  final idx = d.weekday - 1;
  return uz ? _weekdaysUz[idx] : _weekdaysRu[idx];
}

String weekdayShort(int weekday, {required bool uz}) {
  final idx = weekday - 1;
  return uz ? _weekdaysShortUz[idx] : _weekdaysShortRu[idx];
}

String formatTimeOfDay(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String monthKeyOf(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

DateTime parseDate(String s) => DateTime.parse(s);

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
