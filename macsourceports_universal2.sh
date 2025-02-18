# game/app specific values
export APP_VERSION="1.11.0"
export ICONSDIR="stuff"
export ICONSFILENAME="quake2"
export PRODUCT_NAME="yquake2"
export EXECUTABLE_NAME="quake2"
export PKGINFO="APPLGYQ2"
export COPYRIGHT_TEXT="Quake II Copyright © 1997-2012 id Software, Inc. All rights reserved."

#constants
source ../MSPScripts/constants.sh

rm -rf ${BUILT_PRODUCTS_DIR}

ARM64_CFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/openal-soft/include -mmacosx-version-min=10.9"
ARM64_LDFLAGS="-L/opt/homebrew/lib -L/opt/homebrew/opt/openal-soft/lib -mmacosx-version-min=10.9"
x86_64_CFLAGS="-mmacosx-version-min=10.9"
x86_64_LDFLAGS="-mmacosx-version-min=10.9"

(YQ2_ARCH=x86_64 make clean) || exit 1;
(YQ2_ARCH=x86_64 CFLAGS=$x86_64_CFLAGS  LDFLAGS=$x86_64_LDFLAGS make -j$NCPU) || exit 1;
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv release/* ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
rm -rd release

(YQ2_ARCH=arm64 make clean) || exit 1;
(YQ2_ARCH=arm64 CFLAGS=$ARM64_CFLAGS  LDFLAGS=$ARM64_LDFLAGS make -j$NCPU) || exit 1;
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv release/* ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
rm -rd release

# create the app bundle
"../MSPScripts/build_app_bundle.sh"

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/baseq2" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/baseq2" || exit 1;
fi

#dylibbundler the quake2 libs
dylibbundler -od -b -x ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib -d ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/ -p @executable_path/${X86_64_LIBS_FOLDER}/
dylibbundler -od -b -x ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib -d ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/ -p @executable_path/${X86_64_LIBS_FOLDER}/
dylibbundler -od -b -x ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib -d ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/ -p @executable_path/${X86_64_LIBS_FOLDER}/
dylibbundler -od -b -x ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/baseq2/game.dylib -d ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/ -p @executable_path/${X86_64_LIBS_FOLDER}/
dylibbundler -od -b -x ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib -d ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/ -p @executable_path/${ARM64_LIBS_FOLDER}/
dylibbundler -od -b -x ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib -d ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/ -p @executable_path/${ARM64_LIBS_FOLDER}/
dylibbundler -od -b -x ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib -d ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/ -p @executable_path/${ARM64_LIBS_FOLDER}/
dylibbundler -od -b -x ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/baseq2/game.dylib -d ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/ -p @executable_path/${ARM64_LIBS_FOLDER}/

#lipo any app-specific things
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/baseq2/game.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/baseq2/game.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/baseq2/game.dylib" -create

"../MSPScripts/sign_and_notarize.sh" "$1"