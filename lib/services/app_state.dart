import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/revenue_data.dart';
import '../models/payment_data.dart';
import 'mock_data_service.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  String _currency = 'USD';
  bool _isLoggedIn = false;

  // Google OAuth 2.0 Credentials
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '676044285538-vdothcgn8rrcfv90ohn2jfiqisc0ek3i.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  GoogleSignInAccount? _currentUser;

  RevenueData? _revenueData;
  List<PaymentData> _payments = [];
  bool _isLoading = false;

  bool get isDarkMode => _isDarkMode;
  String get currency => _currency;
  bool get isLoggedIn => _isLoggedIn;
  GoogleSignInAccount? get currentUser => _currentUser;
  RevenueData? get revenueData => _revenueData;
  List<PaymentData> get payments => _payments;
  bool get isLoading => _isLoading;

  AppState() {
    _loadPreferences();
    _loadMockData();

    // Listen to Google Sign-In updates
    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
      _isLoggedIn = account != null;
      notifyListeners();
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
    notifyListeners();
  }

  void _loadMockData() {
    _isLoading = true;
    notifyListeners();

    // Simulate short network delay for professional look
    Future.delayed(const Duration(milliseconds: 600), () {
      _revenueData = MockDataService.generateRevenueData();
      _payments = MockDataService.generatePaymentData();
      _isLoading = false;
      notifyListeners();
    });
  }

  void refreshData() {
    _loadMockData();
  }
}
