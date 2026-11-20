import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/favorites.dart';
import '../data/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/nature.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final top = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          PhotoHeader(
            image: AppImages.sunset,
            alignment: const Alignment(0.16, -0.3),
            height: 330 + top,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profil ve Ayarlar', style: AppText.screenTitle.copyWith(color: AppColors.onDark)),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.glass,
                          border: Border.all(color: AppColors.glassBorder, width: 2),
                        ),
                        child: const Icon(Icons.person_rounded, size: 32, color: AppColors.onDark),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ValueListenableBuilder<SessionData?>(
                          valueListenable: Session.current,
                          builder: (context, session, _) {
                            final name = session?.name ?? '';
                            final email = session?.email ?? '';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isEmpty ? 'Misafir' : name,
                                  style: AppText.title.copyWith(color: AppColors.onDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  session?.userId == null ? '${email.isEmpty ? '' : '$email · '}Hesap oluşturulmadı' : email,
                                  style: AppText.caption.copyWith(color: AppColors.onDarkMuted),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: Favorites.ids,
                    builder: (context, ids, _) => Row(
                      children: [
                        _Stat(value: '${ids.length}', label: 'Favori rota'),
                        const _Stat(value: '0', label: 'Tamamlanan'),
                        const _Stat(value: '0 km', label: 'Toplam mesafe'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            Text('Tercihler', style: textTheme.titleLarge),
            const SizedBox(height: 10),
            _SettingsGroup(
              children: [
                ValueListenableBuilder<SessionData?>(
                  valueListenable: Session.current,
                  builder: (context, session, _) => _SettingsRow(
                    icon: Icons.directions_bike_rounded,
                    label: 'Aktivite tercihi',
                    value: session?.activity ?? 'Bisiklet',
                  ),
                ),
                const _SettingsRow(icon: Icons.thermostat_rounded, label: 'Sıcaklık birimi', value: '°C'),
                const _SettingsRow(icon: Icons.notifications_none_rounded, label: 'Bildirimler', value: 'Açık'),
                const _SettingsRow(icon: Icons.language_rounded, label: 'Dil', value: 'Türkçe'),
              ],
            ),
            const SizedBox(height: 24),
            Text('Uygulama', style: textTheme.titleLarge),
            const SizedBox(height: 10),
            const _SettingsGroup(
              children: [
                _SettingsRow(icon: Icons.info_outline_rounded, label: 'Hakkında', value: 'v1.0.0'),
                _SettingsRow(icon: Icons.groups_outlined, label: 'Ekip', value: 'Patikanos'),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Çıkış yap'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.bad,
                side: const BorderSide(color: AppColors.bad),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: AppText.button,
              ),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış yapılsın mı?'),
        content: const Text('Bu cihazdaki adın, e-postan ve tercihlerin silinir. Uygulama baştan başlar.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.bad),
            child: const Text('Çıkış yap'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await Session.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value, style: AppText.section.copyWith(color: AppColors.onDark)),
            const SizedBox(height: 2),
            Text(label, style: AppText.caption.copyWith(color: AppColors.onDarkMuted)),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 60),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: AppColors.seaLight, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: AppColors.sea),
      ),
      title: Text(label, style: AppText.body),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
      onTap: () {},
    );
  }
}
