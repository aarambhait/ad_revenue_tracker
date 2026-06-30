import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/revenue_data.dart';

class GoogleAdsApiService {
  final Map<String, String> authHeaders;

  GoogleAdsApiService({required this.authHeaders});

  static const String _baseUrl = 'https://adsense.googleapis.com/v2';

  // Helper to build URI with repeated query parameters (e.g., repeated metrics/dimensions)
  Uri _buildUri(String path, Map<String, dynamic> params) {
    final queryBuffer = StringBuffer();
    params.forEach((key, value) {
      if (value is List) {
        for (final item in value) {
          if (queryBuffer.isNotEmpty) queryBuffer.write('&');
          queryBuffer.write('${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(item.toString())}');
        }
      } else {
        if (queryBuffer.isNotEmpty) queryBuffer.write('&');
        queryBuffer.write('${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(value.toString())}');
      }
    });

    return Uri.parse('$_baseUrl/$path?${queryBuffer.toString()}');
  }

  Future<String> _getPrimaryAccount() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/accounts'),
      headers: authHeaders,
    );

    if (response.statusCode == 403) {
      throw Exception('Access Forbidden: Ensure Google AdSense API is enabled and your account has permissions.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to load AdSense accounts (Status Code: ${response.statusCode}).');
    }

    final data = json.decode(response.body);
    final accounts = data['accounts'] as List?;
    if (accounts == null || accounts.isEmpty) {
      throw Exception('No AdSense accounts found for this Google account.');
    }

    return accounts.first['name'] as String;
  }

  Future<RevenueData> fetchAdSenseData() async {
    final accountName = await _getPrimaryAccount();

    // Query required data points in parallel
    final Future<double> todayFuture = _fetchSummaryMetric(accountName, 'TODAY');
    final Future<double> yesterdayFuture = _fetchSummaryMetric(accountName, 'YESTERDAY');
    final Future<double> thisMonthFuture = _fetchSummaryMetric(accountName, 'MONTH_TO_DATE');
    final Future<double> lastMonthFuture = _fetchSummaryMetric(accountName, 'LAST_MONTH');
    final Future<Map<String, dynamic>> lifetimeFuture = _fetchLifetimeMetrics(accountName);
    final Future<Map<String, List>> weeklyFuture = _fetchWeeklyChartData(accountName);

    final results = await Future.wait([
      todayFuture,
      yesterdayFuture,
      thisMonthFuture,
      lastMonthFuture,
      lifetimeFuture,
      weeklyFuture,
    ]);

    final double today = results[0] as double;
    final double yesterday = results[1] as double;
    final double thisMonth = results[2] as double;
    final double lastMonth = results[3] as double;
    final Map<String, dynamic> lifetimeData = results[4] as Map<String, dynamic>;
    final Map<String, List> weeklyData = results[5] as Map<String, List>;

    final double lifetimeEarnings = lifetimeData['earnings'] as double;
    final int pageViews = lifetimeData['pageViews'] as int;
    final double pageRpm = pageViews > 0 ? (lifetimeEarnings / pageViews) * 1000 : 0.0;

    return RevenueData(
      today: today,
      yesterday: yesterday,
      thisMonth: thisMonth,
      lastMonth: lastMonth,
      lifetime: lifetimeEarnings,
      pageViews: pageViews,
      impressions: lifetimeData['impressions'] as int,
      clicks: lifetimeData['clicks'] as int,
      pageRpm: pageRpm,
      dailyEarnings: List<double>.from(weeklyData['earnings']!),
      dailyLabels: List<String>.from(weeklyData['labels']!),
    );
  }

  Future<double> _fetchSummaryMetric(String accountName, String dateRange) async {
    final uri = _buildUri('$accountName/reports:generate', {
      'dateRange': dateRange,
      'metrics': ['ESTIMATED_EARNINGS'],
    });

    final response = await http.get(uri, headers: authHeaders);
    if (response.statusCode != 200) return 0.0;

    final data = json.decode(response.body);
    final rows = data['rows'] as List?;
    if (rows == null || rows.isEmpty) return 0.0;

    final cells = rows.first['cells'] as List?;
    if (cells == null || cells.isEmpty) return 0.0;

    return double.tryParse(cells.first['value'] ?? '0.0') ?? 0.0;
  }

  Future<Map<String, dynamic>> _fetchLifetimeMetrics(String accountName) async {
    final now = DateTime.now();
    final threeYearsAgo = now.subtract(const Duration(days: 3 * 365));

    final uri = _buildUri('$accountName/reports:generate', {
      'startDate.year': threeYearsAgo.year.toString(),
      'startDate.month': threeYearsAgo.month.toString(),
      'startDate.day': threeYearsAgo.day.toString(),
      'endDate.year': now.year.toString(),
      'endDate.month': now.month.toString(),
      'endDate.day': now.day.toString(),
      'metrics': ['ESTIMATED_EARNINGS', 'PAGE_VIEWS', 'IMPRESSIONS', 'CLICKS'],
    });

    final response = await http.get(uri, headers: authHeaders);
    final defaultData = {'earnings': 0.0, 'pageViews': 0, 'impressions': 0, 'clicks': 0};

    if (response.statusCode != 200) return defaultData;

    final data = json.decode(response.body);
    final rows = data['rows'] as List?;
    if (rows == null || rows.isEmpty) return defaultData;

    final cells = rows.first['cells'] as List?;
    if (cells == null || cells.length < 4) return defaultData;

    return {
      'earnings': double.tryParse(cells[0]['value'] ?? '0.0') ?? 0.0,
      'pageViews': int.tryParse(cells[1]['value'] ?? '0') ?? 0,
      'impressions': int.tryParse(cells[2]['value'] ?? '0') ?? 0,
      'clicks': int.tryParse(cells[3]['value'] ?? '0') ?? 0,
    };
  }

  Future<Map<String, List>> _fetchWeeklyChartData(String accountName) async {
    final uri = _buildUri('$accountName/reports:generate', {
      'dateRange': 'LAST_7_DAYS',
      'metrics': ['ESTIMATED_EARNINGS'],
      'dimensions': ['DATE'],
    });

    final response = await http.get(uri, headers: authHeaders);
    final defaultData = {'earnings': <double>[], 'labels': <String>[]};

    if (response.statusCode != 200) return defaultData;

    final data = json.decode(response.body);
    final rows = data['rows'] as List?;
    if (rows == null || rows.isEmpty) return defaultData;

    final List<double> earnings = [];
    final List<String> labels = [];

    for (final row in rows) {
      final cells = row['cells'] as List?;
      if (cells != null && cells.length >= 2) {
        final dateStr = cells[0]['value'] ?? '';
        final val = double.tryParse(cells[1]['value'] ?? '0.0') ?? 0.0;

        earnings.add(val);
        labels.add(_formatToDayOfWeek(dateStr));
      }
    }

    return {'earnings': earnings, 'labels': labels};
  }

  String _formatToDayOfWeek(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } catch (_) {
      return dateStr;
    }
  }
}
