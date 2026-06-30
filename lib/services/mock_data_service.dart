import '../models/revenue_data.dart';
import '../models/payment_data.dart';

class MockDataService {
  static RevenueData generateRevenueData() {
    return RevenueData(
      today: 42.80,
      yesterday: 56.40,
      thisMonth: 1240.50,
      lastMonth: 1450.80,
      lifetime: 38290.40,
      pageViews: 124500,
      impressions: 342900,
      clicks: 8910,
      pageRpm: 9.96,
      dailyEarnings: [48.20, 52.40, 45.10, 61.80, 50.30, 56.40, 42.80],
      dailyLabels: ['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon'],
      adsenseEarnings: 18290.40,
      admobEarnings: 20000.00,
      topAdUnits: [
        AdUnitPerformance(
          name: 'Responsive Header Banner',
          platform: 'AdSense',
          earnings: 10974.24,
          ctr: 1.42,
        ),
        AdUnitPerformance(
          name: 'App Interstitial (Home Activity)',
          platform: 'AdMob',
          earnings: 13000.00,
          ctr: 4.80,
        ),
        AdUnitPerformance(
          name: 'Main Feed Native Card',
          platform: 'AdSense',
          earnings: 7316.16,
          ctr: 2.15,
        ),
        AdUnitPerformance(
          name: 'App Reward Video (Unlock Items)',
          platform: 'AdMob',
          earnings: 7000.00,
          ctr: 8.92,
        ),
      ],
    );
  }

  static List<PaymentData> generatePaymentData() {
    return [
      PaymentData(
        date: '2026-06-21',
        amount: 1240.50,
        status: 'Issued',
        referenceNumber: 'PI-938210398',
        paymentMethod: 'Wire Transfer to Bank Account ...4321',
      ),
      PaymentData(
        date: '2026-05-21',
        amount: 1450.80,
        status: 'Issued',
        referenceNumber: 'PI-938102931',
        paymentMethod: 'Wire Transfer to Bank Account ...4321',
      ),
      PaymentData(
        date: '2026-04-21',
        amount: 1120.30,
        status: 'Issued',
        referenceNumber: 'PI-937984029',
        paymentMethod: 'Wire Transfer to Bank Account ...4321',
      ),
      PaymentData(
        date: '2026-03-21',
        amount: 1580.90,
        status: 'Issued',
        referenceNumber: 'PI-937812903',
        paymentMethod: 'Wire Transfer to Bank Account ...4321',
      ),
      PaymentData(
        date: '2026-02-21',
        amount: 1310.20,
        status: 'Issued',
        referenceNumber: 'PI-937651029',
        paymentMethod: 'Wire Transfer to Bank Account ...4321',
      ),
      PaymentData(
        date: '2026-01-21',
        amount: 1690.40,
        status: 'Issued',
        referenceNumber: 'PI-937482910',
        paymentMethod: 'Wire Transfer to Bank Account ...4321',
      ),
    ];
  }
}
