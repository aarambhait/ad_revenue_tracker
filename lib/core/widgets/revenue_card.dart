import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/formatter.dart';

class RevenueCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final IconData? icon;
  final String? comparisonText;
  final double? percentageChange;

  const RevenueCard({
    super.key,
    required this.title,
    required this.amount,
    required this.currency,
    this.icon,
    this.comparisonText,
    this.percentageChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: 20,
                  color: isDark ? Colors.white60 : Colors.black45,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppFormatter.currency(amount, currency),
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          if (comparisonText != null || percentageChange != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (percentageChange != null) ...[
                  Icon(
                    percentageChange! >= 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 14,
                    color: percentageChange! >= 0
                        ? const Color(0xFF34C759)
                        : const Color(0xFFFF3B30),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${percentageChange! >= 0 ? '+' : ''}${percentageChange!.toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: percentageChange! >= 0
                          ? const Color(0xFF34C759)
                          : const Color(0xFFFF3B30),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (comparisonText != null)
                  Expanded(
                    child: Text(
                      comparisonText!,
                      style: Theme.of(context).textTheme.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
