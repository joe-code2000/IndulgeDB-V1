import 'package:flutter/material.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/indulgedb.dart';
import 'package:indulgedb/src/ui/screens/database_screen.dart';
import 'package:indulgedb/src/ui/utilities/utilities.dart';

class NoSQLDatabaseScreen extends StatefulWidget {
  const NoSQLDatabaseScreen({
    super.key,
  });

  @override
  State<NoSQLDatabaseScreen> createState() => _DatabasesScreenState();
}

class _DatabasesScreenState extends State<NoSQLDatabaseScreen> {
  final IndulgeDB indulgeDB = IndulgeDB();

  final TextEditingController nameController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Flutter NoSql"),
      ),
      body: Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder(
                  future: indulgeDB.databases.getDatabases(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return StreamBuilder(
                      stream: indulgeDB.databases.getDatabaseStream(),
                      initialData: snapshot.data,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text(
                              "No Database found",
                            ),
                          );
                        }
                        var data = snapshot.data;

                        if (data!.isEmpty) {
                          return const Center(
                            child: Text(
                              "Empty. Please create a database",
                            ),
                          );
                        }

                        return Column(
                          children: [
                            Text("Databases (${data.length})"),
                            Expanded(
                              child: ListView.separated(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  var db = data[index];
                                  return Dismissible(
                                    key: Key(db.objectId),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (direction) async {
                                      bool results = false;

                                      await showShouldAlertDialog(
                                        context: context,
                                        setResults: (res) {
                                          results = res;
                                        },
                                        title: const Text(
                                          "Delete Database",
                                        ),
                                        content: Text(
                                          'Are you sure you want to delete ( ${db.name} ) database. This action can not be undone',
                                        ),
                                      );

                                      return results;
                                    },
                                    onDismissed: (direction) {
                                      indulgeDB.databases.removeDatabase(
                                        name: db.name,
                                      );
                                    },
                                    background: Container(
                                      color: Colors.redAccent,
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        goToPage(
                                          context: context,
                                          page: DatabaseScreen(
                                            database: db,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: double.maxFinite,
                                        padding: const EdgeInsets.all(24.0),
                                        decoration: BoxDecoration(
                                          color: Colors.black12,
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        child: Text(db.name),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(
                                    height: 16.0,
                                  );
                                },
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return "Database name is required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Database name",
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!formKey.currentState!.validate()) {
            return;
          }

          bool res = await indulgeDB.databases.createDatabase(
            name: nameController.text,
          );

          if (res) {
            nameController.text = "";
            if (context.mounted) FocusScope.of(context).unfocus();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
