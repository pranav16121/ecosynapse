import '../models/user.dart';

class MockData {
  static final List<Community> communities = [
    Community(id: '1', name: 'Greenwood Residency', location: 'Bangalore'),
    Community(id: '2', name: 'Lakeview Enclave', location: 'Hyderabad'),
    Community(id: '3', name: 'Prestige Tech Park', location: 'Bangalore'),
    Community(id: '4', name: 'EcoSynapse Demo Community', location: 'Mumbai'),
  ];

  static User getMockUser(UserRole role) {
    switch (role) {
      case UserRole.resident:
        return User(
          id: 'res_1',
          fullName: 'Aarav Sharma',
          email: 'aarav.sharma@example.com',
          role: UserRole.resident,
          communityId: '1',
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
          fullName: 'Rajesh Kumar',
          email: 'rajesh.k@ecosynapse.com',
          role: UserRole.collector,
          communityId: '1',
        );
      case UserRole.recycler:
        return User(
          id: 'rec_1',
          fullName: 'Anita Desai',
          email: 'anita.d@recyclenow.in',
          role: UserRole.recycler,
          communityId: '1',
        );
    }
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
    {'name': 'Aarav Sharma', 'score': 82, 'points': 2450, 'isCurrent': true},
    {'name': 'Vikram Singh', 'score': 79, 'points': 2100},
    {'name': 'Neha Gupta', 'score': 75, 'points': 1950},
  ];
}
