# game/app specific values
export APP_VERSION="1.11.0"
export ICONSDIR="stuff"
export ICONSFILENAME="quake2.icns"
export PRODUCT_NAME="yquake2"
export EXECUTABLE_NAME="quake2"
export PKGINFO="APPLGYQ2"
export COPYRIGHT_TEXT="Quake II Copyright © 1997-2012 id Software, Inc. All rights reserved."

# non-app speficic values
export WRAPPER_EXTENSION="app"
export WRAPPER_NAME="${PRODUCT_NAME}.${WRAPPER_EXTENSION}"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export BUILT_PRODUCTS_DIR="release"
export ICONS="${ICONSFILENAME}.ICONSFILENAME"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"

#!/bin/bash
APP_VERSION="1.11.0"

CURRENT_ARCH=$(uname -m)
echo "CURRENT_ARCH: $CURRENT_ARCH"

# For parallel make on multicore boxes...
NCPU=`sysctl -n hw.ncpu`

# make the thing
rm -rf "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"

# For parallel make on multicore boxes...
NCPU=`sysctl -n hw.ncpu`
ARM64_CFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/openal-soft/include"
ARM64_LDFLAGS="-L/opt/homebrew/lib -L/opt/homebrew/opt/openal-soft/lib"
x86_64_CFLAGS=""
x86_64_LDFLAGS=""

(YQ2_ARCH=x86_64 make clean) || exit 1;
(YQ2_ARCH=arm64 make clean) || exit 1;
(YQ2_ARCH=x86_64 CFLAGS=$x86_64_CFLAGS  LDFLAGS=$x86_64_LDFLAGS make -j$NCPU) || exit 1;
(YQ2_ARCH=arm64 CFLAGS=$ARM64_CFLAGS  LDFLAGS=$ARM64_LDFLAGS make -j$NCPU) || exit 1;

# here we go
echo "Creating bundle '${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}'"

# make the application bundle directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" || exit 1;
fi
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/baseq2" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/baseq2" || exit 1;
fi
if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" || exit 1;
fi

# copy and generate some application bundle resources
lipo release-x86_64/quake2 release-arm64/quake2 -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/quake2" -create
lipo release-x86_64/ref_gl1.dylib release-arm64/ref_gl1.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib" -create
lipo release-x86_64/ref_gl3.dylib release-arm64/ref_gl3.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib" -create
lipo release-x86_64/ref_soft.dylib release-arm64/ref_soft.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib" -create
lipo release-x86_64/baseq2/game.dylib release-arm64/baseq2/game.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/baseq2/game.dylib" -create

cp /Users/tomkidd/Documents/GitHub/MSPStore/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"

cp ${ICONSDIR}/${ICONSFILENAME} "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/$ICONSFILENAME" || exit 1;
echo -n ${PKGINFO} > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/PkgInfo" || exit 1;

# use install_name tool to point executable to bundled resources (probably wrong long term way to do it)
#modify yquake2 x86_64
install_name_tool -change /usr/local/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -change /usr/local/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib
install_name_tool -change /usr/local/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib
install_name_tool -change /usr/local/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib

#modify yquake2 arm64
install_name_tool -change /opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -change /opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib
install_name_tool -change /opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib
install_name_tool -change /opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib

# create Info.Plist
PLIST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${EXECUTABLE_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>quake2</string>
    <key>CFBundleIdentifier</key>
    <string>com.macsourceports.${PRODUCT_NAME}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${PRODUCT_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION}</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>${APP_VERSION}</string>
    <key>CGDisableCoalescedUpdates</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>10.7</string>
    <key>LSMinimumSystemVersionByArchitecture</key>
    <dict>
        <key>x86_64</key>
        <string>10.7</string>
        <key>arm64</key>
        <string>11.0</string>
    </dict>
	<key>NSHumanReadableCopyright</key>
    <string>QUAKE II Copyright © 1997-2021 id Software, Inc. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <false/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
</dict>
</plist>
"
echo "${PLIST}" > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

echo "bundle done."


"../MSPScripts/sign_and_notarize.sh" "$1"