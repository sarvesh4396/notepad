import "package:flutter/material.dart";
import "package:notepad/models/note.dart";

class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  late Future<List<Tag>> _tags;
  List<Tag> tags = [];
  List<int> selectedTags = [];
  TextEditingController tagController = TextEditingController();

  int selected = -1;

  void changeSelected(int index) {
    setState(
      () {
        selected = index;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tags = Tag().select().toList();
  }

  @override
  void dispose() {
    tagController.dispose();
    super.dispose();
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
          tags = await _tags;
          setState(() {});
        },
        child: FutureBuilder<List<Tag>>(
          future: _tags,
          builder: (BuildContext context, AsyncSnapshot<List<Tag>> snapshot) {
            if (snapshot.hasData) {
              tags = snapshot.data!;

              return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    thickness: 1,
                  );
                },
                shrinkWrap: true,
                itemCount: tags.length,
                itemBuilder: (BuildContext context, int index) {
                  Tag tag = tags[index];
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
                        onTap: () async {
                          tags = await _tags;
                          setState(() {});
                        },
                        title: Text(
                          tag.tag!,
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check,
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await addTag(context, tag, edit: true);
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      selectedTags.add(tag.id!);
                                      await deleteTags();
                                    },
                                    icon: const Icon(Icons.delete_forever),
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

          tags = await _tags;
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> deleteTags() async {
    tags = await _tags;
    await Tag().select().id.inValues(selectedTags).delete(true);
    tags.removeWhere((element) {
      return selectedTags.remove(element.id!);
    });

    setState(() {});
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
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            ElevatedButton(
              onPressed: () async {
                tag.tag = tagController.text;
                await tag.save();
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
