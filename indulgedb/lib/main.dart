import 'package:flutter/material.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/indulgedb.dart';

void initializeDB() {
  IndulgeDB db = IndulgeDB();

  db.database;
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
