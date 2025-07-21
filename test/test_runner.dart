import 'package:flutter_test/flutter_test.dart';

// Unit tests
import 'unit/models/photo_point_test.dart' as photo_point_test;
import 'unit/models/photo_test.dart' as photo_test;
import 'unit/models/location_data_test.dart' as location_data_test;
import 'unit/models/compass_data_test.dart' as compass_data_test;
import 'unit/services/database_service_test.dart' as database_service_test;
import 'unit/services/location_service_test.dart' as location_service_test;
import 'unit/services/compass_service_test.dart' as compass_service_test;
import 'unit/services/photo_service_test.dart' as photo_service_test;
import 'unit/services/permission_service_test.dart' as permission_service_test;

// Widget tests
import 'widget/widgets/photo_point_card_test.dart' as photo_point_card_test;
import 'widget/widgets/confirmation_dialog_test.dart' as confirmation_dialog_test;
import 'widget/widgets/photo_grid_test.dart' as photo_grid_test;

// Integration tests
import 'integration/photo_point_workflow_test.dart' as photo_point_workflow_test;

void main() {
  group('PhotoPoints Test Suite', () {
    group('Unit Tests', () {
      group('Models', () {
        photo_point_test.main();
        photo_test.main();
        location_data_test.main();
        compass_data_test.main();
      });

      group('Services', () {
        database_service_test.main();
        location_service_test.main();
        compass_service_test.main();
        photo_service_test.main();
        permission_service_test.main();
      });
    });

    group('Widget Tests', () {
      photo_point_card_test.main();
      confirmation_dialog_test.main();
      photo_grid_test.main();
    });

    group('Integration Tests', () {
      photo_point_workflow_test.main();
    });
  });
}