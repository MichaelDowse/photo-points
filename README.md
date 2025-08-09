# Photo Points

A Flutter mobile application for creating and managing photo points to monitor reforestation and environmental changes over time. The app captures geotagged photos with compass direction data, enabling users to track environmental progress from consistent viewpoints.

## Features

- **Photo Point Creation**: Create named photo points with GPS coordinates and compass direction
- **Geotagged Photography**: Capture photos with automatic GPS location and compass bearing
- **Time-based Monitoring**: Track changes over time by taking photos from the same locations
- **Local Storage**: All data stored locally using SQLite database
- **Cross-platform**: Runs on iOS and Android devices
- **Offline Capability**: Works without internet connection
- **Export Functionality**: Share photos and data with other applications

## Core Functionality

### Photo Point Management
- Create photo points with custom names and optional notes
- Each photo point stores GPS coordinates (latitude/longitude) and compass direction
- View all photo points in a scrollable list with preview images
- Delete and edit existing photo points

### Photography Features
- Camera integration with real-time compass overlay
- Automatic GPS coordinate capture
- Compass direction recording (both numeric degrees and cardinal directions)
- Photo storage with metadata linking to photo points
- Multiple photos per photo point for time-series monitoring

### Data Management
- SQLite database for local data persistence
- JSON serialization for data export
- Automatic database migrations
- Efficient photo loading and caching

## Technical Architecture

### Technology Stack
- **Framework**: Flutter 3.8.1+ (Dart)
- **Database**: SQLite with `sqflite` package
- **State Management**: Provider pattern
- **Camera**: `camera` package for photo capture
- **Location**: `geolocator` package for GPS coordinates
- **Compass**: `flutter_compass` package for bearing data
- **Permissions**: `permission_handler` for camera/location access

### Project Structure
```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
│   ├── photo_point.dart     # PhotoPoint model with JSON serialization
│   ├── photo.dart           # Photo model
│   ├── location_data.dart   # Location data model
│   └── compass_data.dart    # Compass data model
├── screens/                  # UI screens
│   ├── photo_points_list_screen.dart    # Main list view
│   ├── add_photo_point_screen.dart      # Create new photo point
│   ├── show_photo_point_screen.dart     # View photo point details
│   └── camera_screen.dart               # Camera interface
├── services/                 # Business logic services
│   ├── database_service.dart            # SQLite database operations
│   ├── location_service.dart            # GPS location handling
│   ├── compass_service.dart             # Compass data processing
│   ├── photo_service.dart               # Photo capture and storage
│   └── permission_service.dart          # App permissions management
├── providers/                # State management
│   └── app_state_provider.dart          # Global app state
├── widgets/                  # Reusable UI components
│   ├── photo_point_card.dart            # Photo point list item
│   ├── camera_overlay.dart              # Camera UI overlay
│   ├── navigation_aids.dart             # Navigation helpers
│   ├── permissions_dialog.dart          # Permission request dialog
│   ├── photo_grid.dart                  # Photo grid display
│   └── confirmation_dialog.dart         # Confirmation dialogs
└── utils/                    # Utilities
    └── theme.dart                       # App theme configuration
```

### Data Models

#### PhotoPoint
```dart
class PhotoPoint {
  final String id;           // UUID
  final String name;         // User-defined name
  final String? notes;       // Optional notes
  final double latitude;     // GPS latitude
  final double longitude;    // GPS longitude
  final double compassDirection; // Compass bearing in degrees
  final DateTime createdAt;  // Creation timestamp
  final List<Photo> photos;  // Associated photos
}
```

