import 'package:indulgedb/plugins/indulgedb-v1.0.0/addons/nosql_transactional/nosql_transactional.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/core/utilities/fileoperations.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/helpers/collection_helper.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/helpers/database_helper.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/helpers/document_helper.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/nosql_manager.dart';

class IndulgeDB {
  final DatabaseHelper database = DatabaseHelper();
  final CollectionHelper collection = CollectionHelper();
  final DocumentHelper document = DocumentHelper();

  final NoSQLManager _noSQLManager = NoSQLManager();

  Future<bool> clean({
    required String databasePath,
    required bool delete,
  }) async {
    bool results = true;

    if (delete) {
      return results;
    }

    results = await cleanFile(
      databasePath,
    );

    return results;
  }

  Future<bool> initialize({
    required String databasePath,
  }) async {
    bool results = true;

    Map<String, dynamic>? databaseData = await readFile(databasePath);
    if (databaseData != null) {
      _noSQLManager.initialize(data: databaseData);
    }
    return results;
  }

  Future<bool> commitToDisk({
    required String databasePath,
  }) async {
    bool results = true;

    results = await writeFile(
      databasePath,
      _noSQLManager.toJson(
        serialize: true,
      ),
    );
    return results;
  }

  Future<Map<String, dynamic>> noSQLDatabaseToJson({
    required bool serialize,
  }) async {
    return _noSQLManager.toJson(serialize: serialize);
  }

  NoSQLTransactional transactional(Future<void> Function() executeFunction) {
    NoSQLTransactional sqlTransactional = NoSQLTransactional(
      executeFunction: executeFunction,
    );

    return sqlTransactional;
  }
}
