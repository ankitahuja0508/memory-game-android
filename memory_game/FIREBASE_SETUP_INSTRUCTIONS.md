# 🔥 Firebase Setup Instructions

Firebase has been **integrated into your Android app**! Here's what you need to do in Firebase Console to enable all features.

---

## ✅ What's Already Done

- ✅ `google-services.json` added to `android/app/`
- ✅ Firebase packages installed in `pubspec.yaml`
- ✅ Gradle configured for Firebase
- ✅ Firebase service created with analytics, auth, and Firestore
- ✅ App initialized with Firebase on startup
- ✅ Internet permissions added to AndroidManifest

---

## 📋 What YOU Need to Do in Firebase Console

### Step 1: Enable Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **"memory-match---brain-training"**
3. Click **"Authentication"** in the left sidebar
4. Click **"Get started"**
5. Under **"Sign-in method"** tab:
   - Enable **"Anonymous"** (allows users to play without account)
   - Click on **"Anonymous"** → Toggle **"Enable"** → Save

**Why?** The app uses anonymous authentication to save player data to the cloud without requiring email/password.

---

### Step 2: Enable Cloud Firestore

1. In Firebase Console, click **"Firestore Database"**
2. Click **"Create database"**
3. **Choose location:**
   - Select a region close to your users (e.g., `us-central` for USA, `asia-south1` for India)
4. **Security rules:** Start in **"Test mode"** (allows read/write for 30 days)
   - We'll set proper rules later
5. Click **"Enable"**

**Why?** Firestore stores:
- Player progress and stats
- Leaderboards
- Achievement data
- Cross-device sync

---

### Step 3: Set Firestore Security Rules

After enabling Firestore, set up proper security rules:

1. Go to **Firestore Database** → **Rules** tab
2. Replace the rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Players can read/write their own data
    match /players/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read leaderboards, but only authenticated users can write their own scores
    match /leaderboard/{scoreId} {
      allow read: if true;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if false;
    }
  }
}
```

3. Click **"Publish"**

**Why?** These rules ensure users can only modify their own data and prevent cheating.

---

### Step 4: Enable Analytics & Crashlytics

#### Analytics (Auto-enabled with Firebase)
1. Go to **Analytics** → **Events**
2. You'll see events start appearing once users play the game

**Events tracked:**
- `level_complete` - When a level is finished
- `power_up_used` - When player uses a power-up
- `achievement_unlocked` - When player earns an achievement
- `theme_unlocked` - When player unlocks a new theme

#### Crashlytics
1. Go to **Crashlytics** in Firebase Console
2. Click **"Enable Crashlytics"**
3. That's it! Crashes will be automatically reported

**Why?** Analytics helps you understand player behavior, and Crashlytics helps you fix bugs.

---

### Step 5: Create Firestore Indexes (For Leaderboards)

1. Go to **Firestore Database** → **Indexes** tab
2. Click **"Create Index"**
3. Set up composite index for leaderboard queries:
   - **Collection ID:** `leaderboard`
   - **Fields to index:**
     - `level` → Ascending
     - `score` → Descending
     - `timeSeconds` → Ascending
   - **Query scope:** Collection
4. Click **"Create"**

**Note:** You might also see auto-generated index suggestions when you run the app and query the leaderboard. Just click the link in the error message to auto-create the index.

**Why?** Firestore requires indexes for complex queries (like sorting by multiple fields).

---

## 🎮 Firebase Features Now Available

### 1. **Cloud Save/Sync**
Players' progress automatically syncs across devices when they're online.

### 2. **Leaderboards**
Top scores for each level are stored in Firestore and can be displayed in-game.

### 3. **Analytics**
Track:
- Which levels are most popular
- Power-up usage patterns
- Achievement completion rates
- Player retention metrics

### 4. **Crash Reporting**
Automatically capture and report crashes to help you fix bugs.

### 5. **Anonymous Authentication**
Players can save data without creating an account.

---

## 🧪 Testing Firebase Integration

### Test Authentication
1. Run your app on a device/emulator
2. Check logs for: `✅ Firebase initialized successfully`
3. Player will be automatically signed in anonymously

### Test Firestore
1. Play a level and complete it
2. Go to Firebase Console → Firestore Database
3. You should see collections:
   - `players` → Contains player data
   - `leaderboard` → Contains scores

### Test Analytics
1. Play the game for a few minutes
2. Go to Firebase Console → Analytics → Events
3. Events should appear within 24 hours (debug events show faster)

---

## 📊 Firebase Dashboard Overview

### Key Metrics to Monitor:

**Analytics → Dashboard:**
- Daily Active Users (DAU)
- User retention
- Average session duration

**Analytics → Events:**
- `level_complete` - See which levels are popular
- `power_up_used` - See which power-ups are used most
- `achievement_unlocked` - Track achievement progress

**Crashlytics:**
- Crash-free users %
- Most common crashes

**Firestore → Usage:**
- Read/write operations
- Storage used

---

## 💰 Firebase Free Tier Limits

Firebase has a generous free tier:

| Service | Free Tier Limit | Notes |
|---------|----------------|-------|
| **Authentication** | Unlimited | Free forever |
| **Firestore** | 50K reads/day, 20K writes/day | 1GB storage free |
| **Analytics** | Unlimited | Free forever |
| **Crashlytics** | Unlimited | Free forever |
| **Cloud Functions** | 2M invocations/month | If you add them later |

**For a casual game:** You'll likely stay within free tier for months!

**If you exceed:** Firebase will notify you. You can set spending alerts.

---

## 🚨 Important Security Notes

### 1. API Key is Public
The API key in `google-services.json` is **meant to be public**. It only identifies your Firebase project, not authorize access. Security is enforced through Firestore rules.

### 2. Protect Sensitive Operations
If you add premium features later (IAP, etc.), use **Firebase Functions** to validate purchases server-side.

### 3. Monitor Usage
Set up billing alerts in Firebase Console → Settings → Usage and billing → Budgets.

---

## 📱 Next Steps (Optional)

### Enable More Features Later:

1. **Cloud Functions** - Server-side logic for anti-cheat, IAP validation
2. **Remote Config** - Change game parameters without app updates
3. **Cloud Messaging** - Push notifications for daily rewards
4. **Dynamic Links** - Share levels with friends
5. **A/B Testing** - Test different reward amounts

---

## ✅ Checklist

- [ ] Enable Anonymous Authentication
- [ ] Create Firestore Database
- [ ] Set Firestore Security Rules
- [ ] Enable Crashlytics
- [ ] Create Firestore Indexes for leaderboards
- [ ] Test app and verify data in Firestore
- [ ] Check Analytics events (24h later)
- [ ] Set up billing alerts

---

## 🆘 Troubleshooting

### "Firebase initialization failed"
- Verify `google-services.json` is in `android/app/`
- Run `flutter clean && flutter pub get`
- Rebuild the app

### "Permission denied" errors in Firestore
- Check Firestore Security Rules are published
- Verify authentication is working (check logs for user ID)

### Analytics events not showing
- Events can take up to 24 hours to appear
- For faster testing, use Firebase Debug View

### Leaderboard queries fail
- Create the composite index (see Step 5)
- Or click the link in the error message to auto-create

---

## 📞 Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

---

**🎉 You're all set! Complete the checklist above and your Firebase integration will be live!**

