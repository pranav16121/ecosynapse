import 'enums.dart';

/// Central record of a waste disposal event, including AI and sensor metadata
class WasteEvent {
  final String id;
  final String userId;
  final String communityId;
  final String binId;
  
  /// The waste category predicted by the on-device or cloud AI
  final WasteCategory? predictedCategory;
  
  /// The confidence score of the AI prediction (0.0 to 1.0)
  final double? confidence;
  
  /// The final verified category. Verfication may happen asynchronously.
  final WasteCategory? finalCategory;
  
  /// The weight of the waste in kilograms, as measured by bin sensors
  final double weightKg;
  
  /// Timestamp when the disposal occurred
  final DateTime timestamp;
  
  /// The physical bin compartment where the waste was deposited
  final WasteCategory targetCompartment;
  
  /// Current status of the event classification verification
  final VerificationStatus verificationStatus;
  
  /// AI Model version used for inference
  final String? modelVersion;
  
  /// Time taken for AI inference in milliseconds
  final int? inferenceTimeMs;
  
  /// Reference to the image captured during disposal (e.g., cloud storage path)
  final String? imageReference;

  /// Flexible storage for additional AI-related metadata
  final Map<String, dynamic> aiMetadata;
  
  /// Flexible storage for raw sensor logs or environment data
  final Map<String, dynamic> sensorMetadata;

  WasteEvent({
    required this.id,
    required this.userId,
    required this.communityId,
    required this.binId,
    required this.weightKg,
    required this.timestamp,
    required this.targetCompartment,
    required this.verificationStatus,
    this.predictedCategory,
    this.confidence,
    this.finalCategory,
    this.modelVersion,
    this.inferenceTimeMs,
    this.imageReference,
    this.aiMetadata = const {},
    this.sensorMetadata = const {},
  });

  WasteEvent copyWith({
    String? id,
    String? userId,
    String? communityId,
    String? binId,
    WasteCategory? predictedCategory,
    double? confidence,
    WasteCategory? finalCategory,
    double? weightKg,
    DateTime? timestamp,
    WasteCategory? targetCompartment,
    VerificationStatus? verificationStatus,
    String? modelVersion,
    int? inferenceTimeMs,
    String? imageReference,
    Map<String, dynamic>? aiMetadata,
    Map<String, dynamic>? sensorMetadata,
  }) {
    return WasteEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      communityId: communityId ?? this.communityId,
      binId: binId ?? this.binId,
      predictedCategory: predictedCategory ?? this.predictedCategory,
      confidence: confidence ?? this.confidence,
      finalCategory: finalCategory ?? this.finalCategory,
      weightKg: weightKg ?? this.weightKg,
      timestamp: timestamp ?? this.timestamp,
      targetCompartment: targetCompartment ?? this.targetCompartment,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      modelVersion: modelVersion ?? this.modelVersion,
      inferenceTimeMs: inferenceTimeMs ?? this.inferenceTimeMs,
      imageReference: imageReference ?? this.imageReference,
      aiMetadata: aiMetadata ?? this.aiMetadata,
      sensorMetadata: sensorMetadata ?? this.sensorMetadata,
    );
  }

  factory WasteEvent.fromJson(Map<String, dynamic> json) {
    return WasteEvent(
      id: json['id'] as String,
      userId: json['userId'] as String,
      communityId: json['communityId'] as String,
      binId: json['binId'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      targetCompartment: WasteCategory.values.firstWhere((e) => e.name == json['targetCompartment']),
      verificationStatus: VerificationStatus.values.firstWhere((e) => e.name == json['verificationStatus']),
      predictedCategory: json['predictedCategory'] != null 
          ? WasteCategory.values.firstWhere((e) => e.name == json['predictedCategory'])
          : null,
      confidence: (json['confidence'] as num?)?.toDouble(),
      finalCategory: json['finalCategory'] != null 
          ? WasteCategory.values.firstWhere((e) => e.name == json['finalCategory'])
          : null,
      modelVersion: json['modelVersion'] as String?,
      inferenceTimeMs: json['inferenceTimeMs'] as int?,
      imageReference: json['imageReference'] as String?,
      aiMetadata: json['aiMetadata'] as Map<String, dynamic>? ?? {},
      sensorMetadata: json['sensorMetadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'communityId': communityId,
      'binId': binId,
      'predictedCategory': predictedCategory?.name,
      'confidence': confidence,
      'finalCategory': finalCategory?.name,
      'weightKg': weightKg,
      'timestamp': timestamp.toIso8601String(),
      'targetCompartment': targetCompartment.name,
      'verificationStatus': verificationStatus.name,
      'modelVersion': modelVersion,
      'inferenceTimeMs': inferenceTimeMs,
      'imageReference': imageReference,
      'aiMetadata': aiMetadata,
      'sensorMetadata': sensorMetadata,
    };
  }

  /// Returns true if the user segregated correctly (Final matches Target)
  bool get isCorrectSegregation => (finalCategory ?? predictedCategory) == targetCompartment;
}
