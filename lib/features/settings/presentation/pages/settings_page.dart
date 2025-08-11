import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/theme_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/log_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sozlamalar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Section
          _buildSectionTitle('Ko\'rinish'),
          _buildThemeSelector(),
          const SizedBox(height: 24),

          // App Settings Section
          _buildSectionTitle('Ilova sozlamalari'),
          _buildSettingsCard([
            AnimatedBuilder(
              animation: PreferencesService.instance,
              builder: (context, child) {
                return _buildSettingsTile(
                  icon: Iconsax.notification,
                  title: 'Bildirishnomalar',
                  subtitle: 'Ilova haqida yangiliklar va eslatmalar',
                  trailing: Switch(
                    value: PreferencesService.instance.notificationsEnabled,
                    onChanged: (value) {
                      LogService.info('Settings', 'Notifications toggled',
                          data: {
                            'enabled': value,
                          });
                      PreferencesService.instance
                          .setNotificationsEnabled(value);
                    },
                  ),
                );
              },
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Iconsax.language_square,
              title: 'Til',
              subtitle: 'O\'zbek tili',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                LogService.info('Settings', 'Language settings tapped');
                _showLanguageDialog();
              },
            ),
            const Divider(height: 1),
            AnimatedBuilder(
              animation: PreferencesService.instance,
              builder: (context, child) {
                return _buildSettingsTile(
                  icon: Iconsax.location,
                  title: 'Joylashuv',
                  subtitle: 'GPS va joylashuv xizmatlari',
                  trailing: Switch(
                    value: PreferencesService.instance.locationEnabled,
                    onChanged: (value) {
                      LogService.info('Settings', 'Location toggled', data: {
                        'enabled': value,
                      });
                      PreferencesService.instance.setLocationEnabled(value);
                    },
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 24),

          // About Section
          _buildSectionTitle('Ilova haqida'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Iconsax.share,
              title: 'Ilovani ulashish',
              subtitle: 'Do\'stlaringiz bilan ulashing',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                LogService.info('Settings', 'Share app tapped');
                _shareApp();
              },
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Iconsax.star,
              title: 'Ilovani baholang',
              subtitle: 'Play Store da baho qoldiring',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                LogService.info('Settings', 'Rate app tapped');
                _showRatingDialog();
              },
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Iconsax.message_question,
              title: 'Yordam va qo\'llab-quvvatlash',
              subtitle: 'Savollar va muammolar',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                LogService.info('Settings', 'Help and support tapped');
                _showHelpDialog();
              },
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Iconsax.info_circle,
              title: 'Ilova haqida',
              subtitle: 'Versiya 1.0.0',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                LogService.info('Settings', 'About app tapped');
                _showAboutDialog();
              },
            ),
          ]),
          const SizedBox(height: 24),

          // Privacy Section
          _buildSectionTitle('Maxfiylik'),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Iconsax.shield_tick,
              title: 'Maxfiylik siyosati',
              subtitle: 'Ma\'lumotlaringiz qanday ishlatiladi',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                LogService.info('Settings', 'Privacy policy tapped');
                _showPrivacyDialog();
              },
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Iconsax.document_text,
              title: 'Foydalanish shartlari',
              subtitle: 'Xizmat shartlari',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                LogService.info('Settings', 'Terms of service tapped');
                _showTermsDialog();
              },
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.colorfilter,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Mavzu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: ThemeService.instance,
              builder: (context, child) {
                return Column(
                  children: [
                    _buildThemeOption(
                      ThemeMode.light,
                      'Yorug\'',
                      'Oq rang asosidagi mavzu',
                      Iconsax.sun_1,
                    ),
                    const SizedBox(height: 8),
                    _buildThemeOption(
                      ThemeMode.dark,
                      'Qorong\'i',
                      'Qora rang asosidagi mavzu',
                      Iconsax.moon,
                    ),
                    const SizedBox(height: 8),
                    _buildThemeOption(
                      ThemeMode.system,
                      'Sistema',
                      'Qurilma sozlamasiga mos',
                      Iconsax.mobile,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeMode themeMode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = ThemeService.instance.themeMode == themeMode;

    return InkWell(
      onTap: () {
        LogService.info('Settings', 'Theme changed', data: {
          'themeMode': themeMode.toString(),
        });
        ThemeService.instance.setThemeMode(themeMode);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
          border: isSelected
              ? Border.all(color: Theme.of(context).colorScheme.primary)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _shareApp() {
    const appUrl =
        'https://play.google.com/store/apps/details?id=uz.eldor_dev.toshkent_guide';
    Share.share(
      'Toshkent Guide - Toshkent shahri haqida to\'liq ma\'lumot olish uchun eng yaxshi ilova!\n\n$appUrl',
      subject: 'Toshkent Guide ilovasini sinab ko\'ring',
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Til tanlash'),
        content: const Text(
            'Hozircha faqat o\'zbek tili mavjud. Keyingi yangilanishlarda boshqa tillar qo\'shiladi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ilovani baholang'),
        content: const Text(
            'Agar ilova sizga yoqsa, Play Store da baho qoldiring va izoh yozing!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keyinroq'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openPlayStore();
            },
            child: const Text('Baholash'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPlayStore() async {
    const appUrl =
        'https://play.google.com/store/apps/details?id=uz.eldor_dev.toshkent_guide';
    final uri = Uri.parse(appUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        LogService.info('Settings', 'Play Store opened successfully');
      } else {
        LogService.error('Settings', 'Could not launch Play Store URL');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Play Store ochishda xatolik yuz berdi'),
            ),
          );
        }
      }
    } catch (e) {
      LogService.error('Settings', 'Error opening Play Store', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Play Store ochishda xatolik yuz berdi'),
          ),
        );
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yordam'),
        content: const Text(
            'Savollaringiz bormi? Bizga yozing:\n\nEmail: support@toshkentguide.uz\nTelegram: @toshkentguide'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ilova haqida'),
        content: const Text(
            'Toshkent Guide\nVersiya: 1.0.0\n\nToshkent shahri haqida to\'liq ma\'lumot beruvchi ilova.\n\n© 2024 Toshkent Guide'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maxfiylik siyosati'),
        content: const SingleChildScrollView(
          child: Text(
            'Biz sizning shaxsiy ma\'lumotlaringizni himoya qilishni jiddiy qabul qilamiz.\n\n'
            '• Joylashuv ma\'lumotlari faqat xizmat ko\'rsatish uchun ishlatiladi\n'
            '• Shaxsiy ma\'lumotlar uchinchi shaxslarga berilmaydi\n'
            '• Barcha ma\'lumotlar xavfsiz saqlanadi\n\n'
            'To\'liq maxfiylik siyosati bilan tanishish uchun veb-saytimizga tashrif buyuring.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Foydalanish shartlari'),
        content: const SingleChildScrollView(
          child: Text(
            'Ilovadan foydalanish orqali siz quyidagi shartlarni qabul qilasiz:\n\n'
            '• Ilova faqat shaxsiy foydalanish uchun\n'
            '• Ma\'lumotlarni noto\'g\'ri ishlatish taqiqlanadi\n'
            '• Ilova jamoasi mas\'uliyatni o\'z zimmasiga olmaydi\n\n'
            'To\'liq shartlar bilan tanishish uchun veb-saytimizga tashrif buyuring.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
