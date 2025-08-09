#!/bin/bash

# Version bump script for Photo Points app
# Usage: ./bump_version.sh [major|minor|patch|build]

set -e

VERSION_FILE="pubspec.yaml"

# Function to get current version
get_current_version() {
    grep "version:" $VERSION_FILE | awk '{print $2}'
}

# Function to extract version components
extract_version() {
    local version=$1
    VERSION_PART=$(echo $version | cut -d'+' -f1)
    BUILD_PART=$(echo $version | cut -d'+' -f2)

    MAJOR=$(echo $VERSION_PART | cut -d'.' -f1)
    MINOR=$(echo $VERSION_PART | cut -d'.' -f2)
    PATCH=$(echo $VERSION_PART | cut -d'.' -f3)
    BUILD=$BUILD_PART
}

# Function to update version in pubspec.yaml
update_version() {
    local new_version=$1
    local new_build=$2

    sed -i '' "s/version: .*/version: $new_version+$new_build/" $VERSION_FILE
    echo "✅ Updated version to: $new_version+$new_build"
}

# Main script
CURRENT_VERSION=$(get_current_version)
echo "Current version: $CURRENT_VERSION"

extract_version $CURRENT_VERSION

BUMP_TYPE=${1:-build}

case $BUMP_TYPE in
    "major")
        NEW_MAJOR=$((MAJOR + 1))
        NEW_VERSION="$NEW_MAJOR.0.0"
        NEW_BUILD=1
        ;;
    "minor")
        NEW_MINOR=$((MINOR + 1))
        NEW_VERSION="$MAJOR.$NEW_MINOR.0"
        NEW_BUILD=1
        ;;
    "patch")
        NEW_PATCH=$((PATCH + 1))
        NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH"
        NEW_BUILD=1
        ;;
    "build")
        NEW_VERSION="$MAJOR.$MINOR.$PATCH"
        NEW_BUILD=$((BUILD + 1))
        ;;
    *)
        echo "❌ Invalid bump type: $BUMP_TYPE"
        echo "Usage: $0 [major|minor|patch|build]"
        exit 1
        ;;
esac

update_version $NEW_VERSION $NEW_BUILD

echo ""
echo "📝 Next steps:"
echo "1. Test the app with the new version"
echo "2. Build release: flutter build apk --release"
echo "3. Commit changes: git add . && git commit -m 'Bump version to $NEW_VERSION+$NEW_BUILD'"
echo "4. Tag release: git tag v$NEW_VERSION"
