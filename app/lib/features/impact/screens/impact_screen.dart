import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../core/mock/mock_data.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({super.key});

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen> {
  String _selectedPeriod = 'Month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Environmental Impact')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EcoSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: EcoSpacing.l),
            _buildImpactSummary(),
            const SizedBox(height: EcoSpacing.l),
            Text(
              'Waste Generation Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: EcoSpacing.m),
            _buildWasteTrendChart(),
            const SizedBox(height: EcoSpacing.xl),
            Text(
              'Waste Category Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: EcoSpacing.m),
            _buildCategoryChart(),
            const SizedBox(height: EcoSpacing.xl),
            _buildImpactEquivalents(),
            const SizedBox(height: EcoSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'Week', label: Text('Week')),
        ButtonSegment(value: 'Month', label: Text('Month')),
        ButtonSegment(value: 'Year', label: Text('Year')),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (newSelection) {
        setState(() => _selectedPeriod = newSelection.first);
      },
    );
  }

  Widget _buildImpactSummary() {
    final metrics = MockData.getResidentMetrics();
    return Row(
      children: [
        Expanded(
          child: EcoCard(
            child: Column(
              children: [
                const Text('Segregation'),
                Text(
                  '${metrics['segregationAccuracy']}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('Accuracy', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
        const SizedBox(width: EcoSpacing.m),
        Expanded(
          child: EcoCard(
            child: Column(
              children: [
                const Text('Reduction'),
                Text(
                  '${metrics['wasteReductionPercent']}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('vs last month', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWasteTrendChart() {
    return EcoCard(
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 3),
                  FlSpot(1, 4),
                  FlSpot(2, 3.5),
                  FlSpot(3, 5),
                  FlSpot(4, 4.5),
                  FlSpot(5, 3.8),
                  FlSpot(6, 4),
                ],
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChart() {
    return EcoCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isNarrow = constraints.maxWidth < 300;
          return Column(
            children: [
              if (isNarrow) ...[
                SizedBox(
                  height: 150,
                  child: PieChart(PieChartData(sections: _buildPieSections())),
                ),
                const SizedBox(height: EcoSpacing.l),
                _buildLegend(),
              ] else
                Row(
                  children: [
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: PieChart(
                        PieChartData(sections: _buildPieSections()),
                      ),
                    ),
                    const SizedBox(width: EcoSpacing.l),
                    Expanded(child: _buildLegend()),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    return [
      PieChartSectionData(
        color: Colors.brown,
        value: 40,
        title: '40%',
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: 30,
        title: '30%',
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: Colors.teal,
        value: 30,
        title: '30%',
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: const [
        _LegendItem(color: Colors.brown, label: 'Wet Waste'),
        _LegendItem(color: Colors.blue, label: 'Dry Waste'),
        _LegendItem(color: Colors.teal, label: 'Recyclable'),
      ],
    );
  }

  Widget _buildImpactEquivalents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Impact Equivalents',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: EcoSpacing.m),
        _buildEquivalentItem(
          Icons.cloud_outlined,
          '12.5 kg CO₂ avoided',
          'Equivalent to planting 2 trees',
        ),
        _buildEquivalentItem(
          Icons.delete_sweep_outlined,
          '45 kg diverted',
          'Waste diverted from landfill',
        ),
        _buildEquivalentItem(
          Icons.electric_bolt_outlined,
          '8.2 kWh saved',
          'Energy recovered from recycling',
        ),
      ],
    );
  }

  Widget _buildEquivalentItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: EcoSpacing.m),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: EcoSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
