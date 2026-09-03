import 'dart:async';
import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../models/reward.dart';
import '../models/user.dart';
import '../repositories/reward_repository.dart';
import '../repositories/system_event_repository.dart';
import '../services/supabase_service.dart';

class ResidentState extends ChangeNotifier {
  final RewardRepository _rewardRepository;
  final SystemEventRepository _systemEventRepository;
  StreamSubscription? _eventsSubscription;

  int _ecoPoints = 2450;
  int _ecoScore = 82;
  List<Reward> _liveRewards = [];
  final List<String> _joinedChallenges = [];
  final List<Map<String, dynamic>> _redemptions = [];
  List<Map<String, dynamic>> _notifications = [
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

  ResidentState({
    RewardRepository? rewardRepository,
    SystemEventRepository? systemEventRepository,
  })  : _rewardRepository = rewardRepository ?? RewardRepository(),
        _systemEventRepository =
            systemEventRepository ?? SystemEventRepository() {
    _initLiveResidentData();
  }

  int get ecoPoints => _ecoPoints;
  int get ecoScore => _ecoScore;
  List<Reward> get liveRewards => _liveRewards;
  List<String> get joinedChallenges => _joinedChallenges;
  List<Map<String, dynamic>> get redemptions => _redemptions;
  List<Map<String, dynamic>> get notifications => _notifications;

  bool get isLiveMode => SupabaseService.instance.isInitialized;

  void syncWithUser(User? user) {
    if (user != null && isLiveMode) {
      // In live user profile, eco_points or eco_score can be parsed
      notifyListeners();
    }
  }

  Future<void> _initLiveResidentData() async {
    if (!isLiveMode) return;

    try {
      final rewards = await _rewardRepository.getRewards();
      if (rewards.isNotEmpty) {
        _liveRewards = rewards;
        notifyListeners();
      }

      final events = await _systemEventRepository.getSystemEvents();
      if (events.isNotEmpty) {
        _notifications = events
            .map((e) => {
                  'id': e.id,
                  'title': e.title,
                  'message': e.message,
                  'time': e.timestamp.toString().substring(0, 16),
                  'isRead': e.isRead,
                })
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing live resident data: $e');
    }

    _eventsSubscription?.cancel();
    _eventsSubscription =
        _systemEventRepository.watchSystemEvents().listen((events) {
      if (events.isNotEmpty) {
        _notifications = events
            .map((e) => {
                  'id': e.id,
                  'title': e.title,
                  'message': e.message,
                  'time': e.timestamp.toString().substring(0, 16),
                  'isRead': e.isRead,
                })
            .toList();
        notifyListeners();
      }
    });
  }

  void redeemReward(String rewardId, int cost) {
    if (_ecoPoints >= cost) {
      _ecoPoints -= cost;
      Map<String, dynamic> reward;
      if (_liveRewards.any((r) => r.id == rewardId)) {
        final liveR = _liveRewards.firstWhere((r) => r.id == rewardId);
        reward = {
          'id': liveR.id,
          'title': liveR.title,
          'cost': liveR.pointsCost,
          'category': liveR.category,
        };
      } else {
        reward = MockData.rewards.firstWhere(
          (r) => r['id'] == rewardId,
          orElse: () => {'id': rewardId, 'title': 'Reward'},
        );
      }

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

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}
