import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/app_state.dart';
import '../../core/widgets/revenue_card.dart';
import '../../core/widgets/revenue_chart.dart';
import '../../core/widgets/section_header.dart';
import '../../core/utils/formatter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AppState>(context, listen: false).refreshData();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading && appState.revenueData == null) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (appState.errorMessage != null && appState.revenueData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to sync earnings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appState.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 140,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => appState.refreshData(),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = appState.revenueData;
          if (data == null) {
            return const Center(
              child: Text('No data loaded. Drag down to refresh.'),
            );
          }

          final currency = appState.currency;

          return RefreshIndicator(
            onRefresh: () async {
              appState.refreshData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Featured Card: This Month
                  RevenueCard(
                    title: 'THIS MONTH SO FAR',
                    amount: data.thisMonth,
                    currency: currency,
                    icon: Icons.calendar_month,
                    percentageChange: 8.4,
                    comparisonText: 'vs. last month',
                  ),
                  const SizedBox(height: 16),

                  // Today & Yesterday side-by-side
                  Row(
                    children: [
                      Expanded(
                        child: RevenueCard(
                          title: 'TODAY SO FAR',
                          amount: data.today,
                          currency: currency,
                          percentageChange: -3.2,
                          comparisonText: 'vs. yesterday',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RevenueCard(
                          title: 'YESTERDAY',
                          amount: data.yesterday,
                          currency: currency,
                          percentageChange: 12.5,
                          comparisonText: 'vs. same day last week',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Smooth Custom Painter line chart
                  RevenueChart(
                    values: data.dailyEarnings
                        .map((e) => AppFormatter.convert(e, currency))
                        .toList(),
                    labels: data.dailyLabels,
                  ),
                  const SizedBox(height: 16),

                  // Last Month & Lifetime side-by-side
                  Row(
                    children: [
                      Expanded(
                        child: RevenueCard(
                          title: 'LAST MONTH',
                          amount: data.lastMonth,
                          currency: currency,
                          icon: Icons.history,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RevenueCard(
                          title: 'LIFETIME EARNINGS',
                          amount: data.lifetime,
                          currency: currency,
                          icon: Icons.all_inclusive,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Granular metrics grid
                  const SectionHeader(title: 'Ad Performance'),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _buildStatRow(
                          context,
                          label1: 'Page Views',
                          value1: AppFormatter.number(data.pageViews),
                          label2: 'Impressions',
                          value2: AppFormatter.number(data.impressions),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(height: 1),
                        ),
                        _buildStatRow(
                          context,
                          label1: 'Clicks',
                          value1: AppFormatter.number(data.clicks),
                          label2: 'Page RPM',
                          value2: AppFormatter.currency(data.pageRpm, currency),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required String label1,
    required String value1,
    required String label2,
    required String value2,
  }) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );
    final valueStyle = GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1, style: labelStyle),
              const SizedBox(height: 6),
              Text(value1, style: valueStyle),
            ],
          ),
        ),
        Container(
          height: 35,
          width: 0.5,
          color: Theme.of(context).dividerColor,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2, style: labelStyle),
              const SizedBox(height: 6),
              Text(value2, style: valueStyle),
            ],
          ),
        ),
      ],
    );
  }
}
