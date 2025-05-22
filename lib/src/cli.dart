import 'dart:io';

import 'package:args/args.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

import 'config.dart';
import 'format.dart';

const _schema = 'gsvl';
const _table = 'verification_checks';

ArgParser buildParser() {
  final parser = ArgParser()
    ..addCommand('add')
    ..addCommand('list')
    ..addCommand('summary')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.');

  parser.commands['add']!
    ..addOption('scholar', abbr: 's', help: 'Scholar full name.')
    ..addOption('scholar-id', help: 'Scholar internal ID.')
    ..addOption('type', abbr: 't', help: 'Verification check type.')
    ..addOption('status', abbr: 'x', help: 'Verification status.')
    ..addOption('notes', abbr: 'n', help: 'Optional notes.')
    ..addOption('by', abbr: 'b', help: 'Performed by (staff).')
    ..addOption('performed-at', help: 'ISO timestamp (defaults to now).');

  parser.commands['list']!
    ..addOption('limit', abbr: 'l', defaultsTo: '20', help: 'Max rows.')
    ..addOption('status', help: 'Filter by status.')
    ..addOption('type', help: 'Filter by check type.')
    ..addOption('scholar-id', help: 'Filter by scholar ID.')
    ..addOption('scholar', help: 'Filter by scholar name.')
    ..addOption('since', help: 'Filter after ISO timestamp/date.')
    ..addOption('until', help: 'Filter before ISO timestamp/date.');

  parser.commands['summary']!
    ..addOption('window', defaultsTo: '30', help: 'Window in days.')
    ..addOption('since', help: 'Start ISO timestamp/date.')
    ..addOption('until', help: 'End ISO timestamp/date.')
    ..addOption('status', help: 'Filter by status.')
    ..addOption('type', help: 'Filter by check type.');

  return parser;
}

Future<int> handleCommand(List<String> arguments) async {
  final parser = buildParser();
  final result = parser.parse(arguments);

  if (result['help'] == true || result.command == null) {
    _printUsage(parser);
    return 0;
  }

  final config = DatabaseConfig.fromEnv(Platform.environment);
  final conn = await Connection.open(
    config.toEndpoint(),
    settings: config.toSettings(),
  );

  try {
    switch (result.command!.name) {
      case 'add':
        await _handleAdd(conn, result.command!);
        break;
      case 'list':
        await _handleList(conn, result.command!);
        break;
      case 'summary':
        await _handleSummary(conn, result.command!);
        break;
      default:
        _printUsage(parser);
        return 1;
    }
  } finally {
    await conn.close();
  }

  return 0;
}

void _printUsage(ArgParser parser) {
  stdout.writeln('Groupscholar Verification Logbook');
  stdout.writeln('');
  stdout.writeln('Usage:');
  stdout.writeln('  dart run bin/groupscholar_verification_logbook.dart <command> [options]');
  stdout.writeln('');
  stdout.writeln('Commands:');
  stdout.writeln('  add       Add a verification check record');
  stdout.writeln('  list      List verification checks');
  stdout.writeln('  summary   Summarize verification activity');
  stdout.writeln('');
  stdout.writeln(parser.usage);
}

Future<void> _handleAdd(Connection conn, ArgResults cmd) async {
  final scholar = cmd['scholar'] as String?;
  final type = cmd['type'] as String?;
  final status = cmd['status'] as String?;

  if (scholar == null || type == null || status == null) {
    stderr.writeln('Missing required fields. Provide --scholar, --type, --status.');
    exit(2);
  }

  final performedAt = _parseDate(cmd['performed-at'] as String?) ?? DateTime.now().toUtc();
  final recordId = const Uuid().v4();

  await conn.execute(
    Sql.named('''
      INSERT INTO $_schema.$_table
        (id, scholar_name, scholar_id, check_type, status, notes, performed_by, performed_at)
      VALUES
        (@id, @scholar, @scholarId, @type, @status, @notes, @by, @performedAt)
    '''),
    parameters: {
      'id': recordId,
      'scholar': scholar,
      'scholarId': cmd['scholar-id'] as String?,
      'type': type,
      'status': status,
      'notes': cmd['notes'] as String?,
      'by': cmd['by'] as String? ?? 'Unknown',
      'performedAt': performedAt,
    },
  );

  stdout.writeln('Saved verification check $recordId for $scholar.');
}

