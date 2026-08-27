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
- [ ] Sprite assets (visual design)
- [ ] Color variations (3 per shape)

## Phase 5: Matching Algorithm
- [ ] Implement doorway matching logic
- [ ] Score-based ranking
- [ ] Cold start handling (NPC doorways)
- [ ] Visit selection UI

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

## Next Steps

1. **Code Generation**
   ```bash
   flutter pub run build_runner build
   ```

2. **Flame Integration**
   - Replace PlayScreen's placeholder with Flame GameWidget
   - Implement physics simulation
   - Handle tap/drag input

3. **Parcel Asset Creation**
   - Design 20 parcel types
   - Define shape data (vertices, center of mass)
   - Create sprite assets

4. **Testing**
   - Widget tests for screens
   - Integration tests for critical flows
   - Physics simulation unit tests

## Notes

- **Anonymous Authentication**: Users sign in anonymously. No email/password required.
- **Cold Start Handling**: When users are limited, show NPC doorways (operator-created example towers).
- **Optimistic Updates**: Consider local caching for faster UI updates before Firestore sync.
- **Offline Support**: PlayScreen can work offline; sync results when online.

## Reference

- Design Document: 宅配ドン詰まり — 実装設計書 v1.0
- Main KPI: Day1 Retention 25-28%, Day7 Retention 15-18%
- Aha Moment: Discover other player's parcels → continue stacking → avoid collapse