#### Photo
```dart
class Photo {
  final String id;           // UUID
  final String photoPointId; // Reference to PhotoPoint
  final String filePath;     // Local file path
  final double latitude;     // GPS latitude when taken
  final double longitude;    // GPS longitude when taken
  final double compassDirection; // Compass bearing when taken
  final DateTime takenAt;    // Photo timestamp
  final bool isInitial;      // Whether this is the initial photo
}
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.8.1 or later
- Dart SDK 3.0.0 or later
- Android Studio or VS Code with Flutter extensions
- iOS development: Xcode (for iOS deployment)
- Android development: Android SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd photopoints
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (for JSON serialization)**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   # For development
   flutter run

   # For specific platform
   flutter run -d android
   flutter run -d ios
   flutter run -d chrome
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK version: 21 (Android 5.0)
- Target SDK version: 34
- Required permissions configured in `android/app/src/main/AndroidManifest.xml`:
  - `CAMERA`
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`

#### iOS
- Minimum iOS version: 12.0
- Required permissions configured in `ios/Runner/Info.plist`:
  - `NSCameraUsageDescription`
  - `NSLocationWhenInUseUsageDescription`

## Development

### Building and Testing

The project includes a comprehensive test suite with unit tests, widget tests, and integration tests. For detailed testing information, see [TEST_README.md](TEST_README.md).

```bash
# Quick test run (development)
./scripts/test_quick.sh

# Complete test suite with coverage
./scripts/run_tests.sh

# Run specific test types
flutter test test/unit/         # Unit tests
flutter test test/widget/       # Widget tests
flutter test test/integration/  # Integration tests

# Analyze code
flutter analyze

# Format code
flutter format .

#### Release Commands

**Android Release**:
```bash
# Complete Android release process
./bump_version.sh build                    # Update version
flutter build apk --release                # Build signed APK
./distribute.sh android "1.1.1"    # Distribute to Firebase

# Manual Android setup
export JAVA_HOME=/opt/homebrew/opt/openjdk@11
export PATH="$JAVA_HOME/bin:$PATH"
```

**iOS Release**:
```bash
# Complete iOS release process
./bump_version.sh build                    # Update version
./distribute.sh ios "Release notes"        # Build and distribute to Firebase

# Manual iOS build
flutter build ios --release                # Build iOS project
open ios/Runner.xcworkspace                # Open in Xcode for archive
flutter build ipa --release                # Build IPA directly (if signing configured)
# distribute in xcode:
open /Users/michaeldowse/Projects/ttc/claude/photopoints/build/ios/archive/Runner.xcarchive
```

### Code Generation
The project uses `json_serializable` for automatic JSON serialization. When modifying model classes:

```bash
# Generate code
flutter packages pub run build_runner build

# Watch for changes and regenerate
flutter packages pub run build_runner watch
```

### Database Management
The app uses SQLite for local data storage. Database schema is managed in `lib/services/database_service.dart`:
- Version: 1
- Tables: `photo_points`, `photos`
- Automatic migration support

## Usage Guide

### For Human Developers

1. **Adding New Features**
   - Follow the existing service-provider-widget pattern
   - Add new models to `models/` directory
   - Implement business logic in `services/`
   - Create UI components in `widgets/` or `screens/`

2. **Database Changes**
   - Increment database version in `DatabaseService`
   - Add migration logic in `_onCreate` or new migration method
   - Update model classes and regenerate JSON serialization

3. **Testing**
   - Write unit tests for services and models
   - Write widget tests for UI components
   - Test on both Android and iOS devices

### For AI Developers

1. **Understanding the Codebase**
   - Entry point: `lib/main.dart`
   - State management: Provider pattern in `lib/providers/`
   - Data persistence: SQLite service in `lib/services/database_service.dart`
   - Key models: `PhotoPoint` and `Photo` in `lib/models/`

2. **Common Patterns**
   - Async/await for database operations
   - Provider for state management
   - Service classes for business logic
   - JSON serialization for data export

3. **Key Integration Points**
   - Camera integration: `lib/services/photo_service.dart`
   - Location services: `lib/services/location_service.dart`
   - Compass data: `lib/services/compass_service.dart`
   - Permissions: `lib/services/permission_service.dart`

## Dependencies

### Core Dependencies
- `flutter`: SDK framework
- `camera`: Camera functionality
- `geolocator`: GPS location services
- `flutter_compass`: Compass bearing data
- `sqflite`: SQLite database
- `path_provider`: File system access
- `permission_handler`: Runtime permissions
- `provider`: State management
- `share_plus`: Share functionality

### Development Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Code linting
- `build_runner`: Code generation
- `json_serializable`: JSON serialization

## App Branding and Assets

### App Icons and Launch Screens

The Photo Points app uses custom-designed icons and launch screens that reflect its environmental monitoring purpose. The design features:

- **Camera icon** - Representing photo capture functionality
- **Location pin** - GPS positioning and photo points
- **Compass** - Direction tracking capabilities
- **Environmental elements** - Leaves and nature motifs
- **Green color scheme** - Environmental theme (#4CAF50 primary, #2E7D32 dark)

### Updating Icons and Launch Screens

If you need to update the app icons or launch screens in the future, follow these steps:

#### 1. Design Requirements

Create a 1024x1024 PNG file for the app icon with:
- Solid background (no transparency for iOS App Store compliance)
- Clear, simple design that works at small sizes
- Consistent color scheme matching the app theme

#### 2. Generate Icons and Launch Screens Using Python Script

Use the provided Python script to generate all assets programmatically:

```bash
# Install Python dependencies
pip install Pillow

