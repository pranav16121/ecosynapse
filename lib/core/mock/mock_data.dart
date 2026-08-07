import '../models/user.dart';
import '../models/enums.dart';
import '../models/smart_bin.dart';
import '../models/collection.dart';
import '../models/eco_score.dart';
import '../models/recycler.dart';

class MockData {
  static final List<Community> communities = [
    Community(
      id: '1',
      name: 'Greenwood Residency',
      location: 'Bangalore',
      activeResidentsCount: 450,
    ),
    Community(id: '2', name: 'Lakeview Enclave', location: 'Hyderabad'),
    Community(id: '3', name: 'Prestige Tech Park', location: 'Bangalore'),
    Community(id: '4', name: 'EcoSynapse Demo Community', location: 'Mumbai'),
  ];

  static User getMockUser(UserRole role) {
    switch (role) {
      case UserRole.resident:
        return User(
          id: 'res_1',
          fullName: 'Pranav Powell',
          email: 'pranav.powell@example.com',
          role: UserRole.resident,
          communityId: '1',
          residentId: 'RES-2026-042',
        );
      case UserRole.admin:
        return User(
          id: 'adm_1',
          fullName: 'Priya Iyer',
          email: 'priya.iyer@example.com',
          role: UserRole.admin,
          communityId: '1',
        );
      case UserRole.collector:
        return User(
          id: 'col_1',
          fullName: 'Ramesh Kumar',
          email: 'ramesh.k@ecosynapse.com',
          role: UserRole.collector,
          communityId: '1',
          residentId: 'COL-104',
        );
      case UserRole.recycler:
        return User(
          id: 'rec_1',
          fullName: 'EcoCycle Bangalore',
          email: 'admin@ecocycle.in',
          role: UserRole.recycler,
          communityId: '1',
          residentId: 'REC-001',
        );
    }
  }

  static EcoScore getCommunityEcoScore() {
    return EcoScore(
      overallScore: 86,
      segregationAccuracy: 0.92,
      recyclingRate: 0.74,
      wasteReduction: 0.15,
      monthlyChange: 3,
    );
  }

