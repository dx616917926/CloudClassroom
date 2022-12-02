#!/bin/bash

# #see http://guides.cocoapods.org/syntax/podfile.html#script_phase
# #see https://stackoverflow.com/questions/40400086/xcode-add-embedded-binary-with-buildscript/40484337#40484337

# export

# #see `BJHLMEDIAPLAYER_WEAK=1` in BaijiaYun.podspec
# if [[ $GCC_PREPROCESSOR_DEFINITIONS != *"BJHLMEDIAPLAYER_WEAK=1"* ]]; then
#     exit 0
# fi

framework_name="BJHLMediaPlayer.framework"
framework_executable="BJHLMediaPlayer"

pod_frameworks="${1:-Pods/BaijiaYun/frameworks}"
build_frameworks="$CONFIGURATION_BUILD_DIR/$FRAMEWORKS_FOLDER_PATH"

# echo "app_path: $PWD"
# echo "pod_frameworks: $pod_frameworks"
# echo "build_frameworks: $build_frameworks"

mkdir -p "$build_frameworks"
rm -rf "$build_frameworks/$framework_name"
cp -Rv "$pod_frameworks/$framework_name" "$build_frameworks/$framework_name"

code_sign="$EXPANDED_CODE_SIGN_IDENTITY"
if [ "$code_sign" = "" ] ; then
    code_sign="$EXPANDED_CODE_SIGN_IDENTITY_NAME"
fi
if [ "$code_sign" = "" ] ; then
    code_sign="$CODE_SIGN_IDENTITY"
fi
codesign --force --verbose --sign "$code_sign" "$build_frameworks/$framework_name/$framework_executable"

