# Firebase Configuration Security Guide

## Security Issues Fixed

### 1. ✅ Firebase Configuration Files in Version Control
**Issue**: Firebase configuration files containing API keys were committed to the repository.

**Fix Applied**: 
- Removed duplicate/incorrect configuration files from root directory
- Added guidance to `.gitignore` for excluding Firebase config files
- Documented proper configuration management

**Best Practices**:
1. **For Development**: Use separate Firebase projects for dev/staging/production
2. **For CI/CD**: Store configuration files in secure environment variables or secret management systems
3. **For Teams**: Share configuration files through secure channels, not version control

### 2. ✅ Package Name Inconsistencies
**Issue**: Multiple Firebase configurations with conflicting package names were present.

**Fix Applied**: 
- Removed the incorrect root-level `google-services.json` with conflicting package names
- Kept only the correct configuration in `memory_game/android/app/google-services.json`
- Package name is now consistently: `com.aexyn.memorymatch.memorygame`

### 3. ✅ iOS Analytics Disabled
**Issue**: Firebase Analytics was disabled in iOS configuration despite being used in the app.

**Fix Applied**: 
- Updated `IS_ANALYTICS_ENABLED` from `false` to `true` in `GoogleService-Info.plist`
- Analytics will now work correctly on iOS devices

### 4. ✅ Broken Firestore Rate Limiting
**Issue**: Rate limiting rule checked for a non-existent sentinel document.

**Fix Applied**: 
- Implemented proper rate limiting using a dedicated `rateLimit` collection
- Added rules for managing rate limit documents
- Limits users to 10 leaderboard submissions per hour

## How to Properly Manage Firebase Configuration

### For New Developers

1. **Obtain Configuration Files**:
   ```bash
   # Request from team lead or download from Firebase Console:
   # Android: Project Settings > Your apps > Android app > google-services.json
   # iOS: Project Settings > Your apps > iOS app > GoogleService-Info.plist
   ```

2. **Place Files Correctly**:
   ```bash
   # Android configuration
   cp google-services.json memory_game/android/app/
   
   # iOS configuration
   cp GoogleService-Info.plist memory_game/ios/Runner/
   ```

3. **Never Commit These Files** (if using separate dev/prod projects):
   ```bash
   # Uncomment these lines in .gitignore:
   /android/app/google-services.json
   /ios/Runner/GoogleService-Info.plist
   ```

### For CI/CD Systems

1. **Store as Base64 Secrets**:
   ```bash
   # Encode files
   base64 -i google-services.json -o google-services.json.b64
   base64 -i GoogleService-Info.plist -o GoogleService-Info.plist.b64
   ```

2. **In GitHub Actions** (example):
   ```yaml
   - name: Decode Firebase Config
     env:
       GOOGLE_SERVICES_JSON: ${{ secrets.GOOGLE_SERVICES_JSON_BASE64 }}
       GOOGLE_SERVICE_INFO_PLIST: ${{ secrets.GOOGLE_SERVICE_INFO_PLIST_BASE64 }}
     run: |
       echo $GOOGLE_SERVICES_JSON | base64 --decode > memory_game/android/app/google-services.json
       echo $GOOGLE_SERVICE_INFO_PLIST | base64 --decode > memory_game/ios/Runner/GoogleService-Info.plist
   ```

### Understanding Firebase API Keys

**Important**: Firebase API keys are designed to be public and are safe to expose because:
- They are restricted by package name/bundle ID
- They are restricted by SHA-1 certificate fingerprints (Android)
- Firebase Security Rules protect your data
- Quotas and billing alerts prevent abuse

However, it's still best practice to:
- Use different Firebase projects for dev/staging/production
- Implement proper security rules (✅ Already done)
- Monitor usage in Firebase Console
- Set up billing alerts

## Updated Rate Limiting Implementation

The Firestore rules now properly implement rate limiting. To use it in your app:

```dart
// In firebase_service.dart, when submitting a score:
Future<void> submitScore({
  required int level,
  required int score,
  required int timeSeconds,
}) async {
  final userId = currentUser?.uid;
  if (userId == null) return;

  // Check/update rate limit
  final rateLimitRef = firestore.collection('rateLimit').doc(userId);
  
  await firestore.runTransaction((transaction) async {
    final rateLimitDoc = await transaction.get(rateLimitRef);
    
    final now = Timestamp.now();
    int count = 1;
    
    if (rateLimitDoc.exists) {
      final data = rateLimitDoc.data()!;
      final lastSubmission = data['lastSubmission'] as Timestamp;
      final currentCount = data['count'] as int;
      
      // If more than 1 hour has passed, reset count
      if (lastSubmission.toDate().isBefore(
        DateTime.now().subtract(const Duration(hours: 1))
      )) {
        count = 1;
      } else if (currentCount < 10) {
        count = currentCount + 1;
      } else {
        throw Exception('Rate limit exceeded. Please try again later.');
      }
    }
    
    // Update rate limit
    transaction.set(rateLimitRef, {
      'count': count,
      'lastSubmission': now,
    });
    
    // Submit score
    final scoreRef = firestore.collection('leaderboard').doc();
    transaction.set(scoreRef, {
      'userId': userId,
      'level': level,
      'score': score,
      'timeSeconds': timeSeconds,
      'timestamp': now,
    });
  });
}
```

## Security Checklist

- [x] Remove duplicate/incorrect Firebase configuration files
- [x] Fix package name inconsistencies
- [x] Enable iOS Analytics
- [x] Implement proper rate limiting in Firestore rules
- [x] Document security best practices
- [ ] Set up Firebase App Check (recommended for production)
- [ ] Configure domain restrictions for web API keys
- [ ] Set up billing alerts in Firebase Console
- [ ] Implement server-side validation for critical operations

## Additional Recommendations

1. **Firebase App Check**: Enable App Check to verify requests come from your app
2. **Environment Management**: Use `flutter_dotenv` for managing different environments
3. **Security Rules Testing**: Write unit tests for Firestore security rules
4. **Monitoring**: Set up Firebase Performance Monitoring and Crashlytics alerts

## Resources

- [Firebase Security Best Practices](https://firebase.google.com/docs/projects/learn-more#best-practices)
- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase App Check](https://firebase.google.com/docs/app-check)
- [API Key Restrictions](https://cloud.google.com/docs/authentication/api-keys#api_key_restrictions)
