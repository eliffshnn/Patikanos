import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Renkler ve yazı stilleri yalnızca lib/theme/app_theme.dart içinde tanımlanır.
/// Ekranlarda AppColors, AppText ve AppShadows kullanılır; bu test yeni bir sabit değer eklenirse uyarır.
void main() {
  final rules = <String, RegExp>{
    'Renk kodu yerine AppColors kullanın': RegExp(r'Color\(0x'),
    'Material rengi yerine AppColors kullanın': RegExp(r'(?<!App)Colors\.(?!transparent\b)'),
    'Yazı boyutu yerine AppText stillerinden birini kullanın': RegExp(r'fontSize:'),
    'Yazı tipi yerine AppText stillerinden birini kullanın': RegExp(r'fontFamily:'),
  };

  test('Screens use only theme colors and text styles', () {
    final problems = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.startsWith('lib/theme/'));

    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        rules.forEach((message, pattern) {
          if (pattern.hasMatch(line)) problems.add('${file.path}:${i + 1}  $message\n    ${line.trim()}');
        });
      }
    }

    expect(problems, isEmpty, reason: '\n${problems.join('\n')}');
  });
}
