# 🎵 Audio Setup Guide for Memory Game

This guide helps you download and integrate copyright-free audio into your memory game.

## 📥 Recommended Audio Sources

### Sound Effects (SFX)

| Source | License | URL | Notes |
|--------|---------|-----|-------|
| **Kenney.nl** | CC0 (No attribution) | https://kenney.nl/assets?q=audio | Best for game UI |
| **Freesound** | CC0/CC-BY | https://freesound.org | Huge library |
| **OpenGameArt** | Various CC | https://opengameart.org | Game-focused |
| **Mixkit** | Free license | https://mixkit.co/free-sound-effects/ | High quality |
| **Pixabay** | Royalty-free | https://pixabay.com/sound-effects/ | Easy to use |
| **ZapSplat** | Free + attribution | https://www.zapsplat.com | Professional |

### Background Music

| Source | License | URL | Notes |
|--------|---------|-----|-------|
| **Pixabay Music** | Royalty-free | https://pixabay.com/music/ | Various genres |
| **Free Music Archive** | CC licenses | https://freemusicarchive.org | Large catalog |
| **Incompetech** | CC-BY | https://incompetech.com/music/royalty-free/ | Kevin MacLeod |
| **Bensound** | Free + attribution | https://www.bensound.com | Ambient music |

---

## 🎮 Required Audio Files

Place these files in `assets/audio/`:

| Filename | Purpose | Suggested Search Terms |
|----------|---------|----------------------|
| `card_flip.mp3` | Card flip animation | "card flip", "whoosh", "swipe" |
| `match_success.mp3` | Correct match | "success chime", "correct", "ding" |
| `match_fail.mp3` | Wrong match | "error", "wrong", "buzz" |
| `level_complete.mp3` | Level victory | "victory fanfare", "level up", "success" |
| `achievement.mp3` | Achievement unlocked | "achievement", "unlock", "fanfare" |
| `power_up.mp3` | Power-up activation | "power up", "magic", "sparkle" |
| `button_click.mp3` | UI button press | "click", "tap", "button" |
| `timer_warning.mp3` | Low time alert | "tick", "warning", "alert" |
| `countdown.mp3` | Countdown beep | "beep", "countdown" |
| `background_music.mp3` | Background music | "puzzle music", "casual game", "ambient" |

---

## 🚀 Quick Setup with Kenney Assets

### Step 1: Download Kenney Audio Packs

1. **UI Audio** (for clicks, toggles): https://kenney.nl/assets/ui-audio
2. **Digital Audio** (for success/error): https://kenney.nl/assets/digital-audio
3. **Casino Audio** (perfect for card game!): https://kenney.nl/assets/casino-audio
4. **Music Jingles** (for level complete): https://kenney.nl/assets/music-jingles

### Step 2: Rename and Organize

After downloading, rename files to match the required filenames above.

**Suggested Kenney files to use:**

From **UI Audio**:
- `click1.ogg` → `button_click.mp3`
- `switch3.ogg` → `card_flip.mp3`

From **Digital Audio**:
- `confirmation_001.ogg` → `match_success.mp3`
- `error_001.ogg` → `match_fail.mp3`
- `powerUp1.ogg` → `power_up.mp3`

From **Casino Audio**:
- `cardPlace1.ogg` → Alternative card flip sound
- `chipLay1.ogg` → Alternative match sound

From **Music Jingles**:
- `jingles_STEEL00.ogg` → `level_complete.mp3`
- `jingles_STEEL16.ogg` → `achievement.mp3`

### Step 3: Convert to MP3 (if needed)

Kenney files are in OGG format. Convert to MP3 using:
- **Online**: https://cloudconvert.com/ogg-to-mp3
- **FFmpeg**: `ffmpeg -i input.ogg output.mp3`
- **Audacity**: Open file, Export as MP3

### Step 4: Place in Project

```
memory_game/
└── assets/
    └── audio/
        ├── card_flip.mp3
        ├── match_success.mp3
        ├── match_fail.mp3
        ├── level_complete.mp3
        ├── achievement.mp3
        ├── power_up.mp3
        ├── button_click.mp3
        ├── timer_warning.mp3
        ├── countdown.mp3
        └── background_music.mp3
```

---

## 🎼 Background Music Recommendations

### Casual/Puzzle Game Music

Search these terms on Pixabay Music or Free Music Archive:

- "puzzle game music"
- "casual game background"
- "happy game loop"
- "relaxing puzzle"
- "memory game music"

### Recommended Tracks (Pixabay)

1. **"Cute"** - Happy, playful vibe
2. **"Dreamland"** - Calm, ambient
3. **"Happy Clappy"** - Upbeat, cheerful
4. **"Lofi Study"** - Relaxed, non-distracting

### From Incompetech (Kevin MacLeod)

- "Cipher" - Mysterious puzzle vibe
- "Carefree" - Light and happy
- "Monkeys Spinning Monkeys" - Fun and quirky
- "Sneaky Snitch" - Playful

---

## ⚖️ License Summary

### CC0 (Creative Commons Zero) - BEST CHOICE
- ✅ No attribution required
- ✅ Use commercially
- ✅ Modify freely
- **Sources**: Kenney, many Freesound tracks

### CC-BY (Attribution)
- ✅ Free to use
- ⚠️ Must credit the author
- **How to credit**: In your app's About/Credits screen

### Royalty-Free
- ✅ One-time download, unlimited use
- ✅ No ongoing fees
- ⚠️ Read terms for each source

---

## 🔧 Integration Checklist

- [ ] Download audio files
- [ ] Convert to MP3 format (recommended for compatibility)
- [ ] Rename files to match required names
- [ ] Place files in `assets/audio/`
- [ ] Run `flutter pub get`
- [ ] Test audio playback
- [ ] Add credits for CC-BY licensed audio

---

## 📱 Audio File Guidelines

### Format
- **Preferred**: MP3 (best compatibility)
- **Alternative**: OGG, WAV

### Quality Settings
- **SFX**: 128kbps, 44.1kHz stereo
- **Music**: 192kbps, 44.1kHz stereo

### File Size
- **SFX**: Keep under 100KB each
- **Music**: Keep under 3MB for fast loading

### Duration
- **SFX**: 0.1 - 2 seconds
- **Music**: 2-4 minutes (will loop)

---

## 🎯 Quick Links

### All-in-One Game Audio Packs
- https://kenney.nl/assets/ui-audio
- https://kenney.nl/assets/casino-audio
- https://opengameart.org/content/51-ui-sound-effects-buttons-switches-and-டmore

### Specific Sounds
- Card flip: https://freesound.org/search/?q=card+flip
- Success chime: https://mixkit.co/free-sound-effects/win/
- Error buzz: https://mixkit.co/free-sound-effects/wrong/
- Victory fanfare: https://freesound.org/search/?q=victory+fanfare

### Game Music
- https://pixabay.com/music/search/game/
- https://freemusicarchive.org/genre/Instrumental

---

## 💡 Pro Tips

1. **Test on Real Devices**: Audio behavior differs between web, iOS, and Android

2. **Preload Audio**: Initialize audio service early to avoid delays

3. **Volume Balance**: Keep SFX at 80-100%, music at 40-60%

4. **Loop Points**: Ensure background music loops seamlessly

5. **Fallback**: The audio service uses system sounds when files are missing

---

Happy sound designing! 🎮🔊
