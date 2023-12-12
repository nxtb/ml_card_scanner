import 'dart:core';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ml_card_scanner/src/model/card_info.dart';
import 'package:ml_card_scanner/src/utils/string_extension.dart';

class CardParserUtil {
  final TextRecognizer _textDetector;
  CardParserUtil([TextRecognizer? textDetector])
      : _textDetector =
            textDetector ?? TextRecognizer(script: TextRecognitionScript.latin);

  /// \d{4} matches exactly four digits.
  /// [-\s]? matches an optional hyphen or space.
  /// 4} repeats the previous pattern four times.
  final _cardNumberRegEx = RegExp(r'(\d{4}[-\s]?){4}');

  /// This pattern will match any string that contains a date in the format "MM/YY".
  final _expiryDateRegEx = RegExp(r'(0[1-9]|1[0-2])\/([0-9]{2})');

  /// (?<![0-9]) is a negative lookbehind that asserts the CVV is not preceded by a digit.
  /// [0-9]{3} matches exactly three digits.
  /// (?![0-9]) is a negative lookahead that asserts the CVV is not followed by a digit.
  final _cvvRegEx = RegExp(r'(?<![0-9])[0-9]{3}(?![0-9])');

  Future<CardInfo?> detectCardContent(InputImage inputImage) async {
    final output = await _textDetector.processImage(inputImage);
    var clearElements = output.blocks
        .map(
          (e) => e.text.sanitized,
        )
        .toList();
    try {
      final cardNumber = _getCardNumber(clearElements);
      clearElements.remove(cardNumber);
      final expire = _getExpireDate(clearElements);
      final cvv = _getCvv(clearElements);

      return CardInfo(number: cardNumber, expiry: expire, cvv: cvv);
    } catch (e, _) {
      return null;
    }
  }

  String _getCardNumber(List<String> inputs) {
    return inputs
        .firstWhere((input) => _cardNumberRegEx.hasMatch(input))
        .removeNoneDigits();
  }

  String _getExpireDate(List<String> input) {
    try {
      final possibleDate = input.firstWhere((input) {
        Match? match = _expiryDateRegEx.firstMatch(input);
        return match != null;
      });
      Match match = _expiryDateRegEx.firstMatch(possibleDate)!;
      return possibleDate.substring(match.start, match.end);
    } catch (e, _) {
      return '';
    }
  }

  String _getCvv(List<String> input) {
    try {
      final possibleCvv = input.firstWhere((input) {
        return _cvvRegEx.hasMatch(input);
      });
      Match match = _cvvRegEx.firstMatch(possibleCvv)!;
      return match.group(0)!;
    } catch (e, _) {
      return '';
    }
  }
}
