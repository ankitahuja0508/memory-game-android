#!/bin/bash

# Memory Match - Release Build Testing Script
# This script helps verify that the release build is correctly configured

echo "🚀 Memory Match - Release Build Verification"
echo "=============================================="
echo ""

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ Error: adb not found. Please install Android SDK tools."
    exit 1
fi

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo "❌ Error: No Android device connected."
    echo "   Please connect a device via USB and enable USB debugging."
    exit 1
fi

echo "✅ Device connected"
echo ""

# Install the release APK
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ ! -f "$APK_PATH" ]; then
    echo "❌ Error: Release APK not found at $APK_PATH"
    echo "   Please run: flutter build apk --release"
    exit 1
fi

echo "📦 Installing release APK..."
adb install -r "$APK_PATH"

if [ $? -ne 0 ]; then
    echo "❌ Installation failed"
    exit 1
fi

echo "✅ APK installed successfully"
echo ""

# Launch the app
echo "🚀 Launching app..."
adb shell am start -n com.aexyn.memorymatch.memorygame/.MainActivity

sleep 3

echo ""
echo "📊 Checking ad configuration..."
echo "=============================================="
echo ""

# Capture and display ad configuration logs
adb logcat -d | grep -A 40 "AD CONFIGURATION" | tail -45

echo ""
echo "=============================================="
echo ""

echo "🔍 Key checks:"
echo ""

# Check for kReleaseMode
if adb logcat -d | grep "kReleaseMode: true" > /dev/null; then
    echo "✅ kReleaseMode: true (CORRECT)"
else
    echo "❌ kReleaseMode: false (WRONG - not built with --release)"
fi

# Check for production mode
if adb logcat -d | grep "Mode: PRODUCTION" > /dev/null; then
    echo "✅ Mode: PRODUCTION (Real Ads) (CORRECT)"
else
    echo "❌ Mode: DEBUG/TEST (Test Ads) (WRONG)"
fi

# Check for production app ID
if adb logcat -d | grep "App ID: ca-app-pub-3419805534245719" > /dev/null; then
    echo "✅ Using production AdMob App ID (CORRECT)"
else
    echo "❌ Using test AdMob App ID (WRONG)"
fi

# Check for production ad units
if adb logcat -d | grep "Type: PRODUCTION AD" > /dev/null; then
    echo "✅ Production ad units detected (CORRECT)"
else
    echo "⚠️  No production ad unit confirmation found"
fi

echo ""
echo "=============================================="
echo ""

echo "📱 App is running on your device."
echo ""
echo "Manual checks:"
echo "1. ✅ Look at banner ads - they should NOT have 'Google AdMob' text"
echo "2. ✅ Try to watch a rewarded video - should be real ads"
echo "3. ✅ Test undo power-up - move count should decrease"
echo ""

echo "📋 To view live logs:"
echo "   adb logcat | grep -E 'AD CONFIGURATION|Undo|Build Mode'"
echo ""

echo "🔄 To test undo power-up:"
echo "   1. Start a game level"
echo "   2. Make a mismatch (flip two non-matching cards)"
echo "   3. Use undo power-up"
echo "   4. Check logs: adb logcat | grep Undo"
echo ""

echo "✅ Test script complete!"
