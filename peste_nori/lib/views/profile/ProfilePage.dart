import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peste_nori/globals.dart';

import 'AccountActions.dart';

enum _TrailPreference { bear, weather, closure, accident, visibility }

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _storage = FlutterSecureStorage();
  late final _userId = FirebaseAuth.instance.currentUser?.uid;
  final _preferences = <_TrailPreference, bool>{};
  bool _preferencesLoaded = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  String _key(_TrailPreference preference) =>
      'PROFILE_${_userId}_${preference.name}';

  Future<void> _loadPreferences() async {
    if (_userId == null) return;
    try {
      final values = await Future.wait([
        for (final preference in _TrailPreference.values)
          _storage.read(key: _key(preference)),
      ]);
      if (!mounted) return;
      setState(() {
        for (final preference in _TrailPreference.values) {
          _preferences[preference] = values[preference.index] == 'true';
        }
        _preferencesLoaded = true;
      });
    } catch (error) {
      debugPrint('Could not load profile preferences: $error');
      if (mounted) {
        _showInfo(translations.profileSettingsLoadError);
      }
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      debugPrint('Could not save profile setting: $error');
      if (mounted) _showInfo(translations.profileSettingsSaveError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _preferenceTile(_TrailPreference preference, String label) {
    return SwitchListTile(
      title: Text(label),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      value: _preferences[preference] ?? false,
      onChanged: !_preferencesLoaded || _busy
          ? null
          : (enabled) => _runAction(() async {
              await _storage.write(
                key: _key(preference),
                value: enabled.toString(),
              );
              if (mounted) setState(() => _preferences[preference] = enabled);
            }),
    );
  }

  Widget _sectionNote(String message) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
    child: Text(message, style: Theme.of(context).textTheme.bodySmall),
  );

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final isDark = themeNotifier.isDark;

    return Scaffold(
      appBar: AppBar(title: Text(translations.profile)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(translations.profileLanguage),
                  trailing: DropdownButton<String>(
                    value: language,
                    onChanged: _busy
                        ? null
                        : (code) {
                            if (code != null && code != language) {
                              _runAction(
                                () => localeNotifier.select(Locale(code)),
                              );
                            }
                          },
                    items: [
                      DropdownMenuItem(
                        value: 'ro',
                        child: Text(translations.profileRomanian),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(translations.profileEnglish),
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: Text(translations.profileDarkMode),
                  subtitle: Text(
                    isDark ? translations.profileOn : translations.profileOff,
                  ),
                  value: isDark,
                  onChanged: _busy
                      ? null
                      : (enabled) => _runAction(
                          () => themeNotifier.setDarkMode(enabled),
                        ),
                ),
                ExpansionTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(translations.profileNotifications),
                  children: [
                    _preferenceTile(
                      _TrailPreference.bear,
                      translations.profileBearAlert,
                    ),
                    _preferenceTile(
                      _TrailPreference.weather,
                      translations.profileSevereWeather,
                    ),
                    _preferenceTile(
                      _TrailPreference.closure,
                      translations.profileTrailClosure,
                    ),
                    _preferenceTile(
                      _TrailPreference.accident,
                      translations.profileAccidents,
                    ),
                    _sectionNote(translations.profileNotificationInfo),
                  ],
                ),
                ExpansionTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(translations.profilePrivacy),
                  children: [
                    _preferenceTile(
                      _TrailPreference.visibility,
                      translations.profileTrailVisibility,
                    ),
                    _sectionNote(translations.profileVisibilityInfo),
                  ],
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.mail_outline),
                  title: Text(translations.profileSupport),
                  onTap: () =>
                      _showInfo(translations.profileSupportUnavailable),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(translations.profileTerms),
                  onTap: () => _showInfo(translations.profileTermsUnavailable),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(translations.signOut),
                  enabled: !_busy,
                  onTap: () => _runAction(() => signOutOfAccount(context)),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(translations.deleteAccount),
                  textColor: Theme.of(context).colorScheme.error,
                  iconColor: Theme.of(context).colorScheme.error,
                  enabled: !_busy,
                  onTap: () =>
                      _runAction(() => confirmAccountDeletion(context)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                '${translations.appTitle} v1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
