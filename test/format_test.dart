import 'package:groupscholar_verification_logbook/groupscholar_verification_logbook.dart';
import 'package:test/test.dart';

void main() {
  test('formatListRows renders a table header and rows', () {
    final output = formatListRows([
      {
        'performed_at': '2026-02-08 10:30',
        'scholar_name': 'Avery Johnson',
        'scholar_id': 'GS-102',
        'check_type': 'Residency',
        'status': 'verified',
        'performed_by': 'Ralph',
      },
    ]);

    expect(output, contains('Date'));
    expect(output, contains('Avery Johnson'));
    expect(output, contains('Residency'));
  });

  test('formatSummaryTable renders summary rows', () {
    final output = formatSummaryTable('Status Totals', {
      'verified': 3,
      'pending': 1,
    });

    expect(output, contains('Status Totals'));
    expect(output, contains('verified'));
    expect(output, contains('3'));
  });
}
