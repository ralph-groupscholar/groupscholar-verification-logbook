import 'dart:io';

import 'package:postgres/postgres.dart';

class DatabaseConfig {
  final String host;
  final int port;
  final String database;
  final String username;
  final String password;
  final SslMode sslMode;

  const DatabaseConfig({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
    required this.sslMode,
  });

  factory DatabaseConfig.fromEnv(Map<String, String> env) {
    final host = env['PGHOST'] ?? 'db-acupinir.groupscholar.com';
    final port = int.tryParse(env['PGPORT'] ?? '') ?? 23947;
    final database = env['PGDATABASE'] ?? 'postgres';
    final username = env['PGUSER'] ?? 'ralph';
    final password = env['PGPASSWORD'] ?? '';
    final sslMode = _parseSslMode(env['PGSSLMODE'] ?? 'disable');

    if (password.isEmpty) {
      stderr.writeln('Missing PGPASSWORD in environment.');
      exit(2);
    }

    return DatabaseConfig(
      host: host,
      port: port,
      database: database,
      username: username,
      password: password,
      sslMode: sslMode,
    );
  }

  Endpoint toEndpoint() => Endpoint(
    host: host,
    port: port,
    database: database,
    username: username,
    password: password,
  );

  ConnectionSettings toSettings() => ConnectionSettings(sslMode: sslMode);

  static SslMode _parseSslMode(String value) {
    switch (value.toLowerCase()) {
      case 'disable':
        return SslMode.disable;
      case 'verify-full':
      case 'verifyfull':
      case 'verify':
        return SslMode.verifyFull;
      default:
        return SslMode.require;
    }
  }
}
