# Implementation Plan - Phase 1: Admin UI

This phase focuses on replacing the Admin placeholder with a comprehensive community-management dashboard. It introduces a shared "Operational State" to facilitate interactions between Admin, Collector, and Recycler roles while keeping the Resident experience isolated and stable.

## User Review Required

> [!IMPORTANT]
> - **Operational State**: I will create a new `OperationalState` provider. This will be the shared source of truth for Bins, Collection Requests, and Recycling Batches.
> - **Navigation**: Admin will have a 4-tab bottom navigation (Overview, Bins, Logistics, Community).
> - **Model Reuse**: I will use the recently created `SmartBin`, `CollectionRequest`, `EcoScore`, and `Challenge` models to ensure type safety.

## Proposed Changes

### Core & State

#### [NEW] [operational_state.dart](file:///E:/Projects/ecosynapse/lib/core/state/operational_state.dart)
- Manages `List<SmartBin>`, `List<CollectionRequest>`, and `List<RecyclingBatch>`.
- Provides methods for Admin to trigger collection requests (mocked).
- Provides methods for status updates that will be consumed by Collector and Recycler in future phases.

#### [MODIFY] [mock_data.dart](file:///E:/Projects/ecosynapse/lib/core/mock/mock_data.dart)
- Add functions to return `List<SmartBin>`, `List<CollectionRequest>`, and community-level `EcoScore` model instances.

### Admin Feature Screens

#### [NEW] [AdminMainScreen](file:///E:/Projects/ecosynapse/lib/features/admin/screens/admin_main_screen.dart)
- Persistent bottom navigation for Admin role.
- Tabs: Overview, Bins, Logistics, Community.

#### [NEW] [AdminOverviewScreen](file:///E:/Projects/ecosynapse/lib/features/admin/screens/admin_overview_screen.dart)
- **Hero Card**: Community EcoScore ring (e.g., 86/100).
- **Metric Grid**: Total Waste, Diverted Weight (1.2 Tons), Recycling Rate (74%), Active Residents (450).
- **Charts**: Community waste generation trends using `fl_chart`.
- **Urgent Alerts**: List of full bins requiring attention.

#### [NEW] [AdminBinsScreen](file:///E:/Projects/ecosynapse/lib/features/admin/screens/admin_bins_screen.dart)
- Filterable list of all community bins.
- Show fill levels per category (Wet/Dry/Recyclable).
- Quick action: "Request Collection" for bins > 80% full.

#### [NEW] [AdminLogisticsScreen](file:///E:/Projects/ecosynapse/lib/features/admin/screens/admin_logistics_screen.dart)
- Overview of all `CollectionRequest` instances.
- Status tracking: Pending, Scheduled, Completed.
- Priority indicators (1-5).

#### [NEW] [AdminCommunityScreen](file:///E:/Projects/ecosynapse/lib/features/admin/screens/admin_community_screen.dart)
- Community-wide challenge monitoring.
- High-level resident leaderboard (Top 5 participants).
- Engagement statistics.

### Navigation & App Setup

#### [MODIFY] [router.dart](file:///E:/Projects/ecosynapse/lib/app/routes/router.dart)
- Update `/admin` route to point to `AdminMainScreen`.

#### [MODIFY] [main.dart](file:///E:/Projects/ecosynapse/lib/main.dart)
- Register `OperationalState` in the `MultiProvider` list.

## Verification Plan

### Automated Tests
- `flutter analyze`: Ensure 0 errors.
- `flutter test`: Verify that Admin navigation works and metrics render at 360dp width.

### Manual Verification
- Navigate to Admin via Role Selector.
- Verify bottom navigation works between all 4 Admin tabs.
- Ensure all charts and metric cards fit on 360dp width without overflow.
- Confirm "Request Collection" button adds a request to the Logistics tab (mocked state update).
