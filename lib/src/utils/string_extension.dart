extension StringExtension on String {
  String get sanitized => replaceAll('\n', '').replaceAll(' ', '');

  String removeNoneDigits() => replaceAll(RegExp(r'\D'), '');
}
