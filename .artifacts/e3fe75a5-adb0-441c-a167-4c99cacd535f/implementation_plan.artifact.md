# Implementation Plan - Comprehensive Responsive UI & Test Refactor

This plan addresses the failing responsive tests and completes the application-wide responsive UI audit for narrow Android devices (360dp).

## User Review Required

> [!IMPORTANT]
> - **Test Refactoring**: I will shift from "flow-based" testing to "screen-based" testing. Instead of navigating from Splash to Home, I will render each screen directly in the test environment. This will eliminate delays from timers and complex routing logic, making tests deterministic and fast.
> - **Viewport Constraints**: I will use a helper function to set the viewport to exactly 360dp logical width during tests to guarantee overflow detection.

## Proposed Changes

### 1. Test Refactor

#### [MODIFY] [responsive_test.dart](file:///E:/Projects/ecosynapse/test/responsive_test.dart)
- Redesign tests to use `pumpWidget` on individual screens (e.g., `LoginScreen`, `SignupScreen`, `HomeScreen`).
- Wrap each screen in `MultiProvider` and `MaterialApp` to provide the necessary context.
- Implement a `testScreen` helper to standardize viewport setup and overflow checking.

### 2. Final Responsive UI Refactor (360dp Audit)

#### [MODIFY] [rewards_screen.dart](file:///E:/Projects/ecosynapse/lib/features/rewards/screens/rewards_screen.dart)
- **Points Summary**: Ensure the balance text handles long numbers gracefully without clipping or overflow.
- **Reward Cards**: Refactor the horizontal layout (Icon | Text | Button) to stack or use `Flexible` more effectively.

#### [MODIFY] [notifications_screen.dart](file:///E:/Projects/ecosynapse/lib/features/notifications/screens/notifications_screen.dart)
- Ensure long notification messages wrap correctly and don't cause `ListTile` internal overflows.

#### [MODIFY] [activity_history_screen.dart](file:///E:/Projects/ecosynapse/lib/features/resident/screens/activity_history_screen.dart)
- Audit the row containing the icon, title, and value to ensure the "value" (e.g., "+25 EcoPoints") has enough space.

#### [MODIFY] [Admin & Collector Landings]
- **Admin**: Refactor the metric cards row (Total Residents, Active Bins) to handle 360dp.
- **Collector**: Refactor "Pending Pickups" and "Optimized Route" cards.

### 3. Layout Cleanup

#### [MODIFY] [eco_text_field.dart](file:///E:/Projects/ecosynapse/lib/core/widgets/eco_text_field.dart)
- Ensure the `suffixIcon` doesn't squeeze the input text field excessively on narrow screens.

## Verification Plan

### Automated Tests
- `flutter test test/responsive_test.dart`: All screens must pass at 360dp with zero `RenderFlex` overflows.
- `flutter analyze`: Zero errors.

### Manual Verification
- Visual inspection of the "Rewards" and "Community" dashboards at 360dp to ensure premium spacing is maintained even when wrapping occurs.