# Run the complete asset generation script
python3 scripts/generate_app_assets.py
```

The script (`scripts/generate_app_assets.py`) includes:

- **App Icon Generation**: Creates the main 1024x1024 icon with camera, location pin, compass, and environmental elements
- **Multiple Size Generation**: Automatically creates icons in sizes 512, 256, 128, and 64 pixels
- **Launch Screen Generation**: Creates launch screens for different device sizes and orientations
- **Design Consistency**: Maintains the same color scheme and design elements across all assets

The script creates all necessary files in the `assets/` directory and provides step-by-step instructions for the next steps.

#### 3. Configure Flutter Packages

Update `pubspec.yaml` with the icon and splash screen packages:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.4.0

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/app_icon_1024.png"
  adaptive_icon_background: "#4CAF50"
  adaptive_icon_foreground: "assets/app_icon_1024.png"

flutter_native_splash:
  color: "#4CAF50"
  image: "assets/app_icon_512.png"
  android_12:
    image: "assets/app_icon_512.png"
    color: "#4CAF50"
```

#### 4. Generate Platform-Specific Assets

Run the Flutter commands to generate platform-specific icons and launch screens:

```bash
# Install dependencies
flutter pub get

# Generate app icons for all platforms
flutter pub run flutter_launcher_icons

# Generate native splash screens
flutter pub run flutter_native_splash:create

# Test the build
flutter build apk --debug
```

#### 5. Asset Locations

After generation, assets are automatically placed in:

**iOS:**
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` - App icons
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/` - Launch images
- `ios/Runner/Base.lproj/LaunchScreen.storyboard` - Launch screen layout

**Android:**
- `android/app/src/main/res/mipmap-*/` - App icons
- `android/app/src/main/res/drawable*/` - Launch screen images
- `android/app/src/main/res/values*/styles.xml` - Launch screen configuration

**Design Files:**
- `assets/app_icon_*.png` - Source icon files
- `assets/launch_screen_*.png` - Source launch screen files
- `scripts/generate_app_assets.py` - Python script to regenerate all assets

### Design Notes

- **iOS Compliance**: Icons must not have transparency (alpha channel) for App Store
- **Android Adaptive**: Uses adaptive icons with background and foreground layers
- **Android 12+**: Special splash screen API requirements handled automatically
- **Dark Mode**: Launch screens support both light and dark themes
- **Multiple Densities**: All required sizes generated automatically
- **Automated Generation**: Use the Python script for consistent results across all assets
- **Version Control**: Include both source assets and the generation script in version control


---
