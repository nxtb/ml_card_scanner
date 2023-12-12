import 'dart:core';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ml_card_scanner/src/model/card_info.dart';
import 'package:ml_card_scanner/src/utils/string_extension.dart';

class CardParserUtil {
  final int _cardNumberLength = 16;
  final TextRecognizer _textDetector;
  CardParserUtil([TextRecognizer? textDetector])
      : _textDetector =
            textDetector ?? TextRecognizer(script: TextRecognitionScript.latin);

  Future<CardInfo?> detectCardContent(InputImage inputImage) async {
    final output = await _textDetector.processImage(inputImage);
    final clearElements = output.blocks
        .map(
          (e) => e.text.sanitized,
        )
        .toList();
    try {
      final possibleCardNumber = _getCardNumber(clearElements);
      final expire = _getExpireDate(clearElements);
      final cvv = _getCvv(clearElements);

      return CardInfo(number: possibleCardNumber, expiry: expire, cvv: cvv);
    } catch (e, _) {
      return null;
    }
  }

  String _getCardNumber(List<String> inputs) {
    return inputs
        .firstWhere((input) {
          final cleanValue = input.fixPossibleMisspells().removeNoneDigits();
          return (cleanValue.length == _cardNumberLength) &&
              (int.tryParse(cleanValue) ?? -1) != -1;
        })
        .fixPossibleMisspells()
        .removeNoneDigits();
  }

  String _getExpireDate(List<String> input) {
    try {
      final possibleDate = input.firstWhere((input) {
        final cleanValue = input.fixPossibleMisspells();
        if (int.tryParse(cleanValue) != null && cleanValue.length == 4) {
          return true;
        }
        return false;
      });
      return possibleDate.fixPossibleMisspells().possibleDateFormatted();
    } catch (e, _) {
      return '';
    }
  }

  String _getCvv(List<String> input) {
    try {
      final possibleDate = input.firstWhere((input) {
        final cleanValue = input.fixPossibleMisspells();
        if (cleanValue.length == 3) {
          return true;
        }
        return false;
      });
      return possibleDate.fixPossibleMisspells();
    } catch (e, _) {
      return '';
    }
  }
}
