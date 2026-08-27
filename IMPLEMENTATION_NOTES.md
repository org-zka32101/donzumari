# Donzumari Implementation Notes

## Phase 1: Project Initialization ✅
- [x] Flutter project structure created
- [x] Dependencies configured (pubspec.yaml)
- [x] Data models created (Freezed)
- [x] Routing configured

## Phase 2: Riverpod Providers (State Management) ✅
- [x] Firebase providers (Auth, Firestore, Analytics, Crashlytics)
- [x] Auth service implementation
- [x] Firestore repository
- [x] Auth providers (Riverpod)
- [x] Doorway data providers
- [x] Play result providers
- [x] Ranking providers
- [x] Unit tests for models

### Key Providers Implemented
1. **Firebase Providers**
   - `firebaseAuthProvider`
   - `firebaseFirestoreProvider`
   - `firebaseAnalyticsProvider`
   - `firebaseCrashlyticsProvider`
   - `currentUserProvider` (Stream)
   - `currentUserIdProvider`

2. **Auth Providers**
   - `authServiceProvider`
   - `signInProvider` (Anonymous sign-in)
   - `currentUserAsyncProvider`
   - `signOutProvider`

3. **Data Access Providers**
   - `firestoreRepositoryProvider`
   - `getDoorwayProvider` (by ID)
   - `getRecentDoorwaysProvider`
   - `doorwayVisitCandidatesProvider`
   - `getDoorwayResultsProvider`
   - `getUserResultsProvider`
   - `savePlayResultProvider`
   - `getDoorwayRankingProvider`

## Phase 3: Flame Physics Engine ✅
- [x] Flame game widget integration in PlayScreen (GameWidget)
- [x] Physics simulation (flame_forge2d with Forge2D)
- [x] Parcel physics properties (BodyDef, FixtureDef)
- [x] Tap/drag input handling (TapDown, Drag events)
- [x] Collision detection (basic implementation)
- [x] Stability calculation (PhysicsService)
- [x] ParcelService for game progression
- [x] Game providers (Riverpod)

## Phase 4: Parcel Assets & Data ✅
- [x] Parcel shape definitions (20 types)
- [x] Stability tier configuration
- [x] Firestore seeding service
- [x] Sprite definitions (visual design assets)
- [x] Color variations (3 per shape)

## Phase 5: Matching Algorithm ✅
- [x] Implement doorway matching logic (composite scoring)
- [x] Score-based ranking (skill 40% + activity 35% + novelty 25%)
- [x] Cold start handling (NPC doorways fallback)
- [x] Visit selection UI (dynamic candidate display)

## Phase 6: Polish & QA ✅
- [x] Sprite asset management (SpriteService)
- [x] Audio/sound effects (AudioService with Flame Audio)
- [x] Animation framework (AnimationService with easing curves)
- [x] Particle effects system (ParticleService)
- [x] Network error handling (NetworkErrorHandler with retry logic)
- [x] Performance monitoring (PerformanceService with FPS tracking)
- [x] Error UI components (ErrorDialog, ErrorSnackBar, NetworkStatusIndicator)
- [x] Loading states (PulseLoadingIndicator, LoadingOverlay, SkeletonLoader)
- [x] Polish providers (Riverpod integration for all services)

## Phase 7B: Game Integration ✅
- [x] DonzumariGame updated with audio/particles/animation support
- [x] Game event service (GameEventService) for coordinated audio+visual effects
- [x] Parcel drop sound effects and particle emission
- [x] Collision detection with audio feedback
- [x] Tower collapse with dramatic particle effects
- [x] Performance monitoring integrated into game loop
- [x] Firestore repository with automatic retry logic (NetworkErrorHandler)
- [x] Game stats tracking (height, parcel count, frame time)
- [x] GameParticle class for particle lifecycle management

## Architecture Overview

### Folder Structure
```
lib/
├── main.dart
├── core/
│   └── constants/
│       └── app_constants.dart (共通定数)
├── data/
│   ├── models/ (Freezed - Immutable data)
│   ├── repositories/ (Firestore operations)
│   └── providers/ (Firebase, Firestore, Data access)
├── domain/
│   ├── services/ (Auth, Physics, Matching)
│   └── providers/ (Auth, Business logic)
└── presentation/
    ├── screens/ (8 screens)
    ├── widgets/ (Reusable components)
    └── providers/ (UI state)
```

### Data Flow
```
User Action
    ↓
UI Screen (presentation layer)
    ↓
Riverpod Provider (state management)
    ↓
Service / Repository (domain/data layer)
    ↓
Firebase / Firestore (backend)
```

## Firestore Schema

### Collections

#### `users`
- `uid` (document ID)
- `displayName` (string)
- `doorwayId` (reference)
- `streak` (int)
- `ownedSkins` (array)
- `createdAt` (timestamp)

#### `doorways`
- `doorwayId` (document ID)
- `ownerUid` (string)
- `currentStack` (array of parcel placements)
- `topScore` (double - height in cm)
- `lastVisitedBy` (string)
- `lastActivityAt` (timestamp)

#### `playResults`
- `resultId` (document ID)
- `uid` (string)
- `doorwayId` (string)
- `height` (double)
- `collapsed` (boolean)
- `gifRef` (storage reference)
- `playedAt` (timestamp)

#### `rankings`
- `doorwayId` (document ID)
- `entries` (array of {uid, height, rank})

### Phase 6 - Polish & QA Services Implemented

**Core Services:**

1. **SpriteService** (lib/domain/services/sprite_service.dart)
   - Preload and cache sprite assets
   - Color variation management (3 variations per parcel)
   - Asset path resolution and loading
   - Memory-efficient caching with clearCache()

