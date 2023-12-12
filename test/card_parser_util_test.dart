import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ml_card_scanner/ml_card_scanner.dart';
import 'package:ml_card_scanner/src/utils/card_parser_util.dart';
import 'package:mocktail/mocktail.dart';

class MockTextRecognizer extends Mock implements TextRecognizer {}

void main() {
  late CardParserUtil sut;
  late MockTextRecognizer textRecognizer;
  final sampleCardImage = InputImage.fromBytes(
      bytes: Uint8List(0),
      metadata: InputImageMetadata(
          size: Size.zero,
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 1));

  TextBlock getSampleTextBlock(String text) {
    return TextBlock(
        text: text,
        lines: [],
        boundingBox: Rect.zero,
        recognizedLanguages: [],
        cornerPoints: []);
  }

  setUp(() {
    textRecognizer = MockTextRecognizer();
    sut = CardParserUtil(textRecognizer);
  });
  test('Retruns null when recognized text is not valid a card number',
      () async {
    const invalidCardNumber = '123*234&^@£';
    when(() => textRecognizer.processImage(sampleCardImage)).thenAnswer(
      (_) async => RecognizedText(
        text: '',
        blocks: [
          getSampleTextBlock(invalidCardNumber),
        ],
      ),
    );

    final result = await sut.detectCardContent(
      sampleCardImage,
    );

    expect(result, null);
  });

  test('Returns card info when recognized text has valid card number',
      () async {
    const validCardNumber = '4242 4242 4242 4242';
    when(() => textRecognizer.processImage(sampleCardImage)).thenAnswer(
      (_) async => RecognizedText(
        text: '',
        blocks: [
          getSampleTextBlock(validCardNumber),
        ],
      ),
    );

    final result = await sut.detectCardContent(
      sampleCardImage,
    );

    expect(
        result,
        CardInfo(
          number: '4242424242424242',
          cvv: '',
          expiry: '',
        ));
  });

  test(
      'Returns card info when recognized text has valid card number'
      'with expiry date and CVV', () async {
    const validCardNumber = '4242 4242 4242 4242';
    const sampleDetectedExpiryDate = '12/22';
    const sampleCvv = '123';
    when(() => textRecognizer.processImage(sampleCardImage)).thenAnswer(
      (_) async => RecognizedText(
        text: '',
        blocks: [
          getSampleTextBlock(validCardNumber),
          getSampleTextBlock(sampleDetectedExpiryDate),
          getSampleTextBlock(sampleCvv),
        ],
      ),
    );

    final result = await sut.detectCardContent(
      sampleCardImage,
    );

    expect(result,
        CardInfo(number: '4242424242424242', cvv: sampleCvv, expiry: '12/22'));
  });

  test('Returns card info when recognized text has misspelles', () async {
    const misspelledCardNumber = 'Ll42 Ss42 Oo42 4242';
    const sampleDetectedExpiryDate = 'l2/22';
    const misspelledCvv = '12s';
    const otherDetectedText1 = 'cvv2';
    when(() => textRecognizer.processImage(sampleCardImage)).thenAnswer(
      (_) async => RecognizedText(
        text: '',
        blocks: [
          getSampleTextBlock(misspelledCardNumber),
          getSampleTextBlock(sampleDetectedExpiryDate),
          getSampleTextBlock(misspelledCvv),
          getSampleTextBlock(otherDetectedText1),
        ],
      ),
    );

    final result = await sut.detectCardContent(
      sampleCardImage,
    );

    expect(result,
        CardInfo(number: '1142554200424242', cvv: '125', expiry: '12/22'));
  });
}
