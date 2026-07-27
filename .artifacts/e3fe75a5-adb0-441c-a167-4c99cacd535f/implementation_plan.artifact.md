# Implementation Plan - Core Domain Models & Enums

This plan covers the definition of all core domain models and enums for the EcoSynapse ecosystem. This provides the type-safe foundation for data handling without changing the existing UI or state.

## User Review Required

> [!IMPORTANT]
> - **Existing Models**: I will update `User` and `Community` in `lib/core/models/user.dart` to include the new fields. This is backward-compatible as I will use optional parameters in the constructor or sensible defaults.
> - **WasteEvent**: This is designed as a detailed ledger entry for every disposal, capturing AI and sensor metadata.
> - **Relationships**: All models will refer to each other via `String id` fields rather than object references to simplify serialization and state updates.

## Proposed Enums

### [NEW] [enums.dart](file:///E:/Projects/ecosynapse/lib/core/models/enums.dart)
- `UserRole`: `resident`, `admin`, `collector`, `recycler`
- `WasteCategory`: `wet`, `dry`, `recyclable`, `hazardous`, `unknown`
- `BinStatus`: `online`, `offline`, `maintenance`, `full`, `collectionSoon`
- `TransactionType`: `earned`, `spent`, `adjustment`
- `CollectionStatus`: `pending`, `scheduled`, `inProgress`, `completed`, `cancelled`
- `VerificationStatus`: `pending`, `verified`, `disputed`

## Proposed Models

### Core Identity
#### [MODIFY] [user.dart](file:///E:/Projects/ecosynapse/lib/core/models/user.dart)
- `User`: `id`, `fullName`, `email`, `role`, `communityId`, `residentId?`, `joinedDate?`, `badges` (List<String>)
- `Community`: `id`, `name`, `location`, `ecoScore?`, `rank?`, `activeResidentsCount?`

### Waste Management
#### [NEW] [smart_bin.dart](file:///E:/Projects/ecosynapse/lib/core/models/smart_bin.dart)
- `SmartBin`: `id`, `location`, `status`, `fillLevels` (Map<WasteCategory, int>), `lastCollection?`

#### [NEW] [waste_event.dart](file:///E:/Projects/ecosynapse/lib/core/models/waste_event.dart)
- `WasteEvent`: `id`, `userId`, `communityId`, `binId`, `predictedCategory`, `confidence`, `weightKg`, `timestamp`, `compartment`, `verificationStatus`, `pointsAwarded`

### Scoring & Finance
#### [NEW] [eco_score.dart](file:///E:/Projects/ecosynapse/lib/core/models/eco_score.dart)
- `EcoScore`: `overallScore`, `segregationAccuracy`, `recyclingRate`, `wasteReduction`, `monthlyChange`

#### [NEW] [point_transaction.dart](file:///E:/Projects/ecosynapse/lib/core/models/point_transaction.dart)
- `PointTransaction`: `id`, `amount`, `timestamp`, `description`, `type`, `metadata` (Map)

### Rewards & Challenges
#### [NEW] [reward.dart](file:///E:/Projects/ecosynapse/lib/core/models/reward.dart)
- `Reward`: `id`, `title`, `description`, `pointsCost`, `category`, `icon`
- `RewardRedemption`: `id`, `rewardId`, `userId`, `timestamp`, `status`

#### [NEW] [challenge.dart](file:///E:/Projects/ecosynapse/lib/core/models/challenge.dart)
- `Challenge`: `id`, `title`, `description`, `rewardPoints`, `deadline`, `goalWeight?`
- `ChallengeParticipation`: `id`, `challengeId`, `userId`, `progress`, `status`

### Logistics & Messaging
#### [NEW] [notification.dart](file:///E:/Projects/ecosynapse/lib/core/models/notification.dart)
- `Notification`: `id`, `userId`, `title`, `message`, `timestamp`, `isRead`

#### [NEW] [collection.dart](file:///E:/Projects/ecosynapse/lib/core/models/collection.dart)
- `CollectionRequest`: `id`, `binId`, `communityId`, `timestamp`, `status`
- `CollectionEvent`: `id`, `requestId`, `collectorId`, `weightCollected`, `timestamp`

### Recycling
#### [NEW] [recycler.dart](file:///E:/Projects/ecosynapse/lib/core/models/recycler.dart)
- `Recycler`: `id`, `name`, `type`, `location`
- `RecyclingBatch`: `id`, `recyclerId`, `category`, `weight`, `purity`, `timestamp`

## Verification Plan

### Automated Tests
- `flutter analyze`: Ensure no type errors or missing required fields.
- `flutter test`: Run existing tests to ensure no regressions in current functionality.
- **New Domain Tests**: Create `test/domain_model_test.dart` to verify `fromJson` and `copyWith` logic for each new model.

### Manual Verification
- Verify that `User` and `Community` can still be initialized by existing code in `MockData` and `AuthState` without modification (using defaults or nullability).