  static List<SmartBin> getCommunityBins() {
    return [
      SmartBin(
        id: 'BIN-A01',
        communityId: '1',
        location: 'Tower A Lobby',
        status: BinStatus.online,
        fillLevels: {
          WasteCategory.wet: 68,
          WasteCategory.dry: 45,
          WasteCategory.recyclable: 30,
        },
        lastCollection: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SmartBin(
        id: 'BIN-A03',
        communityId: '1',
        location: 'Tower A Parking',
        status: BinStatus.full,
        fillLevels: {
          WasteCategory.wet: 94,
          WasteCategory.dry: 80,
          WasteCategory.recyclable: 75,
        },
        lastCollection: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      SmartBin(
        id: 'BIN-B05',
        communityId: '1',
        location: 'Clubhouse Entrance',
        status: BinStatus.collectionSoon,
        fillLevels: {
          WasteCategory.wet: 83,
          WasteCategory.dry: 60,
          WasteCategory.recyclable: 40,
        },
        lastCollection: DateTime.now().subtract(const Duration(days: 2)),
      ),
      SmartBin(
        id: 'BIN-C02',
        communityId: '1',
        location: 'Garden Exit',
        status: BinStatus.online,
        fillLevels: {
          WasteCategory.wet: 52,
          WasteCategory.dry: 30,
          WasteCategory.recyclable: 20,
        },
        lastCollection: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      SmartBin(
        id: 'BIN-C08',
        communityId: '1',
        location: 'Main Gate North',
        status: BinStatus.full,
        fillLevels: {
          WasteCategory.wet: 97,
          WasteCategory.dry: 85,
          WasteCategory.recyclable: 90,
        },
        lastCollection: DateTime.now().subtract(const Duration(hours: 24)),
      ),
      SmartBin(
        id: 'BIN-D04',
        communityId: '1',
        location: 'Basement Level 2',
        status: BinStatus.online,
        fillLevels: {
          WasteCategory.wet: 15,
          WasteCategory.dry: 20,
          WasteCategory.recyclable: 10,
        },
        lastCollection: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SmartBin(
        id: 'BIN-E01',
        communityId: '1',
        location: 'Food Court Area',
        status: BinStatus.full,
        fillLevels: {
          WasteCategory.wet: 92,
          WasteCategory.dry: 70,
          WasteCategory.recyclable: 80,
        },
        lastCollection: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      SmartBin(
        id: 'BIN-F03',
        communityId: '1',
        location: 'Gym & Spa',
        status: BinStatus.online,
        fillLevels: {
          WasteCategory.wet: 45,
          WasteCategory.dry: 30,
          WasteCategory.recyclable: 50,
        },
        lastCollection: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SmartBin(
        id: 'BIN-G05',
        communityId: '1',
        location: 'Guest House',
        status: BinStatus.online,
        fillLevels: {
          WasteCategory.wet: 20,
          WasteCategory.dry: 10,
          WasteCategory.recyclable: 15,
        },
        lastCollection: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      SmartBin(
        id: 'BIN-H02',
        communityId: '1',
        location: 'Security Cabin',
        status: BinStatus.maintenance,
        fillLevels: {
          WasteCategory.wet: 0,
          WasteCategory.dry: 0,
          WasteCategory.recyclable: 0,
        },
        lastCollection: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  static List<CollectionRequest> getInitialRequests() {
    return [
      CollectionRequest(
        id: 'REQ-C08',
        binId: 'BIN-C08',
        communityId: '1',
        status: CollectionStatus.pending,
        priority: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      CollectionRequest(
        id: 'REQ-A03',
        binId: 'BIN-A03',
        communityId: '1',
        status: CollectionStatus.pending,
        priority: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CollectionRequest(
        id: 'REQ-E01',
        binId: 'BIN-E01',
        communityId: '1',
        status: CollectionStatus.pending,
        priority: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      CollectionRequest(
        id: 'REQ-B05',
        binId: 'BIN-B05',
        communityId: '1',
        status: CollectionStatus.pending,
        priority: 4,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      CollectionRequest(
        id: 'REQ-A01',
        binId: 'BIN-A01',
        communityId: '1',
        status: CollectionStatus.pending,
        priority: 3,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CollectionRequest(
        id: 'REQ-C02',
        binId: 'BIN-C02',
        communityId: '1',
        status: CollectionStatus.pending,
        priority: 3,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      CollectionRequest(
        id: 'REQ-F03',
        binId: 'BIN-F03',
        communityId: '1',
        status: CollectionStatus.pending,
        priority: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
      ),
      CollectionRequest(
        id: 'REQ-G05',
        binId: 'BIN-G05',
        communityId: '1',
        status: CollectionStatus.pending,
        priority: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }

  static List<CollectionRequest> getCompletedCollections() {
    return List.generate(
      15,
      (index) => CollectionRequest(
        id: 'HIST-${1000 + index}',
        binId: 'BIN-${['A02', 'B04', 'C01', 'D03', 'E02', 'F01'][index % 6]}',
        communityId: '1',
        status: CollectionStatus.completed,
        priority: (index % 3) + 3,
        createdAt: DateTime.now().subtract(Duration(days: index + 1, hours: 4)),
        completedAt: DateTime.now().subtract(Duration(days: index + 1)),
      ),
    );
  }

  static List<RecyclingBatch> getIncomingBatches() {
    final categories = WasteCategory.values.take(3).toList();
    return List.generate(
      10,
      (index) => RecyclingBatch(
        id: 'BAT-${240801 + index}',
        recyclerId: 'rec_1',
        category: categories[index % 3],
        weightKg: (index + 1) * 12.5,
        purityPercent: 0,
        timestamp: DateTime.now().subtract(Duration(hours: index * 2)),
      ),
    );
  }

  static List<RecyclingBatch> getProcessedHistory() {
    final categories = WasteCategory.values.take(3).toList();
    return List.generate(
      20,
      (index) => RecyclingBatch(
        id: 'REC-DONE-${300 + index}',
        recyclerId: 'rec_1',
        category: categories[index % 3],
        weightKg: 20.0 + (index * 5),
        purityPercent: 88 + (index % 12),
        timestamp: DateTime.now().subtract(Duration(days: index + 1)),
      ),
    );
  }

  static Map<String, dynamic> getResidentMetrics() {
    return {
      'ecoScore': 82,
      'ecoPoints': 2450,
      'segregationAccuracy': 91,
      'recyclingParticipation': 78,
      'wasteReduction': 12,
      'ecoScoreChange': 4,
      'totalWaste': 12.4,
      'wetWaste': 4.2,
      'dryWaste': 3.6,
      'recyclableWaste': 4.6,
      'wasteReductionPercent': 18,
    };
  }

  static final List<Map<String, dynamic>> rewards = [
    {
      'id': 'r1',
      'title': '₹100 Café Voucher',
      'points': 500,
      'category': 'Food',
      'description': 'Enjoy a coffee on us at any partner café.',
      'icon': 'coffee',
    },
    {
      'id': 'r2',
      'title': '₹200 Grocery Voucher',
      'points': 900,
      'category': 'Shopping',
      'description': 'Save on your next grocery bill.',
      'icon': 'shopping_basket',
    },
    {
      'id': 'r3',
      'title': 'Public Transport Pass',
      'points': 750,
      'category': 'Transport',
      'description': 'One week of free bus/metro travel.',
      'icon': 'directions_bus',
    },
    {
      'id': 'r4',
      'title': 'Bamboo Cutlery Set',
      'points': 1200,
      'category': 'Eco-friendly',
      'description': 'Sustainable alternative to plastic.',
      'icon': 'eco',
    },
  ];

  static final List<Map<String, dynamic>> challenges = [
    {
      'id': 'c1',
      'title': 'Plastic-Free Week',
      'participants': 124,
      'progress': 0.6,
      'reward': 200,
      'status': 'Active',
    },
    {
      'id': 'c2',
      'title': 'Perfect Segregation Streak',
      'participants': 85,
      'progress': 0.4,
      'reward': 150,
      'status': 'Active',
    },
    {
      'id': 'c3',
      'title': 'Reduce Waste by 15%',
      'participants': 210,
      'progress': 0.8,
      'reward': 300,
      'status': 'Ending Soon',
    },
  ];

  static final List<Map<String, dynamic>> bins = [
    {
      'id': 'BIN-A01',
      'location': 'Tower A Ground Floor',
      'fillLevel': 42,
      'status': 'Online',
      'categories': ['Wet', 'Dry', 'Recyclable'],
    },
    {
      'id': 'BIN-B03',
      'location': 'Clubhouse',
      'fillLevel': 78,
      'status': 'Collection Soon',
      'categories': ['Wet', 'Dry', 'Recyclable'],
    },
    {
      'id': 'BIN-C05',
      'location': 'Park Entrance',
      'fillLevel': 15,
      'status': 'Online',
      'categories': ['Dry', 'Recyclable'],
    },
  ];

  static final List<Map<String, dynamic>> activityHistory = [
    {
      'type': 'Points',
      'title': 'Correct Segregation',
      'value': '+25 EcoPoints',
      'date': 'Today',
      'icon': 'check_circle',
    },
    {
      'type': 'Waste',
      'title': 'Waste Deposited',
      'value': '1.2 kg recyclable',
      'date': 'Yesterday',
      'icon': 'delete',
    },
    {
      'type': 'EcoScore',
      'title': 'EcoScore Improved',
      'value': '+2 points',
      'date': 'July 22',
      'icon': 'trending_up',
    },
    {
      'type': 'Rewards',
      'title': '₹100 Voucher Redeemed',
      'value': '-500 EcoPoints',
      'date': 'July 18',
      'icon': 'card_giftcard',
    },
  ];

  static final List<Map<String, dynamic>> communityLeaderboard = [
    {'name': 'Arjun Mehta', 'score': 94, 'points': 3200},
    {'name': 'Sara Khan', 'score': 91, 'points': 2850},
    {'name': 'Pranav Powell', 'score': 82, 'points': 2450, 'isCurrent': true},
    {'name': 'Vikram Singh', 'score': 79, 'points': 2100},
    {'name': 'Neha Gupta', 'score': 75, 'points': 1950},
  ];
}
