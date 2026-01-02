# 🔒 Firestore Security Rules - Production Ready

This document explains the production-level security rules for your Memory Match game.

---

## 📋 Quick Deployment

### Option 1: Deploy via Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **"memory-match---brain-training"**
3. Click **Firestore Database** → **Rules** tab
4. Copy the entire contents of `firestore.rules` file
5. Paste into the rules editor
6. Click **"Publish"**

### Option 2: Deploy via Firebase CLI

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
cd /path/to/memory_game
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

---

## 🛡️ Security Features

### 1. **User Data Protection**
- Users can ONLY read/write their own data
- Player data is validated for type and range
- Prevents negative values (coins, gems, etc.)

### 2. **Anti-Cheat Measures**

| Field | Max Value | Max Increase Per Update |
|-------|-----------|------------------------|
| Coins | 10,000,000 | +10,000 per update |
| Gems | 100,000 | +500 per update |
| Level | 10,000 | +100 per update |
| Score (leaderboard) | 1,000,000 | N/A (immutable) |

**Why these limits?**
- Prevents players from editing client-side data to give themselves unlimited resources
- Limits ensure realistic progression even if someone hacks the client

### 3. **Timestamp Validation**
- All timestamps must be within 5 minutes of server time
- Prevents backdating or future-dating events
- Protects against time manipulation exploits

### 4. **Rate Limiting**
- Leaderboard: Max 100 submissions per user
- Prevents spam and DDoS attacks on your database

### 5. **Immutable Data**
- Achievements can't be deleted once unlocked
- Leaderboard scores can't be modified or deleted
- Daily rewards are write-once
- Purchases are write-once (updated only by Cloud Functions)

### 6. **Public Leaderboards**
- Anyone can read leaderboard (no auth required)
- But only authenticated users can submit scores
- Scores are validated for realistic ranges

---

## 📊 Collections & Rules Breakdown

### `/players/{userId}` - Player Profile

**What it stores:**
- Coins, gems, level, XP
- Settings, equipped theme
- Power-up inventory
- Stats (total levels completed, achievements unlocked, etc.)

**Rules:**
- ✅ **Read:** User can read their own data
- ✅ **Create:** User can create their own profile with valid data
- ✅ **Update:** User can update with anti-cheat validation
- ❌ **Delete:** Never allowed (preserve data integrity)

**Validation:**
```
✅ Coins: 0 to 10M, max +10K per update
✅ Gems: 0 to 100K, max +500 per update
✅ Level: 1 to 10,000, max +100 per update
✅ XP: 0+
✅ Timestamp: within 5 minutes of server time
```

---

### `/leaderboard/{scoreId}` - Global Leaderboards

**What it stores:**
- User ID, level number, score, time
- Timestamp of submission

**Rules:**
- ✅ **Read:** Public (anyone can view)
- ✅ **Create:** Authenticated users, validated scores
- ❌ **Update:** Never (immutable)
- ❌ **Delete:** Never (immutable)

**Validation:**
```
✅ Level: 1 to 10,000
✅ Score: 0 to 1M per level
✅ Time: 0 to 7,200 seconds (2 hours max)
✅ User can only submit their own scores
✅ Max 100 total submissions per user
```

---

### `/players/{userId}/levelProgress/{levelId}` - Individual Level Stats

**What it stores:**
- Best time, best moves, stars earned
- Last played timestamp

**Rules:**
- ✅ **Read/Write:** User owns their own progress
- ❌ **Delete:** Never

**Validation:**
```
✅ Stars: 0 to 3
✅ Best time: 0+ seconds
✅ Best moves: 0+ moves
✅ Timestamp: recent server time
```

---

### `/players/{userId}/achievements/{achievementId}` - Achievements

**What it stores:**
- Achievement ID, unlock timestamp

**Rules:**
- ✅ **Read:** User owns their achievements
- ✅ **Create:** Once per achievement
- ❌ **Update/Delete:** Never (permanent)

**Validation:**
```
✅ Achievement ID: valid string
✅ Timestamp: within 5 minutes of server time
```

---

### `/players/{userId}/dailyRewards/{rewardId}` - Daily Reward Claims

**What it stores:**
- Day (1-7), claimed timestamp
- Coins and gems received

**Rules:**
- ✅ **Read:** User owns their rewards
- ✅ **Create:** Once per day
- ❌ **Update/Delete:** Never

**Validation:**
```
✅ Day: 1 to 7
✅ Coins: 0 to 5,000 (max daily reward)
✅ Gems: 0 to 100 (max daily gems)
✅ Timestamp: recent
```

---

### `/players/{userId}/purchases/{purchaseId}` - In-App Purchases

**What it stores:**
- Product ID, purchase token
- Verification status
- Purchase timestamp

**Rules:**
- ✅ **Read:** User owns their purchases
- ✅ **Create:** User creates, marked as unverified
- ⚠️ **Update:** Only Cloud Functions can verify
- ❌ **Delete:** Never

**Validation:**
```
✅ Product ID: string
✅ Purchase token: string
✅ Verified: must be false on creation
✅ Timestamp: recent
```

**Important:** Purchase verification should be done server-side via Cloud Functions to prevent fake purchases.

---

### `/analytics/{eventId}` - Custom Analytics (Optional)

**What it stores:**
- User ID, event name, parameters
- Timestamp

**Rules:**
- ❌ **Read:** Admin only
- ✅ **Create:** Authenticated users
- ❌ **Update/Delete:** Never

**Note:** Firebase Analytics handles most events automatically. This is for custom events if needed.

