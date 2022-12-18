import "package:notepad/models/note.dart";

List<Note> sortNotes(List<Note> notes, {bool ascending = true, by = "title"}) {
  if (by == "title") {
    notes.sort((a, b) => (a.title!).compareTo(b.title!));
  } else if (by == "tag") {
    notes.sort((a, b) => (a.tag!).compareTo(b.tag!));
  } else if (by == "createdAt") {
    notes.sort((a, b) => (a.createdAt!).compareTo(b.createdAt!));
  } else if (by == "updatedAt") {
    notes.sort((a, b) => (a.updatedAt!).compareTo(b.updatedAt!));
  }

  if (ascending) {
    return notes;
  }
  return notes.reversed.toList();
}
