#!/bin/bash

# Verification Script for Production Ads
# Run this after installing the new release APK

echo "🔍 Memory Match - Production Ads Verification"
echo "=============================================="
echo ""

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ Error: adb not found"
    exit 1
fi

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo "❌ Error: No device connected"
    exit 1
fi

echo "✅ Device connected"
echo ""

# Check if app is installed
if ! adb shell pm list packages | grep -q "com.aexyn.memorymatch.memorygame"; then
    echo "❌ App not installed!"
    echo "   Run: adb install build/app/outputs/flutter-apk/app-release.apk"
    exit 1
fi

echo "✅ App is installed"
echo ""

# Clear logs
echo "📋 Clearing old logs..."
adb logcat -c

# Launch app
echo "🚀 Launching app..."
adb shell am start -n com.aexyn.memorymatch.memorygame/.MainActivity

# Wait for initialization
echo "⏳ Waiting for app to initialize (5 seconds)..."
sleep 5

echo ""
echo "=============================================="
echo "📊 VERIFICATION RESULTS"
echo "=============================================="
echo ""

# Check for production ad success message
if adb logcat -d | grep -q "PRODUCTION ADS CONFIGURED"; then
    echo "✅✅✅ SUCCESS! PRODUCTION ADS CONFIGURED ✅✅✅"
    echo ""
    adb logcat -d | grep -A 5 "PRODUCTION ADS CONFIGURED"
    echo ""
    echo "🎉 Your app is ready for Play Store!"
    echo "📝 Note: Real ads may take 1-2 hours to start showing"
    RESULT=0
elif adb logcat -d | grep -q "CRITICAL WARNING: USING TEST ADS"; then
    echo "❌❌❌ PROBLEM! TEST ADS DETECTED ❌❌❌"
    echo ""
    adb logcat -d | grep -A 5 "CRITICAL WARNING"
    echo ""
    echo "⚠️  DO NOT PUBLISH TO PLAY STORE!"
    echo "⚠️  Please share the logs with the developer"
    RESULT=1
else
    echo "⚠️  Could not find ad configuration in logs"
    echo "   The app may not have initialized ads yet"
    echo ""
    echo "Try running this command manually:"
    echo "adb logcat -d | grep -A 50 'AD CONFIGURATION'"
    RESULT=2
fi

echo ""
echo "=============================================="
echo "🔍 DETAILED BUILD MODE INFO"
echo "=============================================="
adb logcat -d | grep -E "kReleaseMode|kDebugMode|isProduction" | head -5

echo ""
echo "=============================================="
echo "🔑 APP ID VERIFICATION"
echo "=============================================="
adb logcat -d | grep "App ID:" | head -1

if adb logcat -d | grep "App ID:" | grep -q "3940256099942544"; then
    echo "❌ Using TEST App ID (Google's test ID)"
elif adb logcat -d | grep "App ID:" | grep -q "3419805534245719"; then
    echo "✅ Using PRODUCTION App ID (your real ID)"
fi

echo ""
echo "=============================================="
echo "📱 MANUAL VERIFICATION STEPS"
echo "=============================================="
echo ""
echo "1. Look at the banner ads in your app"
echo "   ❌ If you see 'Test Ad' label → PROBLEM"
echo "   ✅ If you see real company ads → SUCCESS"
echo "   ⚠️  If you see no ads → NORMAL (wait 1-2 hours)"
echo ""
echo "2. Check the app now - do you see 'Test Ad' labels?"
echo ""
echo "=============================================="
echo ""

if [ $RESULT -eq 0 ]; then
    echo "✅ Verification PASSED! Ready for Play Store!"
elif [ $RESULT -eq 1 ]; then
    echo "❌ Verification FAILED! Do not upload to Play Store!"
    echo ""
    echo "📋 To save full logs for debugging:"
    echo "adb logcat -d > ad_verification_logs.txt"
fi

exit $RESULT
