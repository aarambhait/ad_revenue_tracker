import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/revenue_data.dart';
import '../models/payment_data.dart';

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

  Future<String?> _getAdMobPrimaryAccount() async {
    try {
      final response = await http.get(
        Uri.parse('https://admob.googleapis.com/v1/accounts'),
        headers: authHeaders,
      );

      if (response.statusCode != 200) {
        debugPrint('AdMob Account call failed with status: ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body);
      final accounts = data['account'] as List?;
      if (accounts == null || accounts.isEmpty) {
        return null;
      }

      return accounts.first['name'] as String;
    } catch (e) {
      debugPrint('AdMob Account call encountered error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAdSenseDailyRows(String accountName) async {
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
      'dimensions': ['DATE'],
    });

    final response = await http.get(uri, headers: authHeaders);
    if (response.statusCode != 200) {
      debugPrint('AdSense daily report call failed: ${response.statusCode}');
      return [];
    }

    final List<Map<String, dynamic>> dailyRows = [];
    final data = json.decode(response.body);
    final rows = data['rows'] as List?;
    if (rows != null) {
      for (final row in rows) {
        final cells = row['cells'] as List?;
        if (cells != null && cells.length >= 5) {
          dailyRows.add({
            'date': cells[0]['value'] ?? '', // format: yyyy-MM-dd
            'earnings': double.tryParse(cells[1]['value'] ?? '0.0') ?? 0.0,
            'pageViews': int.tryParse(cells[2]['value'] ?? '0') ?? 0,
            'impressions': int.tryParse(cells[3]['value'] ?? '0') ?? 0,
            'clicks': int.tryParse(cells[4]['value'] ?? '0') ?? 0,
          });
        }
      }
    }

    return dailyRows;
  }

  Future<List<Map<String, dynamic>>> _fetchAdMobDailyRows(String accountName) async {
    final now = DateTime.now();
    final threeYearsAgo = now.subtract(const Duration(days: 3 * 365));

    final url = Uri.parse('https://admob.googleapis.com/v1/$accountName/networkReport:generate');

    final requestBody = {
      'reportSpec': {
        'dateRange': {
          'startDate': {
            'year': threeYearsAgo.year,
            'month': threeYearsAgo.month,
            'day': threeYearsAgo.day,
          },
          'endDate': {
            'year': now.year,
            'month': now.month,
            'day': now.day,
          }
        },
        'dimensions': ['DATE'],
        'metrics': ['ESTIMATED_EARNINGS', 'IMPRESSIONS', 'CLICKS'],
        'sortConditions': [
          {
            'dimension': 'DATE',
            'order': 'ASCENDING'
          }
        ]
      }
    };

    final response = await http.post(
      url,
      headers: {
        ...authHeaders,
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode != 200) {
      debugPrint('AdMob report call failed with status: ${response.statusCode}');
      return [];
    }

    final List<Map<String, dynamic>> dailyRows = [];
    final dynamic dataList = json.decode(response.body);

    if (dataList is List) {
      for (final item in dataList) {
        final row = item['row'];
        if (row != null) {
          final dimensionValues = row['dimensionValues'] as Map?;
          final metricValues = row['metricValues'] as Map?;
          if (dimensionValues != null && metricValues != null) {
            final dateVal = dimensionValues['DATE']?['value'] as String?;
            final earningsMicros = metricValues['ESTIMATED_EARNINGS']?['microsValue'] as String?;
            final impressionsInt = metricValues['IMPRESSIONS']?['integerValue'] as String?;
            final clicksInt = metricValues['CLICKS']?['integerValue'] as String?;

            if (dateVal != null) {
              dailyRows.add({
                'date': dateVal, // format: yyyyMMdd
                'earnings': (double.tryParse(earningsMicros ?? '0') ?? 0.0) / 1000000.0,
                'impressions': int.tryParse(impressionsInt ?? '0') ?? 0,
                'clicks': int.tryParse(clicksInt ?? '0') ?? 0,
              });
            }
          }
        }
      }
    }

    return dailyRows;
  }

  Future<List<PaymentData>> fetchAdSensePayments(String accountName) async {
    try {
      final uri = _buildUri('$accountName/payments', {});
      final response = await http.get(uri, headers: authHeaders);

      if (response.statusCode != 200) {
        debugPrint('Payments call failed with status: ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);
      final paymentsList = data['payments'] as List?;
      if (paymentsList == null || paymentsList.isEmpty) {
        return [];
      }

      final List<PaymentData> payments = [];
      for (final payment in paymentsList) {
        final amountStr = payment['amount'] as String?;
        final dateObj = payment['date'] as Map?;

        if (amountStr != null && dateObj != null) {
          final year = dateObj['year'] as int?;
          final month = dateObj['month'] as int?;
          final day = dateObj['day'] as int?;

          if (year != null && month != null && day != null) {
            final dateStr = "$year-${_twoDigits(month)}-${_twoDigits(day)}";
            final amountVal = double.tryParse(amountStr) ?? 0.0;

            payments.add(PaymentData(
              date: dateStr,
              amount: amountVal,
              status: 'Completed',
              referenceNumber: payment['name']?.toString().split('/').last ?? 'REF-XXXXXX',
              paymentMethod: 'Wire Transfer',
            ));
          }
        }
      }
      return payments;
    } catch (e) {
      debugPrint('Payments call error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchCombinedData() async {
    // 1. Fetch account IDs in parallel
    final Future<String> adsenseAccountFuture = _getPrimaryAccount();
    final Future<String?> admobAccountFuture = _getAdMobPrimaryAccount();

    final accounts = await Future.wait([
      adsenseAccountFuture,
      admobAccountFuture,
    ]);

    final String adsenseAccount = accounts[0] as String;
    final String? admobAccount = accounts[1];

    // 2. Fetch daily rows for both in parallel
    final Future<List<Map<String, dynamic>>> adsenseRowsFuture = _fetchAdSenseDailyRows(adsenseAccount);
    final Future<List<Map<String, dynamic>>> admobRowsFuture = admobAccount != null
        ? _fetchAdMobDailyRows(admobAccount)
        : Future.value(<Map<String, dynamic>>[]);

    final dailyDataResults = await Future.wait([
      adsenseRowsFuture,
      admobRowsFuture,
    ]);

    final List<Map<String, dynamic>> adsenseRows = dailyDataResults[0];
    final List<Map<String, dynamic>> admobRows = dailyDataResults[1];

    // 3. Map both datasets by normalized DateTime keys
    final Map<DateTime, Map<String, dynamic>> combinedMap = {};

    for (final row in adsenseRows) {
      final date = parseAdSenseDate(row['date']);
      if (date != null) {
        combinedMap[date] = {
          'earnings': row['earnings'],
          'pageViews': row['pageViews'],
          'impressions': row['impressions'],
          'clicks': row['clicks'],
        };
      }
    }

    for (final row in admobRows) {
      final date = parseAdMobDate(row['date']);
      if (date != null) {
        final existing = combinedMap[date];
        if (existing != null) {
          existing['earnings'] = existing['earnings'] + row['earnings'];
          existing['impressions'] = existing['impressions'] + row['impressions'];
          existing['clicks'] = existing['clicks'] + row['clicks'];
        } else {
          combinedMap[date] = {
            'earnings': row['earnings'],
            'pageViews': 0,
            'impressions': row['impressions'],
            'clicks': row['clicks'],
          };
        }
      }
    }

    // 4. Compute metrics over date ranges
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    double todayEarnings = 0.0;
    double yesterdayEarnings = 0.0;
    double thisMonthEarnings = 0.0;
    double lastMonthEarnings = 0.0;
    double lifetimeEarnings = 0.0;

    int totalPageViews = 0;
    int totalImpressions = 0;
    int totalClicks = 0;

    // Filter weekly earnings (last 7 days)
    final List<DateTime> last7Days = [];
    for (int i = 6; i >= 0; i--) {
      last7Days.add(todayDate.subtract(Duration(days: i)));
    }

    final Map<DateTime, double> weeklyEarningsMap = { for (var d in last7Days) d : 0.0 };

    combinedMap.forEach((date, values) {
      final earnings = values['earnings'] as double;
      final pageViews = values['pageViews'] as int;
      final impressions = values['impressions'] as int;
      final clicks = values['clicks'] as int;

      lifetimeEarnings += earnings;
      totalPageViews += pageViews;
      totalImpressions += impressions;
      totalClicks += clicks;

      if (date == todayDate) {
        todayEarnings += earnings;
      } else if (date == yesterdayDate) {
        yesterdayEarnings += earnings;
      }

      if (date.year == now.year && date.month == now.month) {
        thisMonthEarnings += earnings;
      } else if (date.year == (now.month == 1 ? now.year - 1 : now.year) &&
                 date.month == (now.month == 1 ? 12 : now.month - 1)) {
        lastMonthEarnings += earnings;
      }

      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (weeklyEarningsMap.containsKey(normalizedDate)) {
        weeklyEarningsMap[normalizedDate] = weeklyEarningsMap[normalizedDate]! + earnings;
      }
    });

    final List<double> dailyEarnings = [];
    final List<String> dailyLabels = [];
    const daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (final date in last7Days) {
      dailyEarnings.add(weeklyEarningsMap[date]!);
      dailyLabels.add(daysOfWeek[date.weekday - 1]);
    }

    final double combinedRpm = totalPageViews > 0
        ? (lifetimeEarnings / totalPageViews) * 1000
        : 0.0;

    return {
      'adsenseAccount': adsenseAccount,
      'revenueData': RevenueData(
        today: todayEarnings,
        yesterday: yesterdayEarnings,
        thisMonth: thisMonthEarnings,
        lastMonth: lastMonthEarnings,
        lifetime: lifetimeEarnings,
        pageViews: totalPageViews,
        impressions: totalImpressions,
        clicks: totalClicks,
        pageRpm: combinedRpm,
        dailyEarnings: dailyEarnings,
        dailyLabels: dailyLabels,
      )
    };
  }

  DateTime? parseAdSenseDate(String dateStr) {
    return DateTime.tryParse(dateStr);
  }

  DateTime? parseAdMobDate(String dateStr) {
    if (dateStr.length != 8) return null;
    final year = int.tryParse(dateStr.substring(0, 4));
    final month = int.tryParse(dateStr.substring(4, 6));
    final day = int.tryParse(dateStr.substring(6, 8));
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  String _twoDigits(int n) => n >= 10 ? "$n" : "0$n";
}
