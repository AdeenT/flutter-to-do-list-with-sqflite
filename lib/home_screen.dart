// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:todo_app_sql/sql_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> journals = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = true;

  void refreshJournal() async {
    final data = await SQLHelper.getItems();
    setState(() {
      journals = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshJournal();
    debugPrint("...number of items: ${journals.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Todo List",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showForm(null),
      ),
      body: ListView.builder(
        itemCount: journals.length,
        itemBuilder: (context, index) => Card(
          color: Colors.amber.shade100,
          margin: const EdgeInsets.all(15),
          child: ListTile(
            title: Text(journals[index]['title']),
            subtitle: Text(journals[index]['description']),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      showForm(journals[index]['id']);
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      deleteItem(journals[index]['id']);
                    },
                    icon: const Icon(Icons.delete),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          journals.firstWhere((element) => element['id'] == id);
      titleController.text = existingJournal['title'];
      descriptionController.text = existingJournal['description'];
    }
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (context) => Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await addItem();
                    Navigator.of(context).pop();
                  }
                  if (id != null) {
                    await updateItem(id);

                    titleController.text = "";
                    descriptionController.text = "";
                    Navigator.of(context).pop();
                  }
                },
                child: Text(id == null ? "Create New" : "Update"),
              ),
            ],
          )),
    );
  }

  Future<void> addItem() async {
    await SQLHelper.createItems(
      titleController.text,
      descriptionController.text,
    );
    refreshJournal();
  }

  Future<void> updateItem(int id) async {
    await SQLHelper.updateItem(
        id, titleController.text, descriptionController.text);
    refreshJournal();
  }

  void deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Successfully deleted a journal"),
      ),
    );
  }
}
