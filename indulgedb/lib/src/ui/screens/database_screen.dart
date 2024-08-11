import 'package:flutter/material.dart';

import 'package:indulgedb/plugins/indulgedb-v1.0.0/core/components/sub_components/database.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/indulgedb.dart';
import 'package:indulgedb/src/ui/screens/collection_screen.dart';
import 'package:indulgedb/src/ui/utilities/utilities.dart';

class DatabaseScreen extends StatefulWidget {
  final Database database;
  const DatabaseScreen({
    super.key,
    required this.database,
  });

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  final IndulgeDB db = IndulgeDB();

  final TextEditingController nameController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.database.name} Database"),
      ),
      body: Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder(
                  future: db.collections.getCollections(
                    databaseName: widget.database.name,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return StreamBuilder(
                      stream: db.collections.getCollectionStream(
                        databaseName: widget.database.name,
                      ),
                      initialData: snapshot.data,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text(
                              "No Collection found",
                            ),
                          );
                        }
                        var data = snapshot.data;

                        if (data!.isEmpty) {
                          return const Center(
                            child: Text(
                              "Empty. Please create a collection",
                            ),
                          );
                        }
                        return Column(
                          children: [
                            Text("Collections (${data.length})"),
                            Expanded(
                              child: ListView.separated(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  var collection = data[index];

                                  return Dismissible(
                                    key: Key(collection.objectId),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (direction) async {
                                      bool results = false;

                                      await showShouldAlertDialog(
                                        context: context,
                                        title: const Text(
                                          "Delete Collection",
                                        ),
                                        content: Text(
                                          'Are you sure you want to delete ( ${collection.name} ) collection. This action can not be undone',
                                        ),
                                        setResults: (res) {
                                          results = res;
                                        },
                                      );

                                      return results;
                                    },
                                    onDismissed: (direction) {
                                      db.collections.removeCollection(
                                        reference:
                                            "${widget.database.name}.${collection.name}",
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
                                          page: CollectionScreen(
                                            database: widget.database,
                                            collection: collection,
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
                                        child: Text(collection.name),
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
                    return "Collection name is required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Collection name",
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

          bool res = await db.collections.createCollection(
            reference: "${widget.database.name}.${nameController.text}",
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
