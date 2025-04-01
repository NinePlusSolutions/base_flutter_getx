import 'dart:convert';
import 'dart:io';

void main() async {
  const localizationFile = 'lib/lang/en_US.dart';

  final file = File(localizationFile);
  if (!file.existsSync()) {
    print('❌ Không tìm thấy file $localizationFile');
    return;
  }

  final content = await file.readAsString();

  // Extract the JSON-like content inside the Map
  final start = content.indexOf('{');
  final end = content.lastIndexOf('}');
  if (start == -1 || end == -1) {
    print('❌ Không tìm thấy dữ liệu JSON hợp lệ trong file.');
    return;
  }

  final jsonString = content.substring(start, end + 1);
  final Map<String, dynamic> map = jsonDecode(jsonString.replaceAll("\n", ""));

  final buffer = StringBuffer();
  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buffer.writeln('// ignore_for_file: non_constant_identifier_names');
  buffer.writeln("import 'package:get/get.dart';\n");
  buffer.writeln('class AppLanguageKey {');

  for (var key in map.keys) {
    buffer.writeln("  static String get $key => '$key'.tr;");
  }

  buffer.writeln('}');

  final outputFile = File('lib/lang/generate/app_language_key.dart');
  await outputFile.writeAsString(buffer.toString());

  print('✅ File app_language_key.dart đã được tạo thành công!');
}
