#!/bin/bash

# Script to generate Android release keystore for Photo Points app

echo "Generating Android release keystore..."

# Set Java 11 for compatibility
export JAVA_HOME=/opt/homebrew/opt/openjdk@11
export PATH="$JAVA_HOME/bin:$PATH"

echo "Using Java version: $(java -version 2>&1 | head -1)"

# Create the keystore
keytool -genkeypair \
  -v \
  -keystore android/app/release-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias photopoints-release \
  -storepass photopoints2024 \
  -keypass photopoints2024 \
  -dname "CN=Photo Points, OU=Mobile Apps, O=Photo Points, L=Unknown, ST=Unknown, C=US"

if [ $? -eq 0 ]; then
    echo "✅ Keystore created successfully at android/app/release-keystore.jks"
    echo "✅ Key properties file created at android/key.properties"
    echo ""
    echo "⚠️  IMPORTANT: Keep the following information secure:"
    echo "   - Store password: photopoints2024"
    echo "   - Key password: photopoints2024"
    echo "   - Key alias: photopoints-release"
    echo ""
    echo "📝 Next steps:"
    echo "1. Add android/app/release-keystore.jks to .gitignore"
    echo "2. Add android/key.properties to .gitignore"
    echo "3. Store credentials securely for CI/CD"
else
    echo "❌ Failed to create keystore"
    echo "You may need to install a compatible Java version"
    exit 1
fi