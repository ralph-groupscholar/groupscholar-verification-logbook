import 'dart:io';

import 'package:groupscholar_verification_logbook/groupscholar_verification_logbook.dart';

Future<void> main(List<String> arguments) async {
  final code = await handleCommand(arguments);
  if (code != 0) {
    exit(code);
  }
}
