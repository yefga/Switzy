#!/bin/bash

# build_dmg.sh
# Automate building Switzy and creating a compressed DMG.

set -e

# Configuration
PROJECT_NAME="Switzy"
RELEASE_DIR="release"
DERIVED_DATA_PATH="DerivedData"
BUILD_DIR="${DERIVED_DATA_PATH}/Build/Products/Release"
VERSION=$(grep "MARKETING_VERSION =" Configs/Project.xcconfig | cut -d "=" -f 2 | xargs)
DMG_NAME="${PROJECT_NAME}-v${VERSION}.dmg"
APP_NAME="${PROJECT_NAME}.app"
SIGNING_IDENTITY="Developer ID Application: YG25GXN392"
NOTARY_PROFILE="notary-profile"

# 1. Build the app using Tuist
echo "🚀 Building Switzy v${VERSION}..."
tuist build --configuration Release --derived-data-path "${DERIVED_DATA_PATH}"

# 2. Prepare Release Directory
mkdir -p "${RELEASE_DIR}"
rm -f "${RELEASE_DIR}/${DMG_NAME}"

# 3. Codesign the App
echo "🔏 Codesigning .app..."
codesign --force --options runtime --deep --sign "${SIGNING_IDENTITY}" "${BUILD_DIR}/${APP_NAME}"

# 4. Create DMG
echo "📦 Creating DMG: ${DMG_NAME}..."
TEMP_DMG="${RELEASE_DIR}/temp.dmg"

hdiutil create -volname "${PROJECT_NAME}" -srcfolder "${BUILD_DIR}/${APP_NAME}" -ov -format UDZO "${TEMP_DMG}"
mv "${TEMP_DMG}" "${RELEASE_DIR}/${DMG_NAME}"

# 5. Codesign the DMG
echo "🔏 Codesigning DMG..."
codesign --force --sign "${SIGNING_IDENTITY}" "${RELEASE_DIR}/${DMG_NAME}"

# 6. Notarize the DMG
echo "☁️ Submitting for Notarization..."
xcrun notarytool submit "${RELEASE_DIR}/${DMG_NAME}" --keychain-profile "${NOTARY_PROFILE}" --wait

# 7. Staple the Ticket
echo "🏷️ Stapling Notarization ticket..."
xcrun stapler staple "${RELEASE_DIR}/${DMG_NAME}"

echo "✅ Signed and Notarized DMG created successfully at: ${RELEASE_DIR}/${DMG_NAME}"
echo "📝 Remember to update appcast.xml and Homebrew formula with the new signature and sha256."
