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

## Next Steps

1. **Asset Creation**
   - Design and create sprite PNG files for 20 parcel types
   - Create audio files for SFX and music tracks
   - Organize assets in proper directories:
     * assets/sprites/parcels/{stable,moderate,unstable,rare}/
     * assets/sounds/{effects,music,ui}/

2. **Integration into Game**
   - Integrate SpriteService into Flame GameWidget for parcel rendering
   - Connect AudioService to game events (drop, collision, collapse)
   - Wire AnimationService and ParticleService to visual effects
   - Implement NetworkErrorHandler in Riverpod providers

3. **Settings Screen Polish**
   - Implement volume sliders connected to AudioService
   - Add sound enable/disable toggles
   - Persist audio preferences to SharedPreferences

4. **Testing**
   - Audio/sprite loading unit tests
   - Error handler parsing tests
   - Performance monitoring integration tests
   - Network error UI component tests

## Notes

- **Anonymous Authentication**: Users sign in anonymously. No email/password required.
- **Cold Start Handling**: When users are limited, show NPC doorways (operator-created example towers).
- **Optimistic Updates**: Consider local caching for faster UI updates before Firestore sync.
- **Offline Support**: PlayScreen can work offline; sync results when online.

## Reference

- Design Document: 宅配ドン詰まり — 実装設計書 v1.0
- Main KPI: Day1 Retention 25-28%, Day7 Retention 15-18%
- Aha Moment: Discover other player's parcels → continue stacking → avoid collapse
