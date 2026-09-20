import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class AramaCubugu extends StatelessWidget {
  const AramaCubugu({
    required this.controller,
    required this.onDegisti,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onDegisti;

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    return TextField(
      controller: controller,
      onChanged: onDegisti,
      style: AppTypography.body.copyWith(color: renkler.textPrimary),
      decoration: InputDecoration(
        hintText: 'Ortak no, ad soyad, baba adı, adres...',
        prefixIcon: Icon(Icons.search, color: renkler.textSecondary),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (BuildContext context, TextEditingValue value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(Icons.clear, color: renkler.textSecondary, size: 18),
              tooltip: 'Aramayı Temizle',
              onPressed: () {
                controller.clear();
                onDegisti('');
              },
            );
          },
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + AppSpacing.xs,
        ),
      ),
    );
  }
}
