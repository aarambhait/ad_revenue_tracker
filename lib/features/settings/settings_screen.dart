import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // User Profile Card
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      backgroundImage: appState.currentUser?.photoUrl != null
                          ? NetworkImage(appState.currentUser!.photoUrl!)
                          : null,
                      child: appState.currentUser?.photoUrl == null
                          ? Text(
                              appState.currentUser?.displayName?.isNotEmpty == true
                                  ? appState.currentUser!.displayName![0].toUpperCase()
                                  : 'P',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.currentUser?.displayName ?? 'Premium Publisher',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'pub-938210398210',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            appState.currentUser?.email ?? 'publisher@gmail.com',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Grouped Section: Preferences
              _buildSectionTitle('PREFERENCES'),
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
                child: Column(
                  children: [
                    // Theme Switch Row
                    _buildSettingsRow(
                      context,
                      icon: CupertinoIcons.moon_fill,
                      iconColor: const Color(0xFF5856D6),
                      title: 'Dark Mode',
                      trailing: Switch.adaptive(
                        value: appState.isDarkMode,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (value) {
                          appState.toggleTheme(value);
                        },
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    // Currency Picker Row
                    _buildSettingsRow(
                      context,
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      iconColor: const Color(0xFF34C759),
                      title: 'Display Currency',
                      trailing: DropdownButton<String>(
                        value: appState.currency,
                        dropdownColor: Theme.of(context).cardColor,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            appState.setCurrency(newValue);
                          }
                        },
                        items: <String>['USD', 'EUR', 'GBP', 'INR', 'NPR']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Grouped Section: Account Actions
              _buildSectionTitle('ACCOUNT'),
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
                child: _buildSettingsRow(
                  context,
                  icon: CupertinoIcons.square_arrow_right_fill,
                  iconColor: const Color(0xFFFF3B30),
                  title: 'Sign Out',
                  titleColor: const Color(0xFFFF3B30),
                  onTap: () {
                    _showSignOutDialog(context, appState);
                  },
                  trailing: const Icon(
                    CupertinoIcons.chevron_forward,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Grouped Section: Info
              _buildSectionTitle('INFORMATION'),
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
                child: Column(
                  children: [
                    _buildSettingsRow(
                      context,
                      icon: CupertinoIcons.info_circle_fill,
                      iconColor: const Color(0xFF8E8E93),
                      title: 'App Version',
                      trailing: Text(
                        '1.0.0',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingsRow(
                      context,
                      icon: CupertinoIcons.device_phone_portrait,
                      iconColor: const Color(0xFF007AFF),
                      title: 'Engine',
                      trailing: Text(
                        'Impeller (Metal)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AppState appState) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of AdTracker?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              appState.logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