Future<void> _handleList(Connection conn, ArgResults cmd) async {
  final limit = int.tryParse(cmd['limit'] as String? ?? '20') ?? 20;
  final conditions = <String>[];
  final params = <String, dynamic>{
    'limit': limit,
  };

  void addFilter(String column, String? value, String param) {
    if (value == null || value.isEmpty) return;
    conditions.add('$column = @$param');
    params[param] = value;
  }

  addFilter('status', cmd['status'] as String?, 'status');
  addFilter('check_type', cmd['type'] as String?, 'type');
  addFilter('scholar_id', cmd['scholar-id'] as String?, 'scholarId');
  addFilter('scholar_name', cmd['scholar'] as String?, 'scholar');

  final since = _parseDate(cmd['since'] as String?);
  if (since != null) {
    conditions.add('performed_at >= @since');
    params['since'] = since;
  }

  final until = _parseDate(cmd['until'] as String?);
  if (until != null) {
    conditions.add('performed_at <= @until');
    params['until'] = until;
  }

  final whereClause = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
  final result = await conn.execute(
    Sql.named('''
      SELECT
        to_char(performed_at AT TIME ZONE 'UTC', 'YYYY-MM-DD HH24:MI') AS performed_at,
        scholar_name,
        scholar_id,
        check_type,
        status,
        performed_by
      FROM $_schema.$_table
      $whereClause
      ORDER BY performed_at DESC
      LIMIT @limit
    '''),
    parameters: params,
  );

  final rows = result.map((row) => row.toColumnMap()).toList();
  stdout.writeln(formatListRows(rows));
}

Future<void> _handleSummary(Connection conn, ArgResults cmd) async {
  final conditions = <String>[];
  final params = <String, dynamic>{};

  final status = cmd['status'] as String?;
  if (status != null && status.isNotEmpty) {
    conditions.add('status = @status');
    params['status'] = status;
  }

  final type = cmd['type'] as String?;
  if (type != null && type.isNotEmpty) {
    conditions.add('check_type = @type');
    params['type'] = type;
  }

  final since = _parseDate(cmd['since'] as String?) ??
      DateTime.now().toUtc().subtract(Duration(days: int.tryParse(cmd['window'] as String? ?? '30') ?? 30));
  final until = _parseDate(cmd['until'] as String?);

  if (since != null) {
    conditions.add('performed_at >= @since');
    params['since'] = since;
  }
  if (until != null) {
    conditions.add('performed_at <= @until');
    params['until'] = until;
  }

  final whereClause = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

  final statusRows = await conn.execute(
    Sql.named('''
      SELECT status, COUNT(*) AS total
      FROM $_schema.$_table
      $whereClause
      GROUP BY status
      ORDER BY total DESC
    '''),
    parameters: params,
  );

  final typeRows = await conn.execute(
    Sql.named('''
      SELECT check_type, COUNT(*) AS total
      FROM $_schema.$_table
      $whereClause
      GROUP BY check_type
      ORDER BY total DESC
    '''),
    parameters: params,
  );

  final statusCounts = {
    for (final row in statusRows) row[0] as String: row[1] as int,
  };
  final typeCounts = {
    for (final row in typeRows) row[0] as String: row[1] as int,
  };

  stdout.writeln(formatSummaryTable('Status Totals', statusCounts));
  stdout.writeln('');
  stdout.writeln(formatSummaryTable('Type Totals', typeCounts));
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  try {
    return DateTime.parse(value).toUtc();
  } catch (_) {
    stderr.writeln('Invalid date: $value (use ISO format YYYY-MM-DD or YYYY-MM-DDTHH:MM:SSZ)');
    exit(2);
  }
}
