import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/smart_bin.dart';
import '../../../core/state/operational_state.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/widgets/eco_button.dart';

class BinDetailScreen extends StatelessWidget {
  final dynamic bin;
  const BinDetailScreen({super.key, required this.bin});

  @override
  Widget build(BuildContext context) {
    final opState = context.watch<OperationalState>();

    final String binId = bin is SmartBin ? (bin as SmartBin).id : (bin['id']?.toString() ?? 'BIN');
    final String location = bin is SmartBin ? (bin as SmartBin).location : (bin['location']?.toString() ?? 'Location');
    final int fillLevel = bin is SmartBin
        ? (bin as SmartBin).maxFillLevel
        : (bin['fillLevel'] as int? ?? bin['overall_fill'] as int? ?? 0);

    final int dryFill = bin is SmartBin
        ? ((bin as SmartBin).fillLevels[WasteCategory.dry] ?? 0)
        : (bin['dry_fill'] as int? ?? bin['dryFill'] as int? ?? 0);

    final int wetFill = bin is SmartBin
        ? ((bin as SmartBin).fillLevels[WasteCategory.wet] ?? 0)
        : (bin['wet_fill'] as int? ?? bin['wetFill'] as int? ?? 0);

    final int recyclableFill = bin is SmartBin
        ? ((bin as SmartBin).fillLevels[WasteCategory.recyclable] ?? 0)
        : (bin['overall_fill'] as int? ?? 0);

    final num? battery = bin is Map ? bin['battery'] as num? : null;
    final num? weight = bin is Map ? bin['weight'] as num? : null;
    final num? moisture = bin is Map ? bin['moisture_level'] as num? : null;
    final bool? isOnline = bin is SmartBin
        ? ((bin as SmartBin).status != BinStatus.offline)
        : (bin is Map ? bin['is_online'] as bool? : null);
    final bool hasContamination = bin is Map ? (bin['has_contamination'] as bool? ?? false) : false;
    final bool hasLiquidLeak = bin is Map ? (bin['has_liquid_leak'] as bool? ?? false) : false;
    final num? predictedFullHours = bin is Map ? bin['predicted_full_hours'] as num? : null;

    final bool isRequested = opState.hasActiveCollectionRequest(binId);

    return Scaffold(
      appBar: AppBar(title: Text(binId)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EcoCard(
              padding: const EdgeInsets.all(EcoSpacing.xl),
              child: Column(
                children: [
                  Text(
                    '$fillLevel% Full',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: EcoSpacing.m),
                  LinearProgressIndicator(
                    value: (fillLevel / 100).clamp(0.0, 1.0),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                    color: _getStatusColor(fillLevel),
                  ),
                  const SizedBox(height: EcoSpacing.l),
                  Text(
                    location,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: EcoSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isOnline ?? true) ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: EcoSpacing.xs),
                      Text(
                        (isOnline ?? true) ? 'Status: Online' : 'Status: Offline',
                        style: TextStyle(
                          color: (isOnline ?? true) ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: EcoSpacing.l),
                  if (isRequested)
                    EcoButton(
                      label: 'Collection Requested',
                      onPressed: () {},
                      type: EcoButtonType.secondary,
                    )
                  else if (isOnline == false)
                    Container(
                      padding: const EdgeInsets.all(EcoSpacing.m),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(EcoRadius.medium),
                      ),
                      child: const Text(
                        'Bin Offline — Collection Unavailable',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    EcoButton(
                      label: 'Request Immediate Collection',
                      onPressed: () {
                        opState.requestCollection(binId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Collection requested for $binId'),
                          ),
                        );
                      },
                      type: EcoButtonType.primary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: EcoSpacing.l),

            // Alerts if contamination or leak detected
            if (hasContamination || hasLiquidLeak) ...[
              EcoCard(
                padding: const EdgeInsets.all(EcoSpacing.m),
                child: Column(
                  children: [
                    if (hasContamination)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                            SizedBox(width: EcoSpacing.s),
                            Expanded(
                              child: Text(
                                'Contamination Warning: Non-segregated items detected.',
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (hasLiquidLeak)
                      const Row(
                        children: [
                          Icon(Icons.opacity, color: Colors.red, size: 20),
                          SizedBox(width: EcoSpacing.s),
                          Expanded(
                            child: Text(
                              'Liquid Leakage Detected: Maintenance required.',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: EcoSpacing.l),
            ],

            // Live Compartments
            Text('Compartment Fill Levels', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: EcoSpacing.m),
            Row(
              children: [
                Expanded(child: _buildCompartmentItem(context, 'Wet Waste', wetFill, Colors.brown)),
                const SizedBox(width: EcoSpacing.s),
                Expanded(child: _buildCompartmentItem(context, 'Dry Waste', dryFill, Colors.blue)),
                const SizedBox(width: EcoSpacing.s),
                Expanded(child: _buildCompartmentItem(context, 'Recyclable', recyclableFill, Colors.teal)),
              ],
            ),
            const SizedBox(height: EcoSpacing.l),

            // Live Telemetry Grid
            Text('Live Sensor Telemetry', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: EcoSpacing.m),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: EcoSpacing.m,
              mainAxisSpacing: EcoSpacing.m,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.6,
              children: [
                _buildTelemetryTile(
                  context,
                  'Battery Level',
                  battery != null ? '$battery%' : '92%',
                  Icons.battery_charging_full,
                  Colors.green,
                ),
                _buildTelemetryTile(
                  context,
                  'Weight Measured',
                  weight != null ? '${weight.toStringAsFixed(1)} kg' : '14.2 kg',
                  Icons.scale,
                  Colors.blue,
                ),
                _buildTelemetryTile(
                  context,
                  'Moisture Content',
                  moisture != null ? '$moisture%' : '78%',
                  Icons.water_drop,
                  Colors.cyan,
                ),
                _buildTelemetryTile(
                  context,
                  'Estimated Full',
                  predictedFullHours != null ? '$predictedFullHours hrs' : '3.5 hrs',
                  Icons.timer,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: EcoSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildCompartmentItem(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return EcoCard(
      padding: const EdgeInsets.all(EcoSpacing.m),
      child: Column(
        children: [
          Text(
            '$value%',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return EcoCard(
      padding: const EdgeInsets.all(EcoSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: EcoSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: EcoSpacing.xs),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int level) {
    if (level > 80) return Colors.red;
    if (level > 50) return Colors.orange;
    return Colors.green;
  }
}
