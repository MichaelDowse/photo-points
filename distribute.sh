#!/bin/bash

# distribute.sh - Automated Firebase distribution for Photo Points app
# Usage: ./distribute.sh [android|ios] "Release notes"

set -e

# Configuration
PLATFORM=${1:-android}
RELEASE_NOTES=${2:-"Latest build from $(date)"}

# Firebase App IDs - Update these with your actual Firebase app IDs
ANDROID_APP_ID="YOUR_ANDROID_APP_ID"
IOS_APP_ID="YOUR_IOS_APP_ID"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Firebase CLI is installed
check_firebase_cli() {
    if ! command -v firebase &> /dev/null; then
        log_error "Firebase CLI is not installed. Please install it with: npm install -g firebase-tools"
        exit 1
    fi
}

# Check if user is logged in to Firebase
check_firebase_auth() {
    if ! firebase projects:list &> /dev/null; then
        log_error "Not logged in to Firebase. Please run: firebase login"
        exit 1
    fi
}

# Set Java environment for Android builds
setup_java_env() {
    if [ "$PLATFORM" = "android" ]; then
        export JAVA_HOME=/opt/homebrew/opt/openjdk@11
        export PATH="$JAVA_HOME/bin:$PATH"

        # Verify Java 11
        if ! java -version 2>&1 | grep -q "11\."; then
            log_error "Java 11 is required for Android builds. Please install with: brew install openjdk@11"
            exit 1
        fi

        log_success "Java 11 environment configured"
    fi
}

# Update Firebase App IDs check
check_firebase_config() {
    if [ "$PLATFORM" = "android" ] && [ "$ANDROID_APP_ID" = "YOUR_ANDROID_APP_ID" ]; then
        log_error "Please update ANDROID_APP_ID in this script with your actual Firebase Android app ID"
        log_info "Get your app ID from Firebase Console > Project Settings > General > Your Apps"
        exit 1
    fi

    if [ "$PLATFORM" = "ios" ] && [ "$IOS_APP_ID" = "YOUR_IOS_APP_ID" ]; then
        log_error "Please update IOS_APP_ID in this script with your actual Firebase iOS app ID"
        log_info "Get your app ID from Firebase Console > Project Settings > General > Your Apps"
        exit 1
    fi
}

# Check if keystore exists for Android
check_keystore() {
    if [ "$PLATFORM" = "android" ]; then
        if [ ! -f "android/app/release-keystore.jks" ]; then
            log_error "Release keystore not found. Please run: ./generate_keystore.sh"
            exit 1
        fi

        if [ ! -f "android/key.properties" ]; then
            log_error "Key properties file not found. Please run: ./generate_keystore.sh"
            exit 1
        fi

        log_success "Release keystore found"
    fi
}

# Check iOS signing setup
check_ios_signing() {
    if [ "$PLATFORM" = "ios" ]; then
        # Check if on macOS
        if [[ "$OSTYPE" != "darwin"* ]]; then
            log_error "iOS builds require macOS. Current OS: $OSTYPE"
            exit 1
        fi

        # Check if Xcode is installed
        if ! command -v xcodebuild &> /dev/null; then
            log_error "Xcode is not installed. Please install Xcode from the App Store."
            exit 1
        fi

        # Check if iOS workspace exists
        if [ ! -f "ios/Runner.xcworkspace/contents.xcworkspacedata" ]; then
            log_error "iOS workspace not found. Please run: cd ios && pod install"
            exit 1
        fi

        log_success "iOS build environment verified"
    fi
}

# Check if export options plist exists for iOS
check_export_options() {
    if [ "$PLATFORM" = "ios" ]; then
        if [ ! -f "ios/exportOptions.plist" ]; then
            log_warning "iOS export options not found. Will use manual archive process."
            return 1
        fi

        # Validate exportOptions.plist content
        if ! plutil -lint ios/exportOptions.plist &> /dev/null; then
            log_error "Invalid exportOptions.plist format. Please check the file."
            exit 1
        fi

        log_success "iOS export options found"
        return 0
    fi
}

# Build iOS IPA automatically
build_ios_ipa() {
    log_info "🔨 Building iOS IPA..."

    # Try automated build first
    if check_export_options; then
        log_info "Using automated IPA build with export options..."

        if flutter build ipa --release --export-options-plist=ios/exportOptions.plist; then
            IPA_PATH="build/ios/ipa/photopoints.ipa"

            if [ -f "$IPA_PATH" ]; then
                log_success "IPA built successfully: $IPA_PATH"
                return 0
            else
                log_error "IPA build succeeded but file not found at: $IPA_PATH"
                return 1
            fi
        else
            log_error "Automated IPA build failed"
            return 1
        fi
    else
        log_info "Export options not available, falling back to manual process"
        return 1
    fi
}

