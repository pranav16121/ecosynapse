import 'package:flutter/material.dart';
import '../models/smart_bin.dart';
import '../models/collection.dart';
import '../models/recycler.dart';
import '../models/enums.dart';

class OperationalState extends ChangeNotifier {
  List<SmartBin> _bins = [];
  List<CollectionRequest> _collectionRequests = [];
  List<RecyclingBatch> _recyclingBatches = [];

  List<SmartBin> get bins => _bins;
  List<CollectionRequest> get collectionRequests => _collectionRequests;
  List<RecyclingBatch> get recyclingBatches => _recyclingBatches;

  void initialize(List<SmartBin> bins, List<CollectionRequest> requests) {
    _bins = bins;
    _collectionRequests = requests;
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

      // If completed, reset the bin fill levels
      if (status == CollectionStatus.completed) {
        final binIndex = _bins.indexWhere((b) => b.id == request.binId);
        if (binIndex != -1) {
          _bins[binIndex] = _bins[binIndex].copyWith(
            fillLevels: _bins[binIndex].fillLevels.map(
              (key, value) => MapEntry(key, 0),
            ),
            lastCollection: DateTime.now(),
            status: BinStatus.online,
          );
        }
      }

      notifyListeners();
    }
  }
}