---

### `/reports/{reportId}` - User Reports

**What it stores:**
- Reporter ID, report type
- Description, timestamp

**Rules:**
- ❌ **Read:** Admin only
- ✅ **Create:** Authenticated users
- ❌ **Update/Delete:** Never

**Validation:**
```
✅ Type: 'bug', 'cheater', 'abuse', or 'other'
✅ Description: max 1,000 characters
✅ Timestamp: recent
```

---

## 🔐 Security Best Practices

### 1. **Never Trust Client Data**
Even with these rules, assume client can be hacked. For critical operations (like IAP), use Cloud Functions for server-side validation.

### 2. **Rate Limiting**
Current rules limit:
- 100 leaderboard submissions per user (lifetime)
- Daily rewards once per day
- Timestamps within 5 minutes

For stricter limits, consider Cloud Functions.

### 3. **Monitor Firestore Usage**
- Set up alerts in Firebase Console → Usage tab
- Watch for unusual spikes in reads/writes
- Investigate users with max limits reached

### 4. **Regularly Review Rules**
- Update limits as your game evolves
- Add new collections with appropriate rules
- Test rules before deploying to production

### 5. **Use Firestore Emulator for Testing**
```bash
# Install Firebase emulator
firebase emulators:start --only firestore

# Test rules locally before deploying
```

---

## 🧪 Testing Security Rules

### Test 1: User Can't Access Other User's Data
```javascript
// This should FAIL
firestore.collection('players').doc('OTHER_USER_ID').get()
```

### Test 2: User Can't Give Themselves Unlimited Coins
```javascript
// This should FAIL (exceeds +10K limit)
firestore.collection('players').doc(myUserId).update({
  coins: currentCoins + 100000
})
```

### Test 3: User Can't Submit Fake Leaderboard Scores
```javascript
// This should FAIL (score too high)
firestore.collection('leaderboard').add({
  userId: myUserId,
  level: 1,
  score: 99999999, // Invalid!
  timeSeconds: 1,
  timestamp: new Date()
})
```

### Test 4: User Can Update Their Own Valid Data
```javascript
// This should SUCCEED
firestore.collection('players').doc(myUserId).update({
  coins: currentCoins + 100, // Valid increase
  lastUpdated: new Date()
})
```

---

## 🚨 Common Errors & Solutions

### Error: "Permission Denied"
**Cause:** User trying to access data they don't own or invalid data.

**Solution:**
- Check user is authenticated
- Verify user ID matches document ID
- Ensure data passes validation rules

### Error: "Missing required fields"
**Cause:** Document missing required fields in rules.

**Solution:**
- Check `hasRequiredFields()` in rules
- Ensure client sends all required fields

### Error: "Value exceeds allowed range"
**Cause:** Trying to set unrealistic values (e.g., 1 billion coins).

**Solution:**
- Check anti-cheat limits in rules
- Validate client-side before sending

### Error: "Timestamp too old/new"
**Cause:** Timestamp more than 5 minutes off from server time.

**Solution:**
- Use `FieldValue.serverTimestamp()` instead of client time
- Check device's clock is accurate

---

## 📈 Scaling Considerations

### For Large User Bases (100K+ users):

1. **Add Firestore Indexes**
   - Go to Firestore → Indexes
   - Create composite indexes for queries
   - Firebase will suggest indexes when needed

2. **Implement Cloud Functions**
   - Move sensitive operations server-side
   - Add custom rate limiting
   - Validate purchases

3. **Use Batch Writes**
   - Reduce write operations
   - Atomic updates for related data

4. **Cache Frequently Accessed Data**
   - Use Firestore offline persistence
   - Cache leaderboards locally

---

## 💰 Cost Optimization

### Free Tier Limits:
- 50K document reads/day
- 20K document writes/day
- 1GB storage

### Tips to Stay Free:
1. **Batch player saves** - Don't save on every action
2. **Cache leaderboards** - Refresh hourly, not per game
3. **Use local storage** - Sync to cloud periodically
4. **Limit analytics** - Use Firebase Analytics instead

### Monitoring:
```
Firebase Console → Usage tab:
- Set alerts at 80% of free tier
- Review top consumers
- Optimize queries
```

---

## 🔧 Advanced: Cloud Functions for Extra Security

For maximum security, implement Cloud Functions:

```javascript
// functions/index.js
exports.verifyPurchase = functions.firestore
  .document('players/{userId}/purchases/{purchaseId}')
  .onCreate(async (snap, context) => {
    const purchase = snap.data();
    
    // Verify with Google Play / App Store
    const isValid = await verifyWithStore(purchase.purchaseToken);
    
    if (isValid) {
      // Mark as verified and grant rewards
      await snap.ref.update({ verified: true });
      await grantRewards(context.params.userId, purchase.productId);
    } else {
      // Invalid purchase, delete record
      await snap.ref.delete();
    }
  });
```

---

## ✅ Deployment Checklist

- [ ] Copy `firestore.rules` to Firebase Console
- [ ] Publish rules
- [ ] Test with your app (create player, submit score, etc.)
- [ ] Verify in Firestore that data is being saved correctly
- [ ] Check no permission denied errors in logs
- [ ] Set up billing alerts
- [ ] Create Firestore indexes as needed
- [ ] Document any custom rules for your team

---

## 📞 Support

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Security Rules Testing](https://firebase.google.com/docs/rules/unit-tests)
- [Best Practices](https://firebase.google.com/docs/firestore/security/rules-conditions)

---

**🎉 Your database is now secured with production-ready rules!**