# Manual iOS archive process
manual_ios_archive() {
    log_info "📱 Starting manual iOS archive process..."

    # Build iOS project
    flutter build ios --release

    log_info "Opening Xcode workspace..."
    open ios/Runner.xcworkspace

    log_warning "Manual steps required in Xcode:"
    log_info "1. Wait for Xcode to open and index"
    log_info "2. Select 'Any iOS Device' or a connected device"
    log_info "3. Go to Product → Archive"
    log_info "4. Once archived, click 'Distribute App'"
    log_info "5. Choose 'Ad Hoc' for Firebase App Distribution"
    log_info "6. Select your provisioning profile"
    log_info "7. Export the IPA file"
    log_info "8. Note the IPA file path"

    echo ""
    log_warning "After exporting the IPA in Xcode, run:"
    echo "firebase appdistribution:distribute \\"
    echo "  path/to/your/exported.ipa \\"
    echo "  --app $IOS_APP_ID \\"
    echo "  --groups \"testers\" \\"
    echo "  --release-notes \"$RELEASE_NOTES (Version: $NEW_VERSION)\""
    echo ""

    log_info "Press Enter when you have exported the IPA and want to continue..."
    read -r

    log_info "Please enter the path to your exported IPA file:"
    read -r IPA_PATH

    if [ ! -f "$IPA_PATH" ]; then
        log_error "IPA file not found at: $IPA_PATH"
        exit 1
    fi

    log_success "IPA file located: $IPA_PATH"
    echo "$IPA_PATH"
}

# Main distribution function
main() {
    log_info "🚀 Starting distribution process for $PLATFORM..."

    # Validation checks
    check_firebase_cli
    check_firebase_auth
    check_firebase_config
    setup_java_env
    check_keystore
    check_ios_signing

    # 1. Update version
    log_info "📝 Updating version..."
    if [ ! -f "bump_version.sh" ]; then
        log_error "bump_version.sh not found. Please ensure it exists and is executable."
        exit 1
    fi

    ./bump_version.sh build

    # Get the new version
    NEW_VERSION=$(grep "version:" pubspec.yaml | awk '{print $2}')
    log_success "Version updated to: $NEW_VERSION"

    # 2. Build release
    log_info "🔨 Building release..."

    if [ "$PLATFORM" = "android" ]; then
        # Build Android APK
        flutter build apk --release

        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

        # Verify APK exists
        if [ ! -f "$APK_PATH" ]; then
            log_error "APK build failed. APK not found at: $APK_PATH"
            exit 1
        fi

        # Verify APK is signed
        log_info "🔍 Verifying APK signature..."
        if jarsigner -verify "$APK_PATH" &> /dev/null; then
            log_success "APK is properly signed"
        else
            log_error "APK signature verification failed"
            exit 1
        fi

        # 3. Distribute to Firebase
        log_info "📤 Distributing to Firebase App Distribution..."

        firebase appdistribution:distribute \
            "$APK_PATH" \
            --app "$ANDROID_APP_ID" \
            --groups "testers" \
            --release-notes "$RELEASE_NOTES (Version: $NEW_VERSION)"

        log_success "Android APK distributed successfully!"
        log_info "📱 Testers will receive an email notification with download link"

    elif [ "$PLATFORM" = "ios" ]; then
        # Build iOS - try automated first, fall back to manual
        if build_ios_ipa; then
            # Automated build succeeded
            IPA_PATH="build/ios/ipa/photopoints.ipa"

            log_info "📤 Distributing iOS IPA to Firebase App Distribution..."

            firebase appdistribution:distribute \
                "$IPA_PATH" \
                --app "$IOS_APP_ID" \
                --groups "testers" \
                --release-notes "$RELEASE_NOTES (Version: $NEW_VERSION)"

            log_success "iOS IPA distributed successfully!"
            log_info "📱 Testers will receive an email notification with download link"
        else
            # Automated build failed, use manual process
            log_warning "Automated build failed, using manual archive process..."

            IPA_PATH=$(manual_ios_archive)

            if [ -n "$IPA_PATH" ] && [ -f "$IPA_PATH" ]; then
                log_info "📤 Distributing iOS IPA to Firebase App Distribution..."

                firebase appdistribution:distribute \
                    "$IPA_PATH" \
                    --app "$IOS_APP_ID" \
                    --groups "testers" \
                    --release-notes "$RELEASE_NOTES (Version: $NEW_VERSION)"

                log_success "iOS IPA distributed successfully!"
                log_info "📱 Testers will receive an email notification with download link"
            else
                log_error "Failed to locate IPA file for distribution"
                exit 1
            fi
        fi

    else
        log_error "Invalid platform: $PLATFORM. Use 'android' or 'ios'"
        exit 1
    fi

    # 4. Post-distribution tasks
    log_info "📋 Post-distribution tasks:"
    log_info "- Monitor Firebase console for crash reports"
    log_info "- Collect feedback from testers"
    log_info "- Consider tagging this release: git tag v$NEW_VERSION"

    log_success "✅ Distribution process complete!"
}

# Show usage if no arguments provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [android|ios] [\"Release notes\"]"
    echo ""
    echo "Examples:"
    echo "  $0 android \"Fixed camera permissions bug\""
    echo "  $0 ios \"Updated GPS accuracy\""
    echo "  $0 android  # Uses default release notes"
    echo ""
    echo "Before running this script:"
    echo "1. Update ANDROID_APP_ID and IOS_APP_ID in this script"
    echo "2. Ensure you're logged in to Firebase: firebase login"
    echo "3. Ensure Firebase project is configured: firebase init"
    echo "4. For Android: Ensure keystore exists: ./generate_keystore.sh"
    exit 1
fi

# Run main function
main "$@"
