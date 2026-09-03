# 🌱 EcoSynapse

### Intelligent Waste Management Ecosystem

EcoSynapse is an intelligent waste-management ecosystem that connects smart bins, IoT sensing, real-time monitoring, software applications, data analytics, operational workflows, and AI-driven decision making into one unified platform.

Instead of treating waste collection as a simple pickup problem, EcoSynapse is designed to create an intelligent loop:

Sense → Understand → Act → Recover → Improve


## 🚀 What is EcoSynapse?

Traditional waste management often relies on fixed collection schedules, manual monitoring, and fragmented operational systems.

EcoSynapse is designed to make waste management:

- Real-time
- Data-driven
- Predictive
- Operationally coordinated
- User-friendly
- Resource-efficient

The platform connects multiple stakeholders through role-specific interfaces while maintaining a shared operational data layer.


## 🧠 Core Concept

                         ┌──────────────────────┐
                         │      SMART BINS      │
                         │ Sensors + IoT + Data │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │   ECOSYNAPSE CLOUD   │
                         │                      │
                         │ Supabase + Realtime  │
                         │ Data + Auth + RLS    │
                         └──────────┬───────────┘
                                    │
                  ┌─────────────────┼─────────────────┐
                  │                 │                 │
                  ▼                 ▼                 ▼
           ┌────────────┐    ┌────────────┐    ┌────────────┐
           │  RESIDENT  │    │   ADMIN    │    │ COLLECTOR  │
           │   PORTAL   │    │   PORTAL   │    │   PORTAL   │
           └────────────┘    └────────────┘    └────────────┘
                                    │
                                    ▼
                            ┌────────────┐
                            │  RECYCLER  │
                            │   PORTAL   │
                            └────────────┘


# ✨ Current Platform

## 📱 Multi-Role Mobile Application

The Flutter application supports four distinct operational roles.


### 🏠 Resident

Residents can access:

- Personal dashboard
- Smart-bin information
- Community insights
- EcoScore
- EcoPoints
- Rewards
- Notifications
- Waste activity
- Collection requests
- Profile management

Residents can request immediate collection from applicable smart bins.


### 🛡️ Administrator

Administrators can access:

- Operational overview
- Smart-bin monitoring
- Bin telemetry
- Collection requests
- Logistics information
- Community information
- User/account management
- System events
- Profile and account controls

The Admin portal is designed for centralized monitoring and coordination.


### 🚛 Collector

Collectors can access:

- Active collection requests
- Bin inspection
- Collection status
- Collection history
- Operational information
- Profile/account controls

The collection workflow supports:

Requested
    ↓
Pending
    ↓
Accepted / In Progress
    ↓
Completed

When a collection is completed, the system records the responsible operator and updates the corresponding bin state.


### ♻️ Recycler

Recyclers have a dedicated facility-oriented workflow including:

- Incoming material
- Batch inspection
- Material processing
- Rejection
- Recovery workflow
- Recovery analytics
- Profile/account controls

The application is structured so that collection and material recovery can eventually form a connected operational pipeline.


# 📡 Real-Time Smart Bin Monitoring

EcoSynapse supports live smart-bin telemetry through Supabase Realtime.

The application can display information such as:

- Overall fill level
- Wet waste level
- Dry waste level
- Recyclable level
- Battery level
- Weight
- Moisture
- Online/offline status
- Predicted fullness
- System events

The architecture follows:

Supabase Database
       ↓
Realtime Subscription
       ↓
Repository Layer
       ↓
Provider / ChangeNotifier
       ↓
Flutter UI

Supported telemetry updates can appear in the application without requiring a manual refresh.


# 🚨 Intelligent Collection Requests

One of the core workflows is persistent collection requesting.

A user can select a smart bin and request immediate collection.

User selects bin
       ↓
Request Immediate Collection
       ↓
Collection request stored in Supabase
       ↓
UI → COLLECTION REQUESTED
       ↓
Admin / Collector sees request
       ↓
Collection accepted / processed
       ↓
Collection completed
       ↓
Bin state updated

### Built-in protections

- Persistent requests
- Duplicate active-request prevention
- PostgreSQL partial unique index
- Role-aware access control
- Request accountability
- Completion tracking
- Realtime operational visibility


# 🔐 Authentication & Security

EcoSynapse uses Supabase Auth for authentication.

Authentication is separated from application profile data:

Supabase Auth
    │
    ├── Email
    ├── Password authentication
    └── Session
          │
          ▼
public.users
    ├── Name
    ├── Role
    ├── Flat / Unit
    ├── EcoPoints
    ├── EcoScore
    └── Application profile data

### Role-based access

Supported roles:

- Resident
- Admin
- Collector
- Recycler

Users are verified against their application role before entering a role-specific portal.

### Security principles

EcoSynapse does not store plaintext passwords in application tables.

Supabase Auth remains the credential authority.

Protected application data uses Row Level Security (RLS).


# 🧪 SIH Demo System

EcoSynapse includes dedicated demonstration accounts for the Smart India Hackathon presentation workflow.

Available demo roles:

- Resident
- Admin
- Collector
- Recycler

Each login portal includes:

Use Demo Account

which pre-populates the intended demonstration credentials.

