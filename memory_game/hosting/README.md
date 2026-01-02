# Firebase Hosting - Memory Match

This folder contains the static website for Privacy Policy and Terms of Service pages.

## 📁 Structure

```
hosting/
├── firebase.json         # Firebase hosting configuration
├── public/              # Static files to be deployed
│   ├── index.html       # Landing page
│   ├── privacy-policy.html   # Privacy Policy page
│   └── terms-of-service.html # Terms of Service page
└── README.md            # This file
```

## 🚀 Deployment Instructions

### Prerequisites
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login to Firebase: `firebase login`

### First Time Setup
1. Navigate to hosting folder:
   ```bash
   cd memory_game/hosting
   ```

2. Initialize Firebase (if not already done):
   ```bash
   firebase init hosting
   ```
   - Select your Firebase project (memorymatch-xxxxx)
   - Use existing `public` directory
   - Configure as single-page app: No
   - Set up automatic builds: No

### Deploy
```bash
cd memory_game/hosting
firebase deploy --only hosting
```

## 🔗 URLs After Deployment

Replace `YOUR_PROJECT_ID` with your actual Firebase project ID:

- **Landing Page**: `https://YOUR_PROJECT_ID.web.app`
- **Privacy Policy**: `https://YOUR_PROJECT_ID.web.app/privacy-policy`
- **Terms of Service**: `https://YOUR_PROJECT_ID.web.app/terms-of-service`

### Custom Domain (Optional)
You can add a custom domain in Firebase Console:
1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Follow the DNS verification steps

Example with custom domain:
- `https://memorymatch.aexyn.com/privacy-policy`
- `https://memorymatch.aexyn.com/terms-of-service`

## 📝 Update URLs in App

After deployment, update these files with your actual URLs:

1. **`lib/presentation/screens/settings/settings_screen.dart`**:
   ```dart
   void _openPrivacyPolicy() async {
     const url = 'https://YOUR_PROJECT_ID.web.app/privacy-policy';
     // ...
   }
   
   void _openTermsOfService() async {
     const url = 'https://YOUR_PROJECT_ID.web.app/terms-of-service';
     // ...
   }
   ```

2. **Google Play Console** - Store Listing:
   - Privacy Policy URL: `https://YOUR_PROJECT_ID.web.app/privacy-policy`

## 🔄 Updating Content

1. Edit the HTML files in `public/` folder
2. Run `firebase deploy --only hosting`
3. Changes are live immediately

## ✅ Checklist for App Store Submission

- [ ] Deploy hosting to Firebase
- [ ] Test all URLs work correctly
- [ ] Update URLs in app code
- [ ] Add Privacy Policy URL to Play Store listing
- [ ] Review content for accuracy

