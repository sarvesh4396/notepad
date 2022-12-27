import "package:flutter/material.dart";
import 'package:notepad/constants/app_strings.dart';
import "package:notepad/models/note.dart";
import 'package:notepad/pages/drawer_page.dart';
import "package:notepad/pages/note_page.dart";
import "package:intl/intl.dart";
import 'package:notepad/pages/tag_page.dart';
import "package:notepad/pages/trash_page.dart";
import "package:notepad/utils/util.dart";
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Note>> _notes;
  List<Note> notes = [];
  late Future<List<Tag>> _tags;
  Tag? selectedTag;
  List<Tag> tags = [];
  List<int> selectedNotes = [];
  String ascending = "ascending";
  String sortBy = "updatedAt";
  Map<String, String> sortFields = {
    "Title": "title",
    "Created At": "createdAt",
    "Updated At": "updatedAt"
  };

  @override
  void initState() {
    super.initState();
    _notes = Note().select().toList();
    _tags = Tag().select().toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Note().select().toList().then((value) => {
          setState(() {
            notes = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        centerTitle: true,
        actions: selectedNotes.isNotEmpty
            ? [
                FutureBuilder<List<Tag>>(
                    future: _tags,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Tag>> snapshot) {
                      return PopupMenuButton<Tag>(
                        tooltip: "Apply tag",
                        icon: const Icon(Icons.tag),
                        onSelected: (tag) async {
                          await Note()
                              .select()
                              .id
                              .inValues(selectedNotes)
                              .update({"tag": tag.id});
                          selectedNotes = [];

                          notes = await _notes;

                          setState(() {});
                        },
                        itemBuilder: (BuildContext context) {
                          tags = snapshot.data ?? [];

                          return <PopupMenuEntry<Tag>>[
                            ...tags
                                .map(
                                  (tag) => PopupMenuItem<Tag>(
                                    value: tag,
                                    child: ListTile(
                                      title: Text(tag.tag!),
                                      selected: selectedTag?.id == tag.id,
                                    ),
                                  ),
                                )
                                .toList(),
                          ];
                        },
                      );
                    }),
                IconButton(
                  onPressed: () async {
                    await Note().select().id.inValues(selectedNotes).delete();
                    notes.removeWhere((element) {
                      return selectedNotes.remove(element.id!);
                    });

                    setState(() {});
                  },
                  icon: const Icon(Icons.delete),
                )
              ]
            : [
                // TODO:
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                PopupMenuButton<String>(
                  tooltip: "Sort",
                  icon: const Icon(Icons.sort),
                  onSelected: (item) {
                    print(item);
                    setState(() {});
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem(
                      child: Column(
                        children: [
                          ...sortFields.keys
                              .map(
                                (e) => RadioListTile<String>(
                                  title: Text(e),
                                  dense: true,
                                  value: e,
                                  selected: sortFields[e] == sortBy,
                                  groupValue: "by",
                                  onChanged: (String? key) async {
                                    if (key != null) {
                                      notes = await _notes;
                                      setState(() {
                                        sortBy = sortFields[key]!;
                                        notes = sortNotes(
                                          notes,
                                          ascending: ascending == "ascending",
                                          by: sortBy,
                                        );
                                      });
                                    }
                                  },
                                ),
                              )
                              .toList(),
                          const Divider(
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      child: Column(
                        children: [
                          RadioListTile(
                            title: const Text("Ascending"),
                            dense: true,
                            value: "ascending",
                            groupValue: "asc",
                            selected: ascending == "ascending",
                            onChanged: (value) async {
                              if (value != null) {
                                notes = await _notes;
                                ascending = "ascending";
                                notes = sortNotes(
                                  notes,
                                  ascending: ascending == "ascending",
                                  by: sortBy,
                                );
                                setState(() {});
                              }
                            },
                          ),
                          RadioListTile(
                            title: const Text("Descending"),
                            dense: true,
                            value: "descending",
                            groupValue: "asc",
                            selected: ascending != "ascending",
                            onChanged: (value) async {
                              if (value != null) {
                                notes = await _notes;
                                ascending = "descending";
                                notes = sortNotes(
                                  notes,
                                  ascending: ascending == "ascending",
                                  by: sortBy,
                                );
                                setState(() {});
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),

                FutureBuilder<List<Tag>>(
                    future: _tags,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Tag>> snapshot) {
                      return PopupMenuButton<Tag>(
                        tooltip: "See by tag",
                        icon: const Icon(Icons.tag),
                        onSelected: (tag) async {
                          if (tag.id == null) {
                            selectedTag = null;
                          } else {
                            selectedTag = tag;
                          }
                          setState(() {});
                        },
                        itemBuilder: (BuildContext context) {
                          tags = snapshot.data ?? [];

                          return <PopupMenuEntry<Tag>>[
                            ...tags
                                .map(
                                  (tag) => PopupMenuItem<Tag>(
                                    value: tag,
                                    child: ListTile(
                                      title: Text(tag.tag!),
                                      selected: selectedTag?.id == tag.id,
                                    ),
                                  ),
                                )
                                .toList(),
                            PopupMenuItem<Tag>(
                              value: Tag(),
                              child: ListTile(
                                title: const Text("All Tags"),
                                selected: selectedTag?.id == null,
                              ),
                            )
                          ];
                        },
                      );
                    }),
              ],
      ),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          notes = await _notes;
          tags = await _tags;
          setState(() {});
        },
        child: FutureBuilder<List<Note>>(
          future: _notes,
          builder: (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
            if (snapshot.hasData) {
              notes = snapshot.data!;
              notes = sortNotes(
                notes,
                ascending: ascending == "ascending",
                by: sortBy,
              );

              if (selectedTag != null) {
                notes = notes
                    .where((element) => element.id == selectedTag?.id)
                    .toList();
              }

              return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    thickness: 1,
                  );
                },
                shrinkWrap: true,
                itemCount: notes.length,
                itemBuilder: (BuildContext context, int index) {
                  Note note = notes[index];
                  bool isSelected = selectedNotes.contains(note.id!);
                  return Column(
                    children: [
                      ListTile(
                        onLongPress: () {
                          setState(() {
                            if (isSelected) {
                              selectedNotes.remove(note.id);
                            } else {
                              selectedNotes.add(note.id!);
                            }
                          });
                        },
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotePage(note: note),
                            ),
                          );
                          notes = await _notes;
                          setState(() {});
                        },
                        title: Text(
                          note.title!,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.body!.substring(
                                0,
                                note.body!.length > 30 ? 30 : note.body!.length,
                              ),
                              maxLines: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (note.tag != null)
                                  Text("#${note.tag}")
                                else
                                  const Text(""),
                                Text(
                                  DateFormat("E, MMM d, HH:mm")
                                      .format(note.updatedAt!),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check,
                              )
                            : null,
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
        tooltip: "Add Note",
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotePage(
                note: Note(
                  body: "",
                  title: "",
                  createdAt: DateTime.now(),
                ),
              ),
            ),
          );
          notes = await _notes;
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
