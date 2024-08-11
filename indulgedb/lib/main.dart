import 'package:flutter/material.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/indulgedb.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/wrapper/nosql_stateful_wrapper.dart';
import 'package:indulgedb/src/ui/screens/nosql_database_screen.dart';

Future<void> initDB({
  required bool initializeFromDisk,
  required String databasePath,
}) async {
  IndulgeDB db = IndulgeDB();

  try {
    if (initializeFromDisk) {
      await db.initialize(
        databasePath: databasePath,
      );
    }
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDB(
    initializeFromDisk: true,
    databasePath: "database.json",
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: NoSQLStatefulWrapper(
          initializeFromDisk: true,
          checkPermissions: true,
          databasePath: "database.json",
          body: NoSQLDatabaseScreen(),
          commitStates: [
            AppLifecycleState.inactive,
          ],
        ),
      ),
    );
  }
}