The demo accounts still authenticate through the normal Supabase Auth flow rather than bypassing authentication.

This allows the different operational roles to be demonstrated quickly during judging.


# 🗄️ Current Data Architecture

The application currently uses Supabase for the live data layer.

Core application tables include:

- public.users
- public.bins
- public.rewards
- public.system_events
- public.collection_requests

The architecture is designed so additional domains can be introduced without creating competing sources of truth.


# 🛠️ Technology Stack

## Mobile

- Flutter
- Dart
- Provider / ChangeNotifier
- GoRouter

## Backend / Cloud

- Supabase
- PostgreSQL
- Supabase Authentication
- Supabase Realtime
- Row Level Security

## Current Repository Structure

ecosynapse/
│
├── app/          → Flutter mobile application
│
├── website/      → EcoSynapse web experience
│
├── backend/      → Backend / API layer
│
├── hardware/     → ESP32 / embedded systems
│
└── docs/         → Project documentation


# 📂 Flutter Application Structure

app/
│
├── lib/
│   ├── app/
│   │   ├── routes/
│   │   └── theme/
│   │
│   ├── core/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── services/
│   │   └── state/
│   │
│   └── features/
│       ├── admin/
│       ├── auth/
│       ├── bins/
│       ├── collector/
│       ├── community/
│       ├── notifications/
│       ├── onboarding/
│       ├── profile/
│       ├── recycler/
│       ├── resident/
│       ├── rewards/
│       └── role_selection/
│
└── test/

The application follows a modular feature-oriented structure so different product domains can evolve independently.


# 🔄 Application Flow

## First-Time User

App Launch
    ↓
Splash
    ↓
Onboarding
    ↓
Role Selection
    ↓
Select Portal
    ↓
Authentication
    ↓
Role Dashboard

Onboarding is persisted locally and is shown only during the first-use experience.


## Returning User

### Logged out

App Launch
    ↓
Splash
    ↓
Role Selection

### Logged in

App Launch
    ↓
Session Restoration
    ↓
Role Resolution
    ↓
Correct Role Dashboard


# 🔁 Portal Switching

Users can safely leave their current role and return to the role-selection screen.

Authenticated Portal
        ↓
Switch Portal
        ↓
Logout / Session Clear
        ↓
Role Selection

This prevents stale authenticated dashboards from remaining in the navigation stack.


# 📱 Mobile Navigation

The application is designed for mobile-first interaction with:

- Persistent navigation
- Role-specific tabs
- Nested route navigation
- Android back-button handling
- Responsive layouts
- Loading states
- Empty states
- Error states
- Retry actions

The application is tested against narrow mobile layouts including approximately 360dp width.


# 🧩 Design Philosophy

EcoSynapse is not intended to be just another "smart bin."

The larger objective is to connect:

Physical Infrastructure
        +
IoT Telemetry
        +
Software
        +
Operational Workflows
        +
Data
        +
AI / Analytics
        +
Human Participation

into a unified waste-management ecosystem.


# 🔮 Future Development

The platform is structured to support future expansion into areas such as:

- Predictive fill-level forecasting
- Adaptive IoT communication
- Intelligent collection scheduling
- Route optimization
- Sensor fusion
- Waste classification
- Contamination detection
- Hardware-level automation
- Advanced analytics
- Facility-level optimization
- Community incentive systems
- Municipality-scale deployments

The current software architecture provides the foundation for progressively introducing these capabilities.


# 🎯 Project Vision

> Make waste management intelligent, measurable, and connected — from the moment waste is discarded to the moment it is recovered.

EcoSynapse aims to move waste management away from:

Fixed schedules
Manual monitoring
Disconnected systems
Reactive collection

toward:

Real-time sensing
Data-driven decisions
Connected operations
Predictive collection
Resource recovery


# 👨‍💻 Development

### Active Branch

pranav/supabase-integration

### Primary Flutter Workspace

E:\Projects\ecosynapse\app

The project is currently being developed as a monorepo.


# ⚙️ Local Flutter Setup

From the Flutter application directory:

cd app
flutter pub get
flutter analyze
flutter test

To run on an Android device, provide the Supabase configuration through Dart defines:

flutter run --dart-define=SUPABASE_URL=<SUPABASE_PROJECT_URL> --dart-define=SUPABASE_ANON_KEY=<SUPABASE_PUBLISHABLE_KEY>

Never commit private credentials or server-side secrets to the repository.


# 🧪 Testing

Current Flutter verification includes:

flutter analyze
→ 0 errors

flutter test
→ 17 / 17 tests passing

The test suite includes responsive-layout checks for narrow mobile widths.

Physical-device testing is also used for important workflows including:

- Authentication
- Role switching
- Logout
- Collection requests
- Realtime bin updates
- Recycler workflows


# 🤝 Contributing

EcoSynapse is currently an active development project.

When contributing:

1. Keep feature work isolated where possible.
2. Preserve the existing architecture.
3. Do not introduce a second authentication system.
4. Do not introduce another state-management framework without architectural justification.
5. Keep secrets out of source control.
6. Test changes before merging.


# 📜 License

This repository is currently under active development.

License information will be added as the project approaches release.


# 🌱 EcoSynapse

Sense. Understand. Act. Recover.

Building a smarter waste-management ecosystem.
