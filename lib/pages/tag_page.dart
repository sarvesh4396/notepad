import "package:flutter/material.dart";
import "package:notepad/models/note.dart";

class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  late Future<List<Tag>> tags;

  List<int> selectedTags = [];
  TextEditingController tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateView();
  }

  @override
  void dispose() {
    tagController.dispose();
    super.dispose();
  }

  updateView() async {
    tags = Tag().select().toList();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tags"),
        centerTitle: true,
        actions: selectedTags.isNotEmpty
            ? [
                IconButton(
                  onPressed: () async {
                    await deleteTags();
                  },
                  icon: const Icon(Icons.delete_forever),
                ),
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await updateView();
        },
        child: FutureBuilder<List<Tag>>(
          future: tags,
          builder: (BuildContext context, AsyncSnapshot<List<Tag>> snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data!;

              return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    thickness: 1,
                  );
                },
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  Tag tag = data[index];
                  bool isSelected = selectedTags.contains(tag.id!);
                  return Column(
                    children: [
                      ListTile(
                        onLongPress: () {
                          setState(() {
                            if (isSelected) {
                              selectedTags.remove(tag.id);
                            } else {
                              selectedTags.add(tag.id!);
                            }
                          });
                        },
                        onTap: () {},
                        title: Text(
                          tag.tag!,
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.blue)
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      tagController.text = tag.tag!;
                                      await addTag(context, tag, edit: true);
                                    },
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue,),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      selectedTags.add(tag.id!);
                                      await deleteTags();
                                    },
                                    icon: const Icon(Icons.delete_forever,
                                        color: Colors.blue,),
                                  )
                                ],
                              ),
                      )
                    ],
                  );
                },
              );
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Tag",
        onPressed: () async {
          await addTag(context, Tag(tag: tagController.text));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> deleteTags() async {
    await Tag().select().id.inValues(selectedTags).delete(true);

    selectedTags = [];

    await updateView();
  }

  addTag(BuildContext context, Tag tag, {bool edit = false}) async {
    var title = edit ? "Edit Tag" : "Add Tag";
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: Center(child: Text(title)),
          content: TextFormField(
            controller: tagController,
            validator: (value) {
              if (value!.isEmpty) {
                return "Tag can not be empty";
              }
              return null;
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            ElevatedButton(
              onPressed: () async {
                tag.tag = tagController.text;
                await tag.save();
                tagController.text = "";
                await updateView();
                Navigator.pop(context);
              },
              child: Text(edit ? "Update" : "Save"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      }),
    );
  }
}
