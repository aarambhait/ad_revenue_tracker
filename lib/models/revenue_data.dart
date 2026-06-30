class RevenueData {
  final double today;
  final double yesterday;
  final double thisMonth;
  final double lastMonth;
  final double lifetime;

  // Granular metrics for professional dashboard look
  final int pageViews;
  final int impressions;
  final int clicks;
  final double pageRpm;

  // Chart data
  final List<double> dailyEarnings;
  final List<String> dailyLabels;

  RevenueData({
    required this.today,
    required this.yesterday,
    required this.thisMonth,
    required this.lastMonth,
    required this.lifetime,
    required this.pageViews,
    required this.impressions,
    required this.clicks,
    required this.pageRpm,
    required this.dailyEarnings,
    required this.dailyLabels,
  });
}
