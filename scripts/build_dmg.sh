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

# 1. Build the app using Tuist
echo "🚀 Building Switzy v${VERSION}..."
tuist build --configuration Release --derived-data-path "${DERIVED_DATA_PATH}"

# 2. Prepare Release Directory
mkdir -p "${RELEASE_DIR}"
rm -f "${RELEASE_DIR}/${DMG_NAME}"

# 3. Create DMG
echo "📦 Creating DMG: ${DMG_NAME}..."
TEMP_DMG="${RELEASE_DIR}/temp.dmg"

hdiutil create -volname "${PROJECT_NAME}" -srcfolder "${BUILD_DIR}/${APP_NAME}" -ov -format UDZO "${TEMP_DMG}"
mv "${TEMP_DMG}" "${RELEASE_DIR}/${DMG_NAME}"

echo "✅ DMG created successfully at: ${RELEASE_DIR}/${DMG_NAME}"
echo "📝 Remember to update appcast.xml and Homebrew formula with the new signature and sha256."
