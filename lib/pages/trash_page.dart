import "package:flutter/material.dart";
import "package:notepad/models/note.dart";
import "package:notepad/pages/note_page.dart";
import "package:intl/intl.dart";

class TrashPage extends StatefulWidget {
  const TrashPage({Key? key}) : super(key: key);

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  late Future<List<Note>> _notes;
  List<Note> notes = [];
  List<int> selected = [];

  @override
  void initState() {
    super.initState();
    _notes = Note().select(getIsDeleted: true).isDeleted.equals(true).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Note()
        .select(getIsDeleted: true)
        .isDeleted
        .equals(true)
        .toList()
        .then((value) => {
              setState(() {
                notes = value;
              })
            },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trash"),
        centerTitle: true,
        actions: selected.isNotEmpty
            ? [
                IconButton(
                  onPressed: () async {
                    notes = await _notes;
                    await Note()
                        .select(getIsDeleted: true)
                        .id
                        .inValues(selected)
                        .delete(true);
                    notes.removeWhere((element) {
                      return selected.remove(element.id!);
                    });

                    setState(() {});
                  },
                  icon: const Icon(Icons.delete_forever),
                ),
              ]
            : [],
      ),
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
    );
  }
}
