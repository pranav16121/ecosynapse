import 'package:flutter/material.dart';
import '../models/smart_bin.dart';
import '../models/collection.dart';
import '../models/recycler.dart';
import '../models/enums.dart';

class OperationalState extends ChangeNotifier {
  List<SmartBin> _bins = [];
  List<CollectionRequest> _collectionRequests = [];
  List<RecyclingBatch> _recyclingBatches = [];

  // Community aggregate metrics (Mock)
  double _totalCommunityWasteKg = 1240.0;
  double _totalDivertedKg = 840.0;
  double _communityRecycleRate = 74.0;

  List<SmartBin> get bins => _bins;
  List<CollectionRequest> get collectionRequests => _collectionRequests;
  List<RecyclingBatch> get recyclingBatches => _recyclingBatches;

  double get totalCommunityWasteKg => _totalCommunityWasteKg;
  double get totalDivertedKg => _totalDivertedKg;
  double get communityRecycleRate => _communityRecycleRate;

  void initialize(
    List<SmartBin> bins,
    List<CollectionRequest> requests,
    List<RecyclingBatch> incoming,
  ) {
    _bins = bins;
    _collectionRequests = requests;
    _recyclingBatches = incoming;
    notifyListeners();
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
        _createCollectionRequest(binId, bin.communityId);
      }

      notifyListeners();
    }
  }

  void requestCollection(String binId) {
    final index = _bins.indexWhere((b) => b.id == binId);
    if (index != -1) {
      _createCollectionRequest(binId, _bins[index].communityId);
      notifyListeners();
    }
  }

  void _createCollectionRequest(String binId, String communityId) {
    // Avoid duplicates
    if (_collectionRequests.any(
      (r) => r.binId == binId && r.status != CollectionStatus.completed,
    )) {
      return;
    }

    final newRequest = CollectionRequest(
      id: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
      binId: binId,
      communityId: communityId,
      status: CollectionStatus.pending,
      priority: 5, // Critical
      createdAt: DateTime.now(),
    );
    _collectionRequests.insert(0, newRequest);
  }

  void updateRequestStatus(String requestId, CollectionStatus status) {
    final index = _collectionRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final request = _collectionRequests[index];
      DateTime? completedAt = status == CollectionStatus.completed
          ? DateTime.now()
          : request.completedAt;
      _collectionRequests[index] = request.copyWith(
        status: status,
        completedAt: completedAt,
      );

      // If completed, reset the bin fill levels and create a recycling batch
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
          // Create batches for each compartment that had waste
          bin.fillLevels.forEach((category, level) {
            if (level > 0) {
              double weight = (level * 0.4); // Mock: 1% fill = 0.4kg
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
  }

  void processBatch(String batchId, int purity) {
    final index = _recyclingBatches.indexWhere((b) => b.id == batchId);
    if (index != -1) {
      _recyclingBatches[index] = _recyclingBatches[index].copyWith(
        purityPercent: purity,
      );

      // Update community metrics based on purity
      if (purity > 0) {
        _communityRecycleRate =
            (_communityRecycleRate * 0.9) + (purity * 0.1); // Mock weighted avg
      }
      notifyListeners();
    }
  }
}
