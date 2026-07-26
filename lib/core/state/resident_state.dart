import 'package:flutter/material.dart';
import '../mock/mock_data.dart';

class ResidentState extends ChangeNotifier {
  int _ecoPoints = 2450;
  int _ecoScore = 82;
  final List<String> _joinedChallenges = [];
  final List<Map<String, dynamic>> _redemptions = [];
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'n1',
      'title': 'EcoPoints Earned',
      'message': 'You earned 25 points for correct segregation.',
      'time': '2h ago',
      'isRead': false,
    },
    {
      'id': 'n2',
      'title': 'Challenge Progress',
      'message': 'You are 80% through the Waste Reduction challenge!',
      'time': '5h ago',
      'isRead': false,
    },
    {
      'id': 'n3',
      'title': 'Collection Completed',
      'message': 'Waste from Tower A was collected at 9:00 AM.',
      'time': 'Yesterday',
      'isRead': true,
    },
  ];

  int get ecoPoints => _ecoPoints;
  int get ecoScore => _ecoScore;
  List<String> get joinedChallenges => _joinedChallenges;
  List<Map<String, dynamic>> get redemptions => _redemptions;
  List<Map<String, dynamic>> get notifications => _notifications;

  void redeemReward(String rewardId, int cost) {
    if (_ecoPoints >= cost) {
      _ecoPoints -= cost;
      final reward = MockData.rewards.firstWhere((r) => r['id'] == rewardId);
      _redemptions.add({...reward, 'date': DateTime.now().toString()});
      _notifications.insert(0, {
        'id': 'n${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Reward Redeemed',
        'message': 'Successfully redeemed ${reward['title']}.',
        'time': 'Just now',
        'isRead': false,
      });
      notifyListeners();
    }
  }

  void joinChallenge(String challengeId) {
    if (!_joinedChallenges.contains(challengeId)) {
      _joinedChallenges.add(challengeId);
      notifyListeners();
    }
  }

  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n['isRead'] = true;
    }
    notifyListeners();
  }
}
