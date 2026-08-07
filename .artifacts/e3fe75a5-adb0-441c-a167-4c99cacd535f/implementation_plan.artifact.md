# Implementation Plan - Final EcoSynapse UI Polish & Data Population

This plan outlines the final steps to transform EcoSynapse into a premium, production-quality multi-role ecosystem for SIH demonstrations.

## User Review Required

> [!IMPORTANT]
> - **Operational Logic**: I will add artificial delays (loading dialogs) to operations like "Complete Collection" and "Process Batch" to simulate real-world processing and provide better visual feedback.
> - **Data Volume**: I am populating over 50+ unique mock data points across all roles to ensure the demo feels "alive" and comprehensive.

## Proposed Changes

### 1. Robust Mock Data & State

#### [MODIFY] [mock_data.dart](file:///E:/Projects/ecosynapse/lib/core/mock/mock_data.dart)
- Expand `getInitialRequests` to 8 active items with varied priorities.
- Expand `getCompletedCollections` to 15 history items.
- Expand `getIncomingBatches` to 10 items.
- Expand `getProcessedHistory` to 20 items.
- Update `SmartBin` list to 10 bins with varied fill levels.

#### [MODIFY] [operational_state.dart](file:///E:/Projects/ecosynapse/lib/core/state/operational_state.dart)
- Ensure all community metrics (Total Waste, Recycle Rate) are derived from the mock history on initialization.
- Implement robust `completeCollection` logic that resets bins and notifies Recycler.

### 2. Collector operational App Polish

#### [MODIFY] [CollectorCollectionsScreen](file:///E:/Projects/ecosynapse/lib/features/collector/screens/collector_collections_screen.dart)
- **Enterprise Card Design**: Add "Estimated Weight", "Last Updated", and "Category" to every collection card.
- **Priority Chips**: Use high-contrast semantic badges (Critical/High/Normal).
- **Responsive Layout**: Ensure action buttons wrap or scale without overflow on 360dp.

#### [MODIFY] [CollectorHistoryScreen](file:///E:/Projects/ecosynapse/lib/features/collector/screens/collector_history_screen.dart)
- Redesign list to show detailed stats: Weight, Duration, and Collector Rating for each completed job.

#### [MODIFY] [CollectorProfileScreen](file:///E:/Projects/ecosynapse/lib/features/collector/screens/collector_profile_screen.dart)
- Update profile to "Ramesh Kumar" (COL-104).
- Add "Shift: Morning" and "Performance: 96%" metrics.

### 3. Recycler Recovery App Polish

#### [MODIFY] [RecyclerIncomingScreen](file:///E:/Projects/ecosynapse/lib/features/recycler/screens/recycler_incoming_screen.dart)
- **Detailed Batch Cards**: Include Batch ID (BAT-X), Source Community, and Source Bin.
- **Processing Flow**:
    - Redesign "Process Batch" dialog with Purity Slider (65-100%).
    - Live calculations for "Recovered Material" and "Estimated Revenue".

#### [MODIFY] [RecyclerRecoveryScreen](file:///E:/Projects/ecosynapse/lib/features/recycler/screens/recycler_recovery_screen.dart)
- **Advanced Dashboard**:
    - Metric cards for Today/Weekly recovery.
    - CO2 Savings and Landfill Diverted metrics.
    - Material Breakdown pie chart using `fl_chart`.

#### [MODIFY] [RecyclerProfileScreen](file:///E:/Projects/ecosynapse/lib/features/recycler/screens/recycler_profile_screen.dart)
- Update profile to "EcoCycle Bangalore" (REC-001).
- Add facility throughput and recovery rate stats.

### 4. Global Refinements

#### [MODIFY] [Resident Screens](file:///E:/Projects/ecosynapse/lib/features/profile/screens/profile_screen.dart)
- Update resident profile to "Pranav Powell" (RES-2026-042).
- Final check on button feedback (Snackbars/Navigation).

#### [MODIFY] [Admin Screens](file:///E:/Projects/ecosynapse/lib/features/admin/screens/admin_overview_screen.dart)
- Perfect symmetry pass on metric grids.
- Ensure status chips in Bin screen wrap correctly for long location names.

## Verification Plan

### Automated Tests
- `flutter analyze`: Target 0 errors.
- `flutter test`: Run full responsive suite (all screens at 360dp).

### Demo Walkthrough
1. **Collector**: Log in -> View "Critical" Bin A03 (94%) -> Accept -> Complete -> Bin resets to 0% in Admin -> Recycler sees new batch.
2. **Recycler**: Process batch -> View impact growth in Analytics.
3. **Resident**: View profile "Pranav Powell" -> Access History.
