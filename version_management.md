# Version Management for Photo Points App

## Current Version
- **App Version**: 1.0.0+2
- **Build Number**: 2

## Version Format
Flutter uses semantic versioning with the format: `major.minor.patch+build`

### Version Components
- **Major**: Incremented for breaking changes or major new features
- **Minor**: Incremented for new features that are backward compatible
- **Patch**: Incremented for bug fixes
- **Build**: Incremented for each build/release

## Release Process

### 1. Version Bumping
Before creating a release, update the version in `pubspec.yaml`:

```yaml
version: 1.0.0+2  # Format: major.minor.patch+build
```

### 2. Build Commands
```bash
# Debug build
flutter build apk --debug

# Release build (requires keystore)
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release
```

### 3. Version History
- **1.0.0+1**: Initial version
- **1.0.0+2**: Release setup with signing configuration

## Automated Version Management

### Option 1: Manual Version Updates
Update `pubspec.yaml` manually before each release.

### Option 2: CI/CD Integration
For automated releases, use:
```bash
# Increment build number
flutter build apk --build-number=$BUILD_NUMBER

# Or set version directly
flutter build apk --build-name=1.0.1 --build-number=3
```

### Option 3: Version Management Script
Create a script to automate version bumping:

```bash
#!/bin/bash
# bump_version.sh
CURRENT_VERSION=$(grep "version:" pubspec.yaml | awk '{print $2}')
echo "Current version: $CURRENT_VERSION"

# Extract build number and increment
BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f2)
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))

# Update version
sed -i '' "s/version: .*/version: 1.0.0+$NEW_BUILD_NUMBER/" pubspec.yaml
echo "Updated to version: 1.0.0+$NEW_BUILD_NUMBER"
```

## Release Checklist
- [ ] Update version in pubspec.yaml
- [ ] Test app thoroughly
- [ ] Build release APK/AAB
- [ ] Test release build
- [ ] Tag release in git
- [ ] Upload to Play Store/App Store
- [ ] Update release notes
