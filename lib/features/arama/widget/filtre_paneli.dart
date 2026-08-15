import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class FiltrePaneli extends StatelessWidget {
  const FiltrePaneli({
    required this.pasifleriDeGoster,
    required this.onDegisti,
    super.key,
  });

  final bool pasifleriDeGoster;
  final ValueChanged<bool> onDegisti;

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;
    return InkWell(
      onTap: () => onDegisti(!pasifleriDeGoster),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Checkbox(
              value: pasifleriDeGoster,
              onChanged: (bool? deger) => onDegisti(deger ?? false),
              activeColor: renkler.accent,
            ),
            Text(
              'Pasif (üyeliği sona ermiş) kayıtları da göster',
              style: AppTypography.caption.copyWith(color: renkler.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
