# 🎨 Donzumari Game Assets

Complete guide for managing and creating game assets.

## Asset Directory Structure

```
assets/
├── sprites/
│   └── parcels/
│       ├── stable/           (5 parcel types - stable stacking)
│       ├── moderate/         (5 parcel types - moderate difficulty)
│       ├── unstable/         (5 parcel types - high difficulty)
│       └── rare/             (5 parcel types - special/meme items)
└── sounds/
    ├── effects/              (Game event sounds)
    ├── ui/                   (Menu and UI sounds)
    └── music/                (Background music tracks)
```

## Sprite Assets (20 Total)

### Stable Parcels (5)
- `small_box.png` - Small cardboard box (32x32)
- `medium_box.png` - Medium cardboard box (48x48)
- `letter_mail.png` - Envelope/letter (20x28)
- `tube_mail.png` - Tube-shaped mail (16x40)
- `books.png` - Stack of books (32x24)

### Moderate Difficulty Parcels (5)
- `triangle_box.png` - Triangular pyramid shape (40x48)
- `tall_box.png` - Tall narrow box (24x60)
- `wide_box.png` - Wide flat box (64x32)
- `round_items.png` - Cylindrical/round items (40x40)
- `slanted_box.png` - Slanted/tilted box (48x40)

### Unstable Parcels (5)
- `narrow_tower.png` - Very narrow tall shape (16x56)
- `wobble_cone.png` - Cone/pyramid shape (44x52)
- `tilted_cube.png` - Off-center cube (40x40)
- `asymmetric_box.png` - Asymmetrical shape (48x44)
- `top_heavy_item.png` - Top-heavy object (28x52)

### Rare/Special Parcels (5)
- `pizza_box.png` - Pizza box 🍕 (44x44) *rare, shimmer effect*
- `dumbbell.png` - Dumbbells/weights (52x24) *rare*
- `tire.png` - Vehicle tire (48x48) *rare*
- `crown.png` - Crown shape 👑 (44x44) *rare, particle effects*
- `potted_plant.png` - Potted plant 🌱 (36x48) *rare*

## Audio Assets (18 Total)

### Sound Effects (6)
- `parcel_drop.wav` - Parcel entering game world
- `parcel_land.wav` - Parcel settling after drop
- `parcel_collision.wav` - Parcel hitting another parcel
- `tower_collapse.wav` - Tower falling down
- `tower_perfect.wav` - Perfect stack achieved
- `score_increase.wav` - Score points earned

### UI Sounds (4)
- `button_tap.wav` - Button press feedback
- `screen_transition.wav` - Screen change sound
- `notification.wav` - Generic notification
- `achievement_unlock.wav` - Achievement unlocked

### Music Tracks (4)
- `menu_loop.ogg` - Menu/home screen background music
- `gameplay_loop.ogg` - Gameplay background music (looping)
- `victory.ogg` - Victory/success theme
- `defeat.ogg` - Defeat/fail theme

## Asset Specifications

### Sprite Requirements
- **Format**: PNG with transparency
- **Color Space**: RGB or RGBA
- **DPI**: 72 DPI for screen size
- **Color Variations**: 3 color versions per sprite for variety
  - Generated from base colors in `sprite_definitions.dart`
  - Colors: Primary, Secondary, Tertiary

### Audio Requirements
- **Effects (SFX)**:
  - Format: WAV (16-bit, 44100 Hz)
  - Length: 0.2 - 1.0 seconds
  - Mono or Stereo
  
- **Music**:
  - Format: OGG Vorbis (lossy compression)
  - Length: 30 - 120 seconds (looping)
  - Stereo preferred
  - Bitrate: 128-192 kbps

## Asset Registry

All assets are registered in `lib/data/fixtures/asset_registry.dart`:

```dart
static const Map<String, String> spriteAssets = {
  'small_box': 'assets/sprites/parcels/stable/small_box.png',
  // ... all 20 sprites registered
};

static const Map<String, String> audioAssets = {
  'parcel_drop': 'assets/sounds/effects/parcel_drop.wav',
  // ... all 18 audio assets registered
};
```

## Asset Loading System

### AssetPreloaderService
Manages asset loading with progress tracking:

```dart
// Preload critical assets (stable parcels)
await AssetPreloaderService.preloadCriticalAssets();

// Get progress (0.0 to 1.0)
final progress = AssetPreloaderService.getProgress();

// Get loading status
final status = AssetPreloaderService.getAssetStatus('small_box');
```

### Asset Providers (Riverpod)
Access assets via state management:

```dart
// Get sprite asset path
final path = ref.watch(getSpriteAssetProvider('small_box'));

// Check if asset exists
final exists = ref.watch(hasSpriteAssetProvider('small_box'));

// Get all sprites by category
final stableSprites = ref.watch(
  spriteAssetsByCategoryProvider('stable')
);
```

## Creating New Assets

### Step 1: Design Sprite
1. Create PNG file (recommended 200x200px for high quality)
2. Use transparent background
3. Center the parcel in the image
4. Export as PNG-24 with transparency

### Step 2: Generate Color Variations
1. Create 3 color versions (primary, secondary, tertiary)
2. Naming: `{asset_id}_v1.png`, `{asset_id}_v2.png`, etc.
3. Place in appropriate category folder

### Step 3: Record/Source Audio
- **Record**: Use audio software (Audacity, REAPER, etc.)
- **Royalty-free sources**: Freesound.org, Zapsplat, etc.
- **Export settings**: See Audio Requirements above

### Step 4: Register Asset
1. Add to `AssetRegistry` in `sprite_definitions.dart` or `audio_assets`
2. Update `pubspec.yaml` if new directory created
3. Test loading via `AssetPreloaderService`

## Testing Asset Loading

```bash
# Run asset preload test
flutter test test/services/asset_preloader_test.dart

# Check asset registry
flutter run --dart-define=DEBUG_ASSETS=true
```

## Development vs Production

### Development Phase
- Use placeholder/test assets
- AssetPreloaderService simulates loading
- Fast iteration on game logic

### Production Ready
- Replace with real designed assets
- Ensure all sprite/audio files present
- Verify asset loading performance
- Test on target devices (memory constraints)

## Performance Considerations

### Sprite Optimization
- Total sprite memory: ~5-10 MB (all 20 sprites)
- Use PNG compression (pngcrush, TinyPNG)
- Consider sprite atlasing for better performance

### Audio Optimization
- Total audio memory: ~2-5 MB (all 18 tracks)
- Use OGG Vorbis for music (50% size reduction vs WAV)
- Keep SFX short and focused

### Loading Strategy
- Preload stable parcels at app startup (high priority)
- Lazy-load rare parcels on demand
- Stream music instead of preloading
- Monitor total asset memory usage

## Asset Checklist

- [ ] All 20 sprite PNG files created and placed
- [ ] 3 color variations per sprite completed
- [ ] All 6 SFX files (WAV, 44100 Hz)
- [ ] All 4 UI sounds (WAV, 44100 Hz)
- [ ] All 4 music tracks (OGG Vorbis, looping)
- [ ] Assets registered in `AssetRegistry`
- [ ] `pubspec.yaml` asset paths configured
- [ ] Asset preloading tested
- [ ] Performance profiled on target device
- [ ] Total memory usage < 10 MB

## Asset References

- Sprite Design Guidelines: [Document Link]
- Audio Production Guide: [Document Link]
- Color Palette: See `sprite_definitions.dart` for hex colors
- Flame Asset Loading: https://flame-engine.org/docs/latest/other/asset_loading
