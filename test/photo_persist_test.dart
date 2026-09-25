import 'dart:io';

import 'package:dog_help_pune/src/persistence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persistReportPhoto keeps a durable copy after the source is deleted', () async {
    final root = await Directory.systemTemp.createTemp('dog_help_photos_');
    addTearDown(() => root.delete(recursive: true));

    final source = File('${root.path}/cache/picked.jpg');
    await source.parent.create(recursive: true);
    await source.writeAsBytes(List<int>.filled(64, 7));

    final saved = await persistReportPhoto(source.path, id: 'PC-TEST-1', documents: root);
    expect(File(saved).existsSync(), isTrue);
    expect(saved, contains('report_photos'));
    expect(saved, contains('PC-TEST-1'));

    await source.delete();
    expect(source.existsSync(), isFalse);
    expect(File(saved).existsSync(), isTrue);
    expect(await File(saved).readAsBytes(), List<int>.filled(64, 7));
  });
}
