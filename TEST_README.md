# PhotoPoints Testing Guide

This document provides comprehensive information about the testing setup and practices for the PhotoPoints application.

## Test Suite Overview

The PhotoPoints application includes a comprehensive test suite with:

- **Unit Tests**: Test individual components in isolation
- **Widget Tests**: Test UI components and interactions
- **Integration Tests**: Test complete user workflows
- **End-to-End Tests**: Test the complete application flow

## Test Structure

```
test/
├── unit/                          # Unit tests
│   ├── models/                    # Model tests
│   │   ├── photo_point_test.dart
│   │   ├── photo_test.dart
│   │   ├── location_data_test.dart
│   │   └── compass_data_test.dart
│   └── services/                  # Service tests
│       ├── database_service_test.dart
│       ├── location_service_test.dart
│       ├── compass_service_test.dart
│       ├── photo_service_test.dart
│       └── permission_service_test.dart
├── widget/                        # Widget tests
│   └── widgets/
│       ├── photo_point_card_test.dart
│       ├── confirmation_dialog_test.dart
│       └── photo_grid_test.dart
├── integration/                   # Integration tests
│   └── photo_point_workflow_test.dart
├── mocks/                         # Mock objects
│   ├── mock_database.dart
│   └── mock_services.dart
├── test_data.dart                 # Test data utilities
└── test_runner.dart               # Test suite runner

integration_test/                  # Flutter integration tests
└── app_test.dart                  # End-to-end tests
```

## Running Tests

### Quick Tests (Development)

For fast feedback during development:

```bash
# Run quick tests without coverage
./scripts/test_quick.sh

# Or manually:
flutter test test/unit/
flutter test test/widget/
```

### Complete Test Suite

For comprehensive testing with coverage:

```bash
# Run complete test suite
./scripts/run_tests.sh

# Or manually:
flutter test --coverage
flutter test integration_test/
```

### Specific Test Files

```bash
# Run specific test file
flutter test test/unit/models/photo_point_test.dart

# Run specific test group
flutter test test/unit/models/photo_point_test.dart -n "PhotoPoint"
```

## Test Categories

### Unit Tests

**Purpose**: Test individual components in isolation

**Coverage**:
- Data models (PhotoPoint, Photo, LocationData, CompassData)
- Service classes (DatabaseService, LocationService, etc.)
- Business logic and validation

**Example**:
```dart
test('should create PhotoPoint with all fields', () {
  final photoPoint = PhotoPoint(
    id: 'test-id',
    name: 'Test Point',
    // ... other fields
  );
  
  expect(photoPoint.id, 'test-id');
  expect(photoPoint.name, 'Test Point');
});
```

### Widget Tests

**Purpose**: Test UI components and user interactions

**Coverage**:
- Custom widgets (PhotoPointCard, PhotoGrid, etc.)
- Dialog components
- User interaction handling

**Example**:
```dart
testWidgets('should display photo point information', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: PhotoPointCard(photoPoint: testPhotoPoint),
    ),
  );
  
  expect(find.text('Test Point'), findsOneWidget);
});
```

### Integration Tests

**Purpose**: Test complete workflows and component interactions

**Coverage**:
- Photo point creation workflow
- Data persistence
- Service integration
- Error handling

**Example**:
```dart
test('Complete photo point creation workflow', () async {
  await appStateProvider.addPhotoPoint(photoPoint);
  await appStateProvider.loadPhotoPoints();
  
  expect(appStateProvider.photoPoints.length, 1);
});
```

### End-to-End Tests

**Purpose**: Test complete application flows

**Coverage**:
- User journeys
- Navigation flows
- Cross-screen interactions
- App state management

## Test Utilities

### Test Data

The `TestData` class provides mock data for testing:

```dart
// Create mock photo point
final photoPoint = TestData.createMockPhotoPoint(
  name: 'Test Point',
  latitude: 37.7749,
  longitude: -122.4194,
);

// Create mock photo
final photo = TestData.createMockPhoto(
  photoPointId: 'test-point-id',
  filePath: '/test/path/photo.jpg',
);
```

### Mock Services

Mock implementations for external dependencies:

```dart
// Mock database service
final mockDatabase = MockDatabaseService();
mockDatabase.addMockPhotoPoint(photoPoint);

// Mock location service
final mockLocation = MockLocationService();
mockLocation.setMockLocationData(locationData);
```

## Test Configuration

### Dependencies

Testing dependencies in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
  fake_async: ^1.3.1
  sqflite_common_ffi: ^2.3.3
```

### Analysis Options

Testing-specific linting in `analysis_options.yaml`:

```yaml
linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - avoid_redundant_argument_values
```

## CI/CD Integration

### GitHub Actions

The test suite integrates with GitHub Actions for continuous testing:

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - run: flutter test integration_test/
```

## Best Practices

### Test Organization

1. **Group Related Tests**: Use `group()` to organize related tests
2. **Descriptive Names**: Use clear, descriptive test names
3. **Setup/Teardown**: Use `setUp()` and `tearDown()` for common setup
4. **Mock External Dependencies**: Mock services, databases, and APIs

### Test Writing Guidelines

1. **AAA Pattern**: Arrange, Act, Assert
2. **Single Responsibility**: Each test should verify one behavior
3. **Independent Tests**: Tests should not depend on each other
4. **Test Edge Cases**: Include boundary conditions and error cases

### Coverage Guidelines

1. **Focus on Business Logic**: Prioritize testing critical business logic
2. **Test Error Paths**: Include error handling and validation
3. **Ignore Generated Code**: Exclude `.g.dart` files from coverage
4. **Maintain Thresholds**: Keep coverage above defined thresholds

## Common Test Patterns

### Testing Async Operations

```dart
test('should handle async operations', () async {
  final result = await service.performAsyncOperation();
  expect(result, isNotNull);
});
```

### Testing Streams

```dart
test('should emit values from stream', () async {
  final stream = service.dataStream;
  expect(await stream.first, equals(expectedValue));
});
```

### Testing Exceptions

```dart
test('should throw exception for invalid input', () {
  expect(() => service.processInvalidInput(), throwsException);
});
```

### Testing State Changes

```dart
test('should update state correctly', () {
  provider.updateState(newValue);
  expect(provider.currentState, equals(newValue));
});
```

## Troubleshooting

### Common Issues

1. **Test Timeout**: Increase timeout in test configuration
2. **Mock Setup**: Ensure mocks are properly configured
3. **Widget Tests**: Use `pumpAndSettle()` for animations
4. **File Permissions**: Ensure test files are executable

### Debug Tips

1. **Print Statements**: Use `debugPrint()` for debugging
2. **Test Isolation**: Run tests individually to isolate issues
3. **Coverage Gaps**: Use coverage reports to identify untested code
4. **Verbose Output**: Use `--verbose` flag for detailed output

## Contributing

When adding new features:

1. **Write Tests First**: Follow TDD when possible
2. **Update Test Suite**: Add tests for new components
3. **Maintain Coverage**: Ensure coverage thresholds are met
4. **Document Changes**: Update test documentation

## Resources

- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Integration Testing](https://flutter.dev/docs/testing/integration-tests)
- [Test Coverage](https://flutter.dev/docs/testing/code-coverage)
