import 'package:flutter_test/flutter_test.dart';
import 'package:photopoints/services/photo_service.dart';

void main() {
  group('PhotoService filename generation', () {
    late PhotoService photoService;

    setUp(() {
      photoService = PhotoService();
    });

    test('should generate filename with valid photo point name and date', () {
      final photoDate = DateTime(2023, 12, 25, 14, 30);
      const photoPointName = 'Forest Clearing';

      final filename = photoService.generateShareFilename(
        photoPointName,
        photoDate,
      );

      expect(filename, equals('Forest_Clearing_20231225'));
    });

    test('should sanitize photo point name with special characters', () {
      final photoDate = DateTime(2023, 5, 15, 10, 0);
      const photoPointName = 'Trail <Head>/Path*';

      final filename = photoService.generateShareFilename(
        photoPointName,
        photoDate,
      );

      expect(filename, equals('Trail__Head__Path_20230515'));
    });

    test('should handle multiple spaces in photo point name', () {
      final photoDate = DateTime(2024, 1, 1, 0, 0);
      const photoPointName = 'Mountain   View    Lookout';

      final filename = photoService.generateShareFilename(
        photoPointName,
        photoDate,
      );

      expect(filename, equals('Mountain_View_Lookout_20240101'));
    });

    test('should handle empty or whitespace photo point name', () {
      final photoDate = DateTime(2023, 7, 4, 12, 0);
      const photoPointName = '   ';

      final filename = photoService.generateShareFilename(
        photoPointName,
        photoDate,
      );

      expect(filename, equals('photo_20230704'));
    });

    test('should pad single digit months and days', () {
      final photoDate = DateTime(2023, 3, 7, 8, 15);
      const photoPointName = 'Point A';

      final filename = photoService.generateShareFilename(
        photoPointName,
        photoDate,
      );

      expect(filename, equals('Point_A_20230307'));
    });

    test('should handle long photo point names', () {
      final photoDate = DateTime(2023, 11, 22, 16, 45);
      const photoPointName =
          'Very Long Photo Point Name With Many Words That Should Be Sanitized';

      final filename = photoService.generateShareFilename(
        photoPointName,
        photoDate,
      );

      expect(
        filename,
        equals(
          'Very_Long_Photo_Point_Name_With_Many_Words_That_Should_Be_Sanitized_20231122',
        ),
      );
    });
  });
}
