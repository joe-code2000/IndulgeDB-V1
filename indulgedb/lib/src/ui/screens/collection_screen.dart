import 'package:flutter/material.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/core/components/sub_components/collection.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/core/components/sub_components/database.dart';
import 'package:indulgedb/plugins/indulgedb-v1.0.0/indulgedb.dart';
import 'package:indulgedb/src/ui/utilities/utilities.dart';

class CollectionScreen extends StatefulWidget {
  final Database database;
  final Collection collection;

  const CollectionScreen({
    super.key,
    required this.database,
    required this.collection,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final IndulgeDB db = IndulgeDB();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var ref = "${widget.database.name}.${widget.collection.name}";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.collection.name} Colection",
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: db.documents.getDocuments(
                  reference: ref,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return StreamBuilder(
                    stream: db.documents.getDocumentStream(
                      reference: ref,
                    ),
                    initialData: snapshot.data,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text(
                            "No Document found",
                          ),
                        );
                      }
                      var data = snapshot.data;

                      if (data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "Empty. Please create a Document",
                          ),
                        );
                      }
                      return Column(
                        children: [
                          Text("Documents (${data.length})"),
                          Expanded(
                            child: ListView.separated(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                var document = data[index];
                                return Dismissible(
                                  key: Key(document.objectId),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    bool results = false;

                                    await showShouldAlertDialog(
                                      context: context,
                                      title: const Text(
                                        "Delete Document",
                                      ),
                                      content: Text(
                                        'Are you sure you want to delete ( ${document.objectId} ) Document. This action can not be undone',
                                      ),
                                      setResults: (res) {
                                        results = res;
                                      },
                                    );

                                    return results;
                                  },
                                  onDismissed: (direction) {
                                    db.documents.removeDocuments(
                                      reference: ref,
                                      query: (doc) {
                                        return doc.objectId ==
                                            document.objectId;
                                      },
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
                                    onTap: () {},
                                    child: Container(
                                      padding: const EdgeInsets.all(24.0),
                                      decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: Text(
                                        "${document.toJson(serialize: true)}",
                                      ),
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
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddDocumentModal();
        },
        child: const Icon(
          Icons.add,
          size: 36,
        ),
      ),
    );
  }

  void showAddDocumentModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Form(
          key: formKey,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.525,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return "Name is required";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          hintText: "Name",
                        ),
                      ),
                      TextFormField(
                        controller: ageController,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return "Age is required";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          hintText: "Age",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          hintText: "Description",
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () async {
                        nameController.text = "";
                        ageController.text = "";
                        descriptionController.text = "";
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 36.0,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        bool res = await db.documents.insertDocuments(
                          reference:
                              "${widget.database.name}.${widget.collection.name}",
                          data: [
                            {
                              "name": nameController.text,
                              "age": ageController.text,
                              "description": descriptionController.text,
                            }
                          ],
                        );

                        if (res) {
                          nameController.text = "";
                          ageController.text = "";
                          descriptionController.text = "";
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(
                        Icons.check,
                        size: 36.0,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
