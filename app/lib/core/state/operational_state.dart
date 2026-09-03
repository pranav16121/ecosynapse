import 'dart:async';
import 'package:flutter/material.dart';
import '../models/smart_bin.dart';
import '../models/collection.dart';
import '../models/recycler.dart';
import '../models/enums.dart';
import '../repositories/smart_bin_repository.dart';
import '../repositories/collection_request_repository.dart';
import '../services/supabase_service.dart';

class OperationalState extends ChangeNotifier {
  final SmartBinRepository _smartBinRepository;
  final CollectionRequestRepository _collectionRequestRepository;

  StreamSubscription<List<SmartBin>>? _binSubscription;
  StreamSubscription<List<CollectionRequest>>? _requestSubscription;

  List<SmartBin> _bins = [];
  List<CollectionRequest> _collectionRequests = [];
  List<RecyclingBatch> _recyclingBatches = [];

  double _totalCommunityWasteKg = 1240.0;
  double _totalDivertedKg = 840.0;
  double _communityRecycleRate = 74.0;
  bool _isLoading = false;

  OperationalState({
    SmartBinRepository? smartBinRepository,
    CollectionRequestRepository? collectionRequestRepository,
  })  : _smartBinRepository = smartBinRepository ?? SmartBinRepository(),
        _collectionRequestRepository =
            collectionRequestRepository ?? CollectionRequestRepository() {
    _initLiveSync();
  }

  List<SmartBin> get bins => _bins;
  List<CollectionRequest> get collectionRequests => _collectionRequests;
  List<RecyclingBatch> get recyclingBatches => _recyclingBatches;

  double get totalCommunityWasteKg => _totalCommunityWasteKg;
  double get totalDivertedKg => _totalDivertedKg;
  double get communityRecycleRate => _communityRecycleRate;
  bool get isLoading => _isLoading;

  bool get isLiveMode => SupabaseService.instance.isInitialized;

  void initialize(
    List<SmartBin> bins,
    List<CollectionRequest> requests,
    List<RecyclingBatch> incoming,
  ) {
    if (_bins.isEmpty) {
      _bins = bins;
    }
    if (_collectionRequests.isEmpty) {
      _collectionRequests = requests;
    }
    _recyclingBatches = incoming;
    notifyListeners();
  }

  /// Returns true if an active (pending/scheduled/inProgress) collection request exists for the bin.
  bool hasActiveCollectionRequest(String binId) {
    return _collectionRequests.any(
      (r) =>
          r.binId == binId &&
          r.status != CollectionStatus.completed &&
          r.status != CollectionStatus.cancelled,
    );
  }

