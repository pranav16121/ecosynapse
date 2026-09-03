import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/models/enums.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/state/operational_state.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/eco_card.dart';

class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().currentUser;
    final opState = context.watch<OperationalState>();
    final ecoScore = MockData.getCommunityEcoScore();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () {
              context.read<AuthState>().logout();
              context.go('/auth-portal');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(EcoSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, user),
              const SizedBox(height: EcoSpacing.l),
              _buildEcoScoreHero(context, ecoScore),
              const SizedBox(height: EcoSpacing.l),
              Text('Live Bin Telemetry Summary', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: EcoSpacing.m),
              _buildMetricGrid(context, opState),
              const SizedBox(height: EcoSpacing.l),
              _buildWasteTrendChart(context),
              const SizedBox(height: EcoSpacing.l),
              _buildUrgentAlerts(context, opState),
              const SizedBox(height: EcoSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Greenwood Residency',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'Administrator: ${user?.fullName ?? "Priya Iyer"}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEcoScoreHero(BuildContext context, ecoScore) {
    return EcoCard(
      padding: const EdgeInsets.all(EcoSpacing.l),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community EcoScore',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: EcoSpacing.xs),
                Row(
                  children: [
                    Text(
                      '${ecoScore.overallScore}',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      ' / 100',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: EcoSpacing.xs),
                Text(
                  'Excellent Participation',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: CircularProgressIndicator(
                  value: ecoScore.overallScore / 100,
                  strokeWidth: 8,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '+${ecoScore.monthlyChange}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(BuildContext context, OperationalState opState) {
    final int totalBins = opState.bins.length;
    final int onlineBins = opState.bins.where((b) => b.status != BinStatus.offline).length;
    final int criticalBins = opState.bins.where((b) => b.maxFillLevel >= 80).length;
    final int avgFill = opState.bins.isEmpty
        ? 0
        : (opState.bins.fold<int>(0, (sum, b) => sum + b.maxFillLevel) / opState.bins.length).round();

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: EcoSpacing.m,
      mainAxisSpacing: EcoSpacing.m,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _buildSmallMetric(
          context,
          'Total Smart Bins',
          '$totalBins Bins',
          Icons.delete_outline,
          Colors.blue,
        ),
        _buildSmallMetric(
          context,
          'Bins Online',
          '$onlineBins / $totalBins',
          Icons.wifi,
          Colors.green,
        ),
        _buildSmallMetric(
          context,
          'Critical Fill (>=80%)',
          '$criticalBins Bins',
          Icons.warning_amber_rounded,
          criticalBins > 0 ? Colors.red : Colors.orange,
        ),
        _buildSmallMetric(
          context,
          'Avg Bin Fill',
          '$avgFill%',
          Icons.auto_graph,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildSmallMetric(
    BuildContext context,
    String label,
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
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: EcoSpacing.s),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteTrendChart(BuildContext context) {
    return EcoCard(
      padding: const EdgeInsets.all(EcoSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waste Generation Trend',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: EcoSpacing.l),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 30),
                      FlSpot(1, 45),
                      FlSpot(2, 35),
                      FlSpot(3, 50),
                      FlSpot(4, 40),
                      FlSpot(5, 48),
                    ],
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentAlerts(BuildContext context, OperationalState opState) {
    final fullBins = opState.bins.where((b) => b.maxFillLevel >= 80).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Urgent Bin Alerts', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: EcoSpacing.m),
        if (fullBins.isEmpty)
          const EcoCard(
            child: Center(child: Text('All smart bins are within normal fill levels.')),
          )
        else
          ...fullBins.map(
            (bin) => Padding(
              padding: const EdgeInsets.only(bottom: EcoSpacing.s),
              child: EcoCard(
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: EcoSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bin Full: ${bin.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            bin.location,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${bin.maxFillLevel}%',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
