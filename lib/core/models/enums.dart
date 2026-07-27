/// Roles within the EcoSynapse ecosystem
enum UserRole { resident, admin, collector, recycler }

/// Primary categories for waste segregation
enum WasteCategory { wet, dry, recyclable, hazardous, unknown }

/// Operational status of a Smart Bin
enum BinStatus { online, offline, maintenance, full, collectionSoon }

/// Type of points transaction in the ledger
enum TransactionType { earned, spent, adjustment }

/// Lifecycle stages of a collection request
enum CollectionStatus { pending, scheduled, inProgress, completed, cancelled }

/// Verification status for AI waste classification
enum VerificationStatus { pending, verified, disputed }

/// Status of a community challenge
enum ChallengeStatus { active, completed, expired }

/// Status of a reward item for a specific user
enum RewardStatus { available, redeemed, expired }

/// Types of sustainability challenges
enum ChallengeType { reduction, segregation, recycling, community }

/// Categories for application notifications
enum NotificationType {
  points,
  challenge,
  collection,
  system,
  reward,
  community,
}
