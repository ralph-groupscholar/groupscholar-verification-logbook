String formatListRows(List<Map<String, dynamic>> rows) {
  if (rows.isEmpty) {
    return 'No verification checks found for the selected filters.';
  }

  final headers = ['Date', 'Scholar', 'Scholar ID', 'Type', 'Status', 'By'];
  final widths = List<int>.filled(headers.length, 0);

  void consider(int index, String value) {
    if (value.length > widths[index]) {
      widths[index] = value.length;
    }
  }

  for (var i = 0; i < headers.length; i++) {
    widths[i] = headers[i].length;
  }

  for (final row in rows) {
    consider(0, row['performed_at'] as String? ?? '');
    consider(1, row['scholar_name'] as String? ?? '');
    consider(2, row['scholar_id'] as String? ?? '');
    consider(3, row['check_type'] as String? ?? '');
    consider(4, row['status'] as String? ?? '');
    consider(5, row['performed_by'] as String? ?? '');
  }

  String pad(String value, int width) => value.padRight(width);

  final buffer = StringBuffer();
  buffer.writeln(_row(headers, widths, pad));
  buffer.writeln(_row(widths.map((w) => '-' * w).toList(), widths, pad));

  for (final row in rows) {
    buffer.writeln(
      _row(
        [
          row['performed_at'] as String? ?? '',
          row['scholar_name'] as String? ?? '',
          row['scholar_id'] as String? ?? '',
          row['check_type'] as String? ?? '',
          row['status'] as String? ?? '',
          row['performed_by'] as String? ?? '',
        ],
        widths,
        pad,
      ),
    );
  }

  return buffer.toString().trimRight();
}

String formatSummaryTable(String title, Map<String, int> counts) {
  if (counts.isEmpty) {
    return '$title\nNo matching records.';
  }

  final headers = ['Label', 'Count'];
  var labelWidth = headers[0].length;
  var countWidth = headers[1].length;

  for (final entry in counts.entries) {
    if (entry.key.length > labelWidth) {
      labelWidth = entry.key.length;
    }
    final countLength = entry.value.toString().length;
    if (countLength > countWidth) {
      countWidth = countLength;
    }
  }

  final buffer = StringBuffer();
  buffer.writeln(title);
  buffer.writeln(
    _row(headers, [labelWidth, countWidth], (v, w) => v.padRight(w)),
  );
  buffer.writeln(
    _row(
      ['-' * labelWidth, '-' * countWidth],
      [labelWidth, countWidth],
      (v, w) => v.padRight(w),
    ),
  );

  for (final entry in counts.entries) {
    buffer.writeln(
      _row(
        [entry.key, entry.value.toString()],
        [labelWidth, countWidth],
        (v, w) => v.padRight(w),
      ),
    );
  }

  return buffer.toString().trimRight();
}

String _row(
  List<String> values,
  List<int> widths,
  String Function(String, int) pad,
) {
  final padded = <String>[];
  for (var i = 0; i < values.length; i++) {
    padded.add(pad(values[i], widths[i]));
  }
  return padded.join(' | ');
}
