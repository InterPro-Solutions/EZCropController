#!/bin/sh

#  build.sh
#  
#
#  Created by Xiang Li on 6/11/21.
#  

set -e
function trap_handler {
  echo "**** Failed ****"
  exit 255
}
trap trap_handler INT TERM EXIT

MODE="$1"

if [ "$MODE" = "tests" -o "$MODE" = "all" ]; then
  echo "Running EZCropController tests."
  cd EZCropExample
  set -o pipefail && xcodebuild test -scheme EZCropExample_Swift -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 11" | xcpretty -c
  set -o pipefail && xcodebuild test -scheme EZCropExample_OC -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 11" | xcpretty -c
  success="1"
fi


if [ "$MODE" = "example" -o "$MODE" = "all" ]; then
  echo "Building & testing EZCropController Example app."
  cd EZCropExample
  set -o pipefail && xcodebuild build analyze -scheme EZCropExample_Swift -destination "platform=iOS Simulator,name=iPhone 11" CODE_SIGNING_REQUIRED=NO | xcpretty -c
  set -o pipefail && xcodebuild build analyze -scheme EZCropExample_OC -destination "platform=iOS Simulator,name=iPhone 11" CODE_SIGNING_REQUIRED=NO | xcpretty -c
  success="1"
fi

if [ "$success" = "1" ]; then
trap - EXIT
exit 0
fi

echo "Unrecognised mode '$MODE'."
