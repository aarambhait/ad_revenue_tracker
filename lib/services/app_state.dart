import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/revenue_data.dart';
import '../models/payment_data.dart';
import 'mock_data_service.dart';
import 'google_ads_api_service.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  String _currency = 'USD';
  bool _isLoggedIn = false;
  String? _errorMessage;

  // Google OAuth 2.0 Credentials with specific AdSense/AdMob readonly scopes
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '676044285538-vdothcgn8rrcfv90ohn2jfiqisc0ek3i.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/adsense.readonly',
      'https://www.googleapis.com/auth/admob.readonly',
    ],
  );

  GoogleSignInAccount? _currentUser;

  RevenueData? _revenueData;
  List<PaymentData> _payments = [];
  bool _isLoading = false;

  bool get isDarkMode => _isDarkMode;
  String get currency => _currency;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  GoogleSignInAccount? get currentUser => _currentUser;
  RevenueData? get revenueData => _revenueData;
  List<PaymentData> get payments => _payments;
  bool get isLoading => _isLoading;

  AppState() {
    _loadPreferences();

    // Listen to Google Sign-In updates
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      _currentUser = account;
      _isLoggedIn = account != null;
      if (account != null) {
        await loadAdSenseData();
      } else {
        _revenueData = null;
        _payments = [];
        _errorMessage = null;
        notifyListeners();
      }
    });

    // Attempt silent sign-in on startup
    _googleSignIn.signInSilently();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _currency = prefs.getString('currency') ?? 'USD';
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    _currency = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', value);
    notifyListeners();
  }

  Future<bool> login() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final account = await _googleSignIn.signIn();
      _isLoading = false;

      if (account != null) {
        _currentUser = account;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      debugPrint('Google Sign-In Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
    _currentUser = null;
    _isLoggedIn = false;
    _revenueData = null;
    _payments = [];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadAdSenseData() async {
    final account = _currentUser;
    if (account == null) {
      _errorMessage = 'Sign in required.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Ensure user granted the specific read-only scopes
      final requiredScopes = [
        'https://www.googleapis.com/auth/adsense.readonly',
        'https://www.googleapis.com/auth/admob.readonly',
      ];
      final hasScopes = await _googleSignIn.canAccessScopes(requiredScopes);
      if (!hasScopes) {
        final authorized = await _googleSignIn.requestScopes(requiredScopes);
        if (!authorized) {
          throw Exception('Google AdSense and AdMob scopes are required to track your earnings.');
        }
      }

      final authHeaders = await account.authHeaders;
      final apiService = GoogleAdsApiService(authHeaders: authHeaders);

      _revenueData = await apiService.fetchAdSenseData();
      _payments = MockDataService.generatePaymentData();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _revenueData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshData() {
    loadAdSenseData();
  }
}
