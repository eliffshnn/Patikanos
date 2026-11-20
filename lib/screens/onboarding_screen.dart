import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/user_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

// ---------------------------------------------------------------------------
// Onboarding: 3 sayfa
// ---------------------------------------------------------------------------

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();

  void _goTo(int page) => _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );

  void _finish() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.pineDark,
        body: PageView(
          controller: _controller,
          children: [
            _IntroPage(
              image: 'assets/onboarding/coast-hike.jpg',
              imageAlignment: const Alignment(0, -0.2),
              eyebrow: 'MUĞLA · BİSİKLET & YÜRÜYÜŞ',
              titleStart: "Muğla'yı ",
              titleItalic: 'patika patika',
              titleEnd: ' keşfet',
              body:
                  'Çam ormanlarından Ege kıyısına, bisiklet ve yürüyüş rotaları tek yerde.',
              step: 0,
              buttonLabel: 'Başlayalım',
              onNext: () => _goTo(1),
              onSkip: () => _goTo(2),
            ),
            _IntroPage(
              image: 'assets/onboarding/forest-bike.jpg',
              imageAlignment: const Alignment(0.1, 0),
              eyebrow: 'AKILLI ZAMANLAMA',
              titleStart: 'Havanın en güzel ',
              titleItalic: 'saatini',
              titleEnd: ' yakala',
              body:
                  'Sıcaklık, rüzgâr, yağmur ve UV tek bir skorda. Her akşam yarının en iyi saatini sana bildiririz.',
              step: 1,
              buttonLabel: 'Devam',
              onNext: () => _goTo(2),
              onSkip: () => _goTo(2),
              onBack: () => _goTo(0),
              overlay: const _ScoreCard(),
            ),
            _SetupPage(onBack: () => _goTo(1), onDone: _finish),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. ve 2. sayfa: tam ekran fotoğraf + alt metin
// ---------------------------------------------------------------------------

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.image,
    required this.imageAlignment,
    required this.eyebrow,
    required this.titleStart,
    required this.titleItalic,
    required this.titleEnd,
    required this.body,
    required this.step,
    required this.buttonLabel,
    required this.onNext,
    required this.onSkip,
    this.onBack,
    this.overlay,
  });

  final String image;
  final Alignment imageAlignment;
  final String eyebrow;
  final String titleStart;
  final String titleItalic;
  final String titleEnd;
  final String body;
  final int step;
  final String buttonLabel;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback? onBack;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover, alignment: imageAlignment),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.photoScrim,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      if (onBack == null)
                        Text('Patikanos',
                            style: AppText.section.copyWith(color: AppColors.onDark))
                      else
                        _BackButton(onPressed: onBack!),
                      const Spacer(),
                      TextButton(
                        onPressed: onSkip,
                        child: Text('Atla',
                            style: AppText.label.copyWith(color: AppColors.onDark)),
                      ),
                    ],
                  ),
                ),
                if (overlay != null) ...[
                  const SizedBox(height: 16),
                  overlay!,
                ],
                const Spacer(),
                Text(
                  eyebrow,
                  style: AppText.eyebrow.copyWith(color: AppColors.onDarkSubtle),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: AppText.title.copyWith(color: AppColors.onDark),
                    children: [
                      TextSpan(text: titleStart),
                      TextSpan(
                        text: titleItalic,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      TextSpan(text: titleEnd),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: AppText.bodyMuted.copyWith(color: AppColors.onDarkMuted),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _Dots(step: step),
                    const Spacer(),
                    _PillButton(label: buttonLabel, onPressed: onNext),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 2. sayfadaki buzlu cam skor kartı (örnek değerler; ileride WeatherService'e
// bağlanabilir)
// ---------------------------------------------------------------------------

class _ScoreCard extends StatelessWidget {
  const _ScoreCard();

  @override
  Widget build(BuildContext context) {
    const soft = AppColors.onDarkMuted;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.glassDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text('BUGÜN · AKYAKA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.eyebrow.copyWith(color: soft)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: AppColors.onDarkGood, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text('Bisiklet için harika',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.label.copyWith(color: AppColors.onDarkGood)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('86', style: AppText.score.copyWith(color: AppColors.onDark)),
                  const SizedBox(width: 4),
                  Text('/ 100',
                      style: AppText.caption.copyWith(color: soft)),
                  const SizedBox(width: 12),
                  // Büyük yazı ayarında taşmak yerine küçülür
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('En iyi saat', style: AppText.caption.copyWith(color: soft)),
                          Text('07:00 – 09:00',
                              style: AppText.section.copyWith(color: AppColors.onDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                  height: 1, color: AppColors.glassBorder),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 4,
                children: [
                  for (final t in ['18° hissedilen', 'Rüzgâr 9 km/s', 'UV 3'])
                    Text(t,
                        style: AppText.caption.copyWith(color: AppColors.onDark)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. sayfa: tercih + hesap oluşturma (POST /users, PUT /preferences)
// ---------------------------------------------------------------------------

class _SetupPage extends StatefulWidget {
  const _SetupPage({required this.onBack, required this.onDone});

  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  State<_SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<_SetupPage> {
  static const _activities = [
    ('Bisiklet', 'cycling'),
    ('Yürüyüş', 'walking'),
    ('İkisi de', 'both'),
  ];

  final _name = TextEditingController();
  final _email = TextEditingController();
  int _selected = 0;
  bool _loading = false;
  String? _error;

  /// Sunucuya ulaşılamadıysa kullanıcı hesap oluşturmadan da devam edebilir.
  bool _offline = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Adını yazar mısın?');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'Geçerli bir e-posta adresi gir.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _offline = false;
    });

    final (label, code) = _activities[_selected];
    try {
      final user = await UserService.createUser(name: name, email: email);
      await UserService.updatePreferences(user.id, {'activity': code});
      await Session.save(SessionData(userId: user.id, name: name, email: email, activity: label));
      if (mounted) widget.onDone();
    } on UserServiceException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Sunucuya bağlanılamadı. İnternet bağlantını kontrol et.';
          _offline = true;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _continueOffline() async {
    final (label, _) = _activities[_selected];
    await Session.save(SessionData(name: _name.text.trim(), email: _email.text.trim(), activity: label));
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/onboarding/sunset-climb.jpg',
          fit: BoxFit.cover,
          alignment: const Alignment(0.16, -0.36),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.photoScrimTop,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 0, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: _BackButton(onPressed: widget.onBack),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            reverse: true,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
                  decoration: BoxDecoration(
                    color: AppColors.photoSheet,
                    border: Border(
                      top: BorderSide(
                          color: AppColors.glassBorder),
                    ),
                  ),
                  child: AutofillGroup(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Dots(step: 2),
                        const SizedBox(height: 12),
                        Text.rich(
                          TextSpan(
                            style: AppText.title.copyWith(color: AppColors.onDark),
                            children: const [
                              TextSpan(text: 'Seni biraz '),
                              TextSpan(
                                text: 'tanıyalım',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _Label('NE YAPMAYI SEVERSİN?'),
                        const SizedBox(height: 6),
                        _ActivityPicker(
                          labels: [for (final a in _activities) a.$1],
                          selected: _selected,
                          onChanged: (i) => setState(() => _selected = i),
                        ),
                        const SizedBox(height: 10),
                        const _Label('ADIN'),
                        const SizedBox(height: 5),
                        _GlassField(
                          controller: _name,
                          hint: 'Adını yaz',
                          keyboardType: TextInputType.name,
                          autofillHints: const [AutofillHints.name],
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 10),
                        const _Label('E-POSTA'),
                        const SizedBox(height: 5),
                        _GlassField(
                          controller: _email,
                          hint: 'ornek@mail.com',
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Text(_error!,
                              style: AppText.label.copyWith(color: AppColors.onDarkBad)),
                        ],
                        const SizedBox(height: 16),
                        _PillButton(
                          label: 'Keşfetmeye başla',
                          onPressed: _loading ? null : _submit,
                          loading: _loading,
                          expand: true,
                        ),
                        if (_offline)
                          TextButton(
                            onPressed: _loading ? null : _continueOffline,
                            child: Text('Hesap olmadan devam et',
                                style: AppText.label.copyWith(color: AppColors.onDark)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Küçük parçalar
// ---------------------------------------------------------------------------

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Geri',
      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onDark),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Adım ${step + 1} / 3',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 6),
              width: i == step ? 22 : 10,
              height: 4,
              decoration: BoxDecoration(
                color: i == step ? AppColors.onDark : AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.sand,
        foregroundColor: AppColors.pineDark,
        disabledBackgroundColor: AppColors.sandDark,
        minimumSize: expand ? const Size.fromHeight(48) : const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: const StadiumBorder(),
        textStyle: AppText.button,
      ),
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.pineDark),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppText.eyebrow.copyWith(color: AppColors.onDarkMuted),
    );
  }
}

class _ActivityPicker extends StatelessWidget {
  const _ActivityPicker({
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == selected
                            ? AppColors.sand
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        labels[i],
                        style: AppText.label.copyWith(
                            color: i == selected
                                ? AppColors.pineDark
                                : AppColors.onDark),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.autofillHints,
    required this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<String> autofillHints;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      cursorColor: AppColors.onDark,
      style: AppText.body.copyWith(color: AppColors.onDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.body.copyWith(color: AppColors.onDarkSubtle),
        filled: true,
        fillColor: AppColors.glass,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: border(AppColors.glassBorder),
        enabledBorder: border(AppColors.glassBorder),
        focusedBorder: border(AppColors.sunsetLight, 2),
      ),
    );
  }
}
