import "package:flutter/material.dart";
import "package:notepad/models/note.dart";
import "package:notepad/pages/note_page.dart";
import "package:intl/intl.dart";
import "package:notepad/utils/util.dart";

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Note>> _notes;
  List<Note> notes = [];
  List<int> selected = [];
  String ascending = "ascending";
  String sortBy = "title";
  Map<String, String> sortFields = {
    "Title": "title",
    "Created At": "createdAt",
    "Updated At": "updatedAt"
  };

  @override
  void initState() {
    super.initState();
    _notes = Note().select().toList();
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
        actions: selected.isNotEmpty
            ? [
                IconButton(
                  onPressed: () async {
                    notes = await _notes;
                    await Note().select().id.inValues(selected).delete();
                    notes.removeWhere((element) {
                      return selected.remove(element.id!);
                    });

                    setState(() {});
                  },
                  icon: const Icon(Icons.delete),
                ),
              ]
            : [
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                PopupMenuButton<String>(
                  tooltip: "Sort",
                  icon: const Icon(Icons.sort),
                  onSelected: (item) {},
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
                                setState(() {
                                  ascending = "ascending";
                                  notes = sortNotes(
                                    notes,
                                    ascending: ascending == "ascending",
                                    by: sortBy,
                                  );
                                });
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
                                setState(() {
                                  ascending = "descending";
                                  notes = sortNotes(
                                    notes,
                                    ascending: ascending == "ascending",
                                    by: sortBy,
                                  );
                                });
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
      ),
      drawer: const Drawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          notes = await _notes;
          setState(() {});
        },
        child: FutureBuilder<List<Note>>(
          future: _notes,
          builder: (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
            if (snapshot.hasData) {
              notes = snapshot.data!;

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
                  bool isSelected = selected.contains(note.id!);
                  return Column(
                    children: [
                      ListTile(
                        onLongPress: () {
                          setState(() {
                            if (isSelected) {
                              selected.remove(note.id);
                            } else {
                              selected.add(note.id!);
                            }
                            print(selected);
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
                                      .format(DateTime.now()),
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
                  updatedAt: DateTime.now(),
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
