import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Create staggered animations for each element
    _animations = List.generate(
      6,
      (index) => CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.1,
          (index * 0.1) + 0.5,
          curve: Curves.easeOut,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      appBar: AppBar(
        title: Text('about_app'.tr()),
        backgroundColor: HomeScreenTheme.cardBackground(isDark),
        foregroundColor: HomeScreenTheme.primaryText(isDark),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // App Logo and Name
            FadeTransition(
              opacity: _animations[0],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_animations[0]),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: HomeScreenTheme.cardBackground(isDark),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [HomeScreenTheme.cardShadow(isDark)],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: HomeScreenTheme.accentBlue(
                            isDark,
                          ).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.psychology,
                          size: 48,
                          color: HomeScreenTheme.accentBlue(isDark),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Khuta',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: HomeScreenTheme.primaryText(isDark),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'app_description'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: HomeScreenTheme.secondaryText(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Features Section
            FadeTransition(
              opacity: _animations[1],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_animations[1]),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: HomeScreenTheme.cardBackground(isDark),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [HomeScreenTheme.cardShadow(isDark)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'app_features'.tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: HomeScreenTheme.primaryText(isDark),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        isDark,
                        Icons.wifi_off_rounded,
                        'offline_support'.tr(),
                        HomeScreenTheme.accentGreen(isDark),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        isDark,
                        Icons.security_rounded,
                        'secure_storage'.tr(),
                        HomeScreenTheme.accentBlue(isDark),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        isDark,
                        Icons.language_rounded,
                        'multilingual'.tr(),
                        HomeScreenTheme.accentOrange(isDark),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Version Info
            FadeTransition(
              opacity: _animations[2],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_animations[2]),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: HomeScreenTheme.cardBackground(isDark),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [HomeScreenTheme.cardShadow(isDark)],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        isDark,
                        'version'.tr(),
                        '1.0.0',
                        Icons.info_outline_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        isDark,
                        'developed_by'.tr(),
                        'Khuta Team',
                        Icons.code_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Legal Links
            FadeTransition(
              opacity: _animations[3],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_animations[3]),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: HomeScreenTheme.cardBackground(isDark),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [HomeScreenTheme.cardShadow(isDark)],
                  ),
                  child: Column(
                    children: [
                      _buildLinkButton(
                        isDark,
                        'privacy_policy'.tr(),
                        Icons.privacy_tip_rounded,
                        () async {
                          const url = 'https://khuta.app/privacy';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildLinkButton(
                        isDark,
                        'terms_of_service'.tr(),
                        Icons.description_rounded,
                        () async {
                          const url = 'https://khuta.app/terms';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildLinkButton(
                        isDark,
                        'feedback'.tr(),
                        Icons.feedback_rounded,
                        () async {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'feedback@khuta.app',
                            queryParameters: {'subject': 'Khuta App Feedback'},
                          );
                          if (await canLaunchUrl(emailLaunchUri)) {
                            await launchUrl(emailLaunchUri);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    bool isDark,
    IconData icon,
    String text,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: HomeScreenTheme.primaryText(isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(bool isDark, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: HomeScreenTheme.accentBlue(isDark).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: HomeScreenTheme.accentBlue(isDark),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: HomeScreenTheme.secondaryText(isDark),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: HomeScreenTheme.primaryText(isDark),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLinkButton(
    bool isDark,
    String text,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: HomeScreenTheme.accentBlue(isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: HomeScreenTheme.accentBlue(isDark),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: HomeScreenTheme.primaryText(isDark),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: HomeScreenTheme.secondaryText(isDark),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
