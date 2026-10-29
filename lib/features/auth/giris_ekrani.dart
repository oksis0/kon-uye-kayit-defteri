import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../data/uzak/auth_servisi.dart';
import 'auth_provider.dart';

/// Tek ortak hesap girişi (PLAN.md §12.2). Kayıt ol / şifre sıfırla ekranı
/// bilinçli olarak YOK — hesap Firebase Konsolu'ndan elle oluşturuluyor.
///
/// Firebase Auth oturumu cihazda kalıcı olduğu için bu ekran pratikte
/// kurulumda bir kez görünür.
class GirisEkrani extends ConsumerStatefulWidget {
  const GirisEkrani({super.key});

  @override
  ConsumerState<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends ConsumerState<GirisEkrani> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ePostaController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  bool _sifreGoster = false;

  @override
  void dispose() {
    _ePostaController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  Future<void> _girisYap() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(girisIslemiProvider.notifier).girisYap(
          ePosta: _ePostaController.text.trim(),
          sifre: _sifreController.text,
        );
  }

  String _hataMesajiCevir(Object hata) {
    if (hata is AuthServisiHatasi) {
      return hata.mesaj;
    }
    final String hataMetni = hata.toString().toLowerCase();
    if (hataMetni.contains('keychain') || hataMetni.contains('-34018')) {
      return 'macOS Anahtar Zinciri (Keychain) erişimi engellendi. "Çevrimdışı / Yerel Olarak Devam Et" butonu ile uygulamaya doğrudan erişebilirsiniz.';
    }
    if (hata is FirebaseAuthException) {
      return switch (hata.code) {
        'user-not-found' || 'invalid-credential' || 'wrong-password' =>
          'E-posta veya şifre hatalı.',
        'invalid-email' => 'Geçersiz e-posta adresi.',
        'user-disabled' => 'Bu hesap devre dışı bırakılmış.',
        'too-many-requests' => 'Çok fazla başarısız deneme. Lütfen biraz sonra tekrar deneyin.',
        'network-request-failed' => 'İnternet bağlantısı kurulamadı. Lütfen bağlantınızı kontrol edin veya "Çevrimdışı / Yerel Olarak Devam Et" butonunu kullanın.',
        _ => 'Giriş yapılamadı: ${hata.message ?? hata.code}',
      };
    }
    return 'Giriş yapılamadı: $hata';
  }

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    final AsyncValue<void> girisDurumu = ref.watch(girisIslemiProvider);

    ref.listen<AsyncValue<void>>(girisIslemiProvider, (AsyncValue<void>? _, AsyncValue<void> yeni) {
      if (yeni.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_hataMesajiCevir(yeni.error!))),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'KON Üye Kayıt Defteri',
                    textAlign: TextAlign.center,
                    style: AppTypography.headline.copyWith(color: renkler.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Devam etmek için giriş yapın',
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(color: renkler.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: _ePostaController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-posta'),
                    validator: (String? deger) =>
                        (deger == null || deger.trim().isEmpty) ? 'Zorunlu alan' : null,
                    onFieldSubmitted: (_) => _girisYap(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _sifreController,
                    obscureText: !_sifreGoster,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      suffixIcon: IconButton(
                        icon: Icon(_sifreGoster ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _sifreGoster = !_sifreGoster),
                      ),
                    ),
                    validator: (String? deger) =>
                        (deger == null || deger.isEmpty) ? 'Zorunlu alan' : null,
                    onFieldSubmitted: (_) => _girisYap(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: girisDurumu.isLoading ? null : _girisYap,
                    child: girisDurumu.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Giriş Yap'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => ref.read(authServisiProvider).yerelGirisYap(),
                    icon: const Icon(Icons.offline_pin_outlined),
                    label: const Text('Çevrimdışı / Yerel Olarak Devam Et'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
