#!/bin/bash

# Use specific simulator ID for iPhone 16 Pro with iOS 26
SIMULATOR_ID="80582076-FFC2-4DFF-B938-9A3C27B847C7"

echo "Building the app..."
xcodebuild -scheme PetMatchSwiftUI -destination "platform=iOS Simulator,id=$SIMULATOR_ID" build || exit 1

echo "Starting iPhone 16 Pro simulator..."
xcrun simctl boot "$SIMULATOR_ID" || true
sleep 5

echo "Installing and launching the app..."
APP_PATH="$(find /Users/nikfurry/Library/Developer/Xcode/DerivedData -name "PetMatchSwiftUI.app" -path "*/Debug-iphonesimulator/*" -type d | head -n 1)"

if [ -z "$APP_PATH" ]; then
    echo "Error: Could not find app in Debug-iphonesimulator directory"
    exit 1
fi

if [ ! -d "$APP_PATH" ]; then
    echo "Error: App directory not found at: $APP_PATH"
    exit 1
fi

echo "Installing app at: $APP_PATH"
xcrun simctl install "$SIMULATOR_ID" "$APP_PATH" || exit 1
echo "Waiting for installation to complete..."
sleep 2

echo "Launching app..."
xcrun simctl launch "$SIMULATOR_ID" "com.swiftui.PetMatchSwiftUI" || exit 1

# Open simulator window if not already visible
open -a Simulator

echo "Setup complete! The app should now be running in the simulator."