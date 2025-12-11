# Branding Update - Stupefying Labs

## Changes Made

### ✅ Company Rebranding: Aexyn → Stupefying Labs

All references to "Aexyn" have been updated to "Stupefying Labs" in user-facing documents:

#### Privacy Policy (`hosting/public/privacy-policy.html`)
- ✅ Updated copyright: `© 2025 Stupefying Labs`
- ✅ Updated contact email: `privacy@stupefyinglabs.com`
- ✅ Updated website: `https://stupefyinglabs.com`
- ✅ Updated developer name: `Stupefying Labs`
- ✅ Updated "Last Updated" date: `January 10, 2025`

#### Terms of Service (`hosting/public/terms-of-service.html`)
- ✅ Updated copyright: `© 2025 Stupefying Labs`
- ✅ Updated contact email: `legal@stupefyinglabs.com`
- ✅ Updated website: `https://stupefyinglabs.com`
- ✅ Updated developer name: `Stupefying Labs`
- ✅ Updated ownership references
- ✅ Updated indemnification clause
- ✅ Updated "Last Updated" date: `January 10, 2025`

#### Landing Page (`hosting/public/index.html`)
- ✅ Updated footer: `© 2025 Stupefying Labs`
- ✅ Updated website link: `https://stupefyinglabs.com`

---

### ✅ Year Update: 2024 → 2025

All copyright notices and "Last Updated" dates have been updated to 2025.

---

### ✅ Navigation Fix: Privacy Policy & Terms Links

**Problem**: Clicking on Privacy Policy or Terms of Service links on the deployed website didn't work - they just reloaded the homepage.

**Root Cause**: The `firebase.json` configuration had a blanket rewrite rule:
```json
"rewrites": [
  {
    "source": "**",
    "destination": "/index.html"
  }
]
```
This redirected ALL requests (including /privacy-policy and /terms-of-service) back to index.html.

**Fix Applied**:
- Removed the problematic `rewrites` section
- Added `"cleanUrls": true` to allow clean URLs without .html extension
- Now `/privacy-policy` correctly serves `privacy-policy.html`
- And `/terms-of-service` correctly serves `terms-of-service.html`

---

## Deployment

✅ **Successfully Deployed to Firebase Hosting**

**Hosting URL**: https://memory-match---brain-training.web.app

**Updated Files**:
- ✅ index.html
- ✅ privacy-policy.html
- ✅ terms-of-service.html
- ✅ firebase.json (configuration fix)

---

## Verification

### Test the Links

Visit the website and verify all navigation works:

1. **Main Page**: https://memory-match---brain-training.web.app
   - Should show "© 2025 Stupefying Labs" in footer

2. **Privacy Policy**: https://memory-match---brain-training.web.app/privacy-policy
   - Should load the privacy policy page (not redirect to home)
   - Should show "© 2025 Stupefying Labs" in footer
   - Should show "Last Updated: January 10, 2025"
   - Contact email: privacy@stupefyinglabs.com

3. **Terms of Service**: https://memory-match---brain-training.web.app/terms-of-service
   - Should load the terms page (not redirect to home)
   - Should show "© 2025 Stupefying Labs" in footer
   - Should show "Last Updated: January 10, 2025"
   - Contact email: legal@stupefyinglabs.com

### Test In-App Links

The app's Settings screen has links to:
- Privacy Policy: `https://memory-match---brain-training.web.app/privacy-policy`
- Terms of Service: `https://memory-match---brain-training.web.app/terms-of-service`

Both should now open correctly in the browser.

---

## Important Notes

### Package Names (NOT Changed)
The Android/iOS package identifiers remain unchanged as they cannot be easily changed after release:
- Android: `com.aexyn.memorymatch.memorygame`
- iOS: `com.aexyn.memorymatch.memorygame`
- macOS: `com.aexyn.memorymatch.memorygame`

**This is normal and acceptable** - the package name is just a technical identifier and doesn't need to match the company name. Many companies rebrand but keep the original package name.

### Documentation Files (Internal Only)
The following internal documentation files still reference "Aexyn" but these are for developer use only and not user-facing:
- Build scripts (test_release.sh, verify_production_ads.sh)
- Technical documentation (TEST_ADS_FIX.md, RELEASE_BUILD_INFO.md, etc.)
- ProGuard rules
- Build configurations

These can be left as-is or updated over time as they don't affect users.

---

## Contact Email Addresses

Make sure these email addresses are set up:

1. **privacy@stupefyinglabs.com** - For privacy-related inquiries
2. **legal@stupefyinglabs.com** - For legal/terms inquiries

Or update the HTML files with your actual contact emails if different.

---

## Summary

✅ All user-facing branding updated to "Stupefying Labs"
✅ All dates updated to 2025
✅ Website navigation fixed - links now work correctly
✅ Successfully deployed to Firebase Hosting
✅ Ready for app submission to Play Store

The website is now live with all correct branding and working navigation!