  /// Returns the active collection request for a bin if present.
  CollectionRequest? getActiveCollectionRequest(String binId) {
    try {
      return _collectionRequests.firstWhere(
        (r) =>
            r.binId == binId &&
            r.status != CollectionStatus.completed &&
            r.status != CollectionStatus.cancelled,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _initLiveSync() async {
    if (!isLiveMode) return;

    _isLoading = true;
    notifyListeners();

    try {
      final initialBins = await _smartBinRepository.getBins();
      if (initialBins.isNotEmpty) {
        _bins = initialBins;
      }

      final initialRequests = await _collectionRequestRepository.getCollectionRequests();
      if (initialRequests.isNotEmpty) {
        _collectionRequests = initialRequests;
      }
    } catch (e) {
      debugPrint('Error fetching initial operational live data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    _binSubscription?.cancel();
    _binSubscription = _smartBinRepository.watchBins().listen(
      (liveBins) {
        if (liveBins.isNotEmpty) {
          _bins = liveBins;
          notifyListeners();
        }
      },
      onError: (e) {
        debugPrint('Error in live bin subscription: $e');
      },
    );

    _requestSubscription?.cancel();
    _requestSubscription = _collectionRequestRepository.watchCollectionRequests().listen(
      (liveRequests) {
        if (liveRequests.isNotEmpty) {
          _collectionRequests = liveRequests;
          notifyListeners();
        }
      },
      onError: (e) {
        debugPrint('Error in live collection request subscription: $e');
      },
    );
  }

  void updateBinFillLevel(String binId, WasteCategory category, int level) {
    final index = _bins.indexWhere((b) => b.id == binId);
    if (index != -1) {
      final bin = _bins[index];
      final newFillLevels = Map<WasteCategory, int>.from(bin.fillLevels);
      newFillLevels[category] = level;
      _bins[index] = bin.copyWith(fillLevels: newFillLevels);

      // Auto-trigger collection if full
      if (level >= 90) {
        requestCollection(binId);
      }

      notifyListeners();
    }
  }

  /// Triggers a collection request for a specific bin safely with duplicate check.
  Future<void> requestCollection(String binId, {String? userId}) async {
    if (hasActiveCollectionRequest(binId)) {
      debugPrint('Collection request already pending for $binId.');
      return;
    }

    final index = _bins.indexWhere((b) => b.id == binId);
    final String communityId = index != -1 ? _bins[index].communityId : '1';

    if (isLiveMode) {
      try {
        final liveReq = await _collectionRequestRepository.createCollectionRequest(
          binId: binId,
          requestedBy: userId ?? 'user',
          communityId: communityId,
          priority: 5,
        );

        if (liveReq != null) {
          _collectionRequests.removeWhere((r) => r.id == liveReq.id);
          _collectionRequests.insert(0, liveReq);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error inserting collection request to Supabase: $e');
        _createLocalCollectionRequest(binId, communityId);
      }
    } else {
      _createLocalCollectionRequest(binId, communityId);
    }
  }

  void _createLocalCollectionRequest(String binId, String communityId) {
    if (hasActiveCollectionRequest(binId)) return;

    final newRequest = CollectionRequest(
      id: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
      binId: binId,
      communityId: communityId,
      status: CollectionStatus.pending,
      priority: 5,
      createdAt: DateTime.now(),
    );
    _collectionRequests.insert(0, newRequest);
    notifyListeners();
  }

  Future<void> updateRequestStatus(
    String requestId,
    CollectionStatus status, {
    String? completedBy,
  }) async {
    final index = _collectionRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final request = _collectionRequests[index];
    DateTime? completedAt =
        status == CollectionStatus.completed ? DateTime.now() : request.completedAt;

    _collectionRequests[index] = request.copyWith(
      status: status,
      completedAt: completedAt,
    );

    if (isLiveMode) {
      try {
        await _collectionRequestRepository.updateRequestStatus(
          requestId: requestId,
          status: status,
          completedBy: completedBy,
        );
      } catch (e) {
        debugPrint('Error updating request status in Supabase: $e');
      }
    }

    // Reset bin fill levels on completion
    if (status == CollectionStatus.completed) {
      final binIndex = _bins.indexWhere((b) => b.id == request.binId);
      if (binIndex != -1) {
        final bin = _bins[binIndex];
        _bins[binIndex] = bin.copyWith(
          fillLevels: bin.fillLevels.map((key, value) => MapEntry(key, 0)),
          lastCollection: DateTime.now(),
          status: BinStatus.online,
        );

        double collectedWeight = 0;
        bin.fillLevels.forEach((category, level) {
          if (level > 0) {
            double weight = (level * 0.4);
            collectedWeight += weight;
            _recyclingBatches.insert(
              0,
              RecyclingBatch(
                id: 'BAT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                recyclerId: 'rec_1',
                category: category,
                weightKg: weight,
                purityPercent: 0,
                timestamp: DateTime.now(),
              ),
            );
          }
        });

        _totalCommunityWasteKg += collectedWeight;
        _totalDivertedKg += collectedWeight;
      }
    }

    notifyListeners();
  }

  void processBatch(String batchId, int purity) {
    final index = _recyclingBatches.indexWhere((b) => b.id == batchId);
    if (index != -1) {
      _recyclingBatches[index] = _recyclingBatches[index].copyWith(
        purityPercent: purity,
      );

      if (purity > 0) {
        _communityRecycleRate =
            (_communityRecycleRate * 0.9) + (purity * 0.1);
      }
      notifyListeners();
    }
  }

  void rejectBatch(String batchId) {
    final index = _recyclingBatches.indexWhere((b) => b.id == batchId);
    if (index != -1) {
      _recyclingBatches[index] = _recyclingBatches[index].copyWith(
        purityPercent: -1,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _binSubscription?.cancel();
    _requestSubscription?.cancel();
    super.dispose();
  }
}
