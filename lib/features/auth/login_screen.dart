import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;

  void _handleLogin() async {
    setState(() {
      _isSigningIn = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.login();

    if (!mounted) return;

    setState(() {
      _isSigningIn = false;
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign-In failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonBg = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final buttonFg = isDark ? Colors.black : Colors.white;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(), // Top Spacer

              // Logo & App Header
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.4)
                              : Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Stack(
                      children: [
                        // Left bar (Yellow/Orange)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 16,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFB900),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        // Middle bar (Green)
                        Positioned(
                          left: 20,
                          top: 10,
                          bottom: 0,
                          width: 16,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF107C41),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        // Right bar (Blue)
                        Positioned(
                          left: 40,
                          top: 24,
                          bottom: 0,
                          width: 16,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF00A4EF),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AdTracker',
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Google AdSense & AdMob Earnings Tracker',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Button & Footer Info
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSigningIn ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonBg,
                        foregroundColor: buttonFg,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: Colors.transparent,
                      ),
                      child: _isSigningIn
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(buttonFg),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: CustomPaint(
                                    painter: _GoogleLogoPainter(buttonBg),
                                  ),
                                ),
                                Text(
                                  'Sign in with Google',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'By logging in, you authorize AdTracker to display your earnings, report logs, and payment details.',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 11,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  final Color buttonBgColor;

  _GoogleLogoPainter(this.buttonBgColor);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double radius = w / 2;
    final double innerRadius = radius * 0.55;

    final Paint bluePaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final Paint greenPaint = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;
    final Paint yellowPaint = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    final Paint redPaint = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Draw 4 sectors
    canvas.drawArc(rect, -2.4, 1.4, true, redPaint);
    canvas.drawArc(rect, -3.8, 1.4, true, yellowPaint);
    canvas.drawArc(rect, 0.8, 1.4, true, greenPaint);
    canvas.drawArc(rect, -0.6, 1.4, true, bluePaint);

    // Draw G horizontal bar
    canvas.drawRect(
      Rect.fromLTRB(cx, cy - radius * 0.25, cx + radius, cy + radius * 0.25),
      bluePaint,
    );

    // Cutout center circle
    canvas.drawCircle(Offset(cx, cy), innerRadius, Paint()..color = buttonBgColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