2. **AudioService** (lib/domain/services/audio_service.dart)
   - SFX and music playback via Flame Audio
   - Volume controls (0.0-1.0 range)
   - Sound sequences and preloading
   - Audio cache management

3. **AnimationService** (lib/domain/services/animation_service.dart)
   - Easing curve implementations (quad, back, linear)
   - Animation timing calculations
   - Particle motion physics (trajectory, bounce)
   - Tower sway and collapse animations

4. **ParticleService** (lib/domain/services/particle_service.dart)
   - 6 particle types: dust, spark, score, collision, rare_loot, impact
   - Configurable particle emissions and physics
   - Alpha/scale interpolation
   - Rotation and shimmer effects

5. **NetworkErrorHandler** (lib/domain/services/network_error_handler.dart)
   - Firebase error parsing and translation to user-friendly Japanese messages
   - Automatic retry logic with exponential backoff
   - Retryable error detection
   - Error classification (timeout, connection, server, permission)

6. **PerformanceService** (lib/domain/services/performance_service.dart)
   - Frame time recording and analysis
   - FPS calculation and monitoring
   - Performance reports with metrics
   - Memory optimization suggestions

**UI Components (lib/presentation/widgets/):**

- **error_dialog.dart**: ErrorDialog, ErrorSnackBar, NetworkStatusIndicator, RetryButton
- **loading_state.dart**: PulseLoadingIndicator, LoadingOverlay, SkeletonLoader, EmptyStateWidget

**Providers (lib/domain/providers/polish_providers.dart):**
- spriteServiceProvider, audioServiceProvider, animationServiceProvider, particleServiceProvider
- getSpriteProvider, getAnimationEaseProvider, getParticleConfigProvider
- sfxVolumeProvider, musicVolumeProvider, soundEnabledProvider, musicEnabledProvider
- initializePolishProvider, preloadGameplaySpritesProvider, preloadGameplaySoundsProvider

### Phase 7B - Game Integration Services Implemented

**Updated Services:**

1. **DonzumariGame** (lib/presentation/game/donzumari_game.dart)
   - Audio integration: plays drop, collision, and collapse sounds
   - Particle system: dust, collision, and impact particles on events
   - Performance monitoring: frame-time tracking and FPS calculation
   - Game statistics: height, parcel count, elapsed time tracking
   - GameParticle lifecycle management with physics simulation

2. **GameEventService** (lib/domain/services/game_event_service.dart)
   - Centralized game event management
   - Sound + particle effect combinations for each event type
   - 7 event types: parcel_drop, parcel_land, collision, collapse, perfect, score, rare_item
   - Event callback system for UI layer integration
   - Performance tracking for each event

3. **FirestoreRepository** (lib/data/repositories/firestore_repository.dart)
   - Automatic retry logic on ALL Firestore operations
   - Exponential backoff: 100ms, 200ms, 400ms, 800ms
   - Transient error detection (timeout, connection, server)
   - User-friendly error messages for permanent errors
   - Retryable operations: getDoorway, createDoorway, updateStack, saveResult, getRanking

## Phase 7A: Asset Creation ✅
- [x] AssetRegistry (lib/data/fixtures/asset_registry.dart)
- [x] AssetPreloaderService (lib/domain/services/asset_preloader_service.dart)
- [x] Asset providers (lib/domain/providers/asset_providers.dart)
- [x] AssetLoadingScreen widget
- [x] ASSETS.md documentation
- [x] pubspec.yaml asset paths configured

**Implemented Assets:**
- 20 sprite assets (5 stable + 5 moderate + 5 unstable + 5 rare)
- 18 audio assets (6 SFX + 4 UI + 4 music)
- Asset registry with category filtering
- Loading progress tracking system

## Phase 7C: Settings Polish ✅
- [x] PreferencesService (lib/domain/services/preferences_service.dart)
  * SharedPreferences integration for local persistence
  * Audio: SFX/music volume (0.0-1.0), sound/music toggles
  * Game: auto-save toggle, graphics quality (low/medium/high)
  * Haptics: vibration feedback toggle
  * Localization: language selection (ja/en)
  * Theme: dark mode toggle
  * Utilities: initialize, reset to defaults, bulk operations
  
- [x] PreferencesProviders (lib/domain/providers/preferences_providers.dart)
  * StateProviders for reactive state management
  * FutureProviders for async persistence
  * AudioService integration for real-time volume changes
  * Reset provider with default restoration
  
- [x] SettingsScreen UI enhancements (lib/presentation/screens/settings_screen.dart)
  * Volume sliders for SFX and music (0-100%)
  * Toggle switches for sound/music/haptic/auto-save
  * Dropdowns for graphics quality and language
  * Dark mode toggle
  * Reset preferences confirmation dialog
  * Auto-sync with AudioService

- [x] Main.dart updates
  * PreferencesService initialization on app startup
  * Dark mode preference respected in theme selection
  * Watch darkModeProvider for reactive theme changes

## Next Steps

1. **Testing Suite** (Phase 7D)
   - Game event service tests
   - Firestore repository retry logic tests
   - Performance monitoring tests
   - Network error handler tests
   - UI component tests (error dialog, loading states)
   - PreferencesService unit tests
   - Asset preloader tests

## Notes

- **Anonymous Authentication**: Users sign in anonymously. No email/password required.
- **Cold Start Handling**: When users are limited, show NPC doorways (operator-created example towers).
- **Optimistic Updates**: Consider local caching for faster UI updates before Firestore sync.
- **Offline Support**: PlayScreen can work offline; sync results when online.

## Reference

- Design Document: 宅配ドン詰まり — 実装設計書 v1.0
- Main KPI: Day1 Retention 25-28%, Day7 Retention 15-18%
- Aha Moment: Discover other player's parcels → continue stacking → avoid collapse
