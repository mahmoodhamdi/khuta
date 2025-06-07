import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';

class AnimatedBottomBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTap;

  const AnimatedBottomBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = context.locale.languageCode == 'ar';

    return AnimatedBottomNavigationBar(
      icons: [Icons.home_rounded, Icons.settings_rounded],
      activeIndex: activeIndex,
      gapLocation: GapLocation.none,
      notchSmoothness: NotchSmoothness.smoothEdge,

      onTap: onTap,
      backgroundColor: HomeScreenTheme.cardBackground(isDark),
      activeColor: HomeScreenTheme.accentBlue(isDark),
      inactiveColor: HomeScreenTheme.secondaryText(isDark),
      iconSize: 24,

      splashSpeedInMilliseconds: 300,
      splashColor: HomeScreenTheme.accentBlue(isDark).withOpacity(0.1),
    );
  }
}
