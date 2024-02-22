import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';

class DatabaseHelper {
  Future<Connection> connectToDatabase() async {
    final conn = await Connection.open(
      Endpoint(
        host: kIsWeb ||
                Platform.isWindows ||
                Platform.isLinux ||
                Platform.isMacOS ||
                Platform.isFuchsia
            ? 'localhost'
            : '10.0.2.2', // Android localhost
        database: 'postgres',
        port: 5432,
        username: 'postgres',
        password: getPassword(), // Insert password here
      ),
      // The postgres server hosted locally doesn't have SSL by default. If you're
      // accessing a postgres server over the Internet, the server should support
      // SSL and you should swap out the mode with `SslMode.verifyFull`.
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    return conn;
  }

  String getPassword() {
    File file = File('${Directory.current.path}\\lib\\password.txt');
    if (file.existsSync()) {
      return file.readAsStringSync();
    } else {
      return 'Password not found';
    }
  }

  void sampleDatabase() async {
    Connection conn = await connectToDatabase();

    // Simple query without results
    await conn.execute('CREATE TABLE IF NOT EXISTS a_table ('
        '  id TEXT NOT NULL, '
        '  totals INTEGER NOT NULL DEFAULT 0'
        ')');

    // simple query
    final result0 = await conn.execute("SELECT 'foo'");
    print(result0[0][0]); // first row, first column

    // Using prepared statements to supply values
    final result1 = await conn.execute(
      r'INSERT INTO a_table (id) VALUES ($1)',
      parameters: ['example row'],
    );
    print('Inserted ${result1.affectedRows} rows');

    // name parameter query
    final result2 = await conn.execute(
      Sql.named('SELECT * FROM a_table WHERE id=@id'),
      parameters: {'id': 'example row'},
    );
    print(result2.first.toColumnMap());

    // transaction
    await conn.runTx((s) async {
      final rs = await s.execute('SELECT count(*) FROM a_table');
      await s.execute(
        r'UPDATE a_table SET totals=$1 WHERE id=$2',
        parameters: [rs[0][0], 'xyz'],
      );
    });

    // prepared statement
    final statement = await conn.prepare(Sql("SELECT 'foo';"));
    final result3 = await statement.run([]);
    print(result3);
    await statement.dispose();

    // preared statement with types
    final anotherStatement =
        await conn.prepare(Sql(r'SELECT $1;', types: [Type.bigInteger]));
    final bound = anotherStatement.bind([1]);
    final subscription = bound.listen((row) {
      print('row: $row');
    });
    await subscription.asFuture();
    await subscription.cancel();
    print(await subscription.affectedRows);
    print(await subscription.schema);

    await conn.close();
  }
}
