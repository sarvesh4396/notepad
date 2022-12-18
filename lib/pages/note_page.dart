import "package:flutter/material.dart";
import "package:notepad/models/note.dart";

class NotePage extends StatefulWidget {
  const NotePage({Key? key, required this.note}) : super(key: key);
  final Note note;

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  late String _title;
  late String _body;

  @override
  void initState() {
    super.initState();
    _title = widget.note.title!;
    _body = widget.note.body!;

    _titleController.text = _title;
    _bodyController.text = _body;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var formState = formKey.currentState!;
        formState.save();
        var note = widget.note;
        note.body = _bodyController.text;
        note.title = _titleController.text;
        note.updatedAt = DateTime.now();
        var i = await note.save();
        print("Saved $i");
        return i != null;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleController.text),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  width: 3.0,
                  color: Colors.indigo,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 6),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.always,
                  onChanged: () {
                    Form.of(primaryFocus!.context!)?.save();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: TextFormField(
                          initialValue: _title != "" ? _title : "Note Title...",
                          onChanged: (value) {
                            setState(
                              () {
                                _titleController.text = value;
                              },
                            );
                          },
                          decoration: const InputDecoration(
                            hintText: "My Note Title",
                            label: Text("Title"),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: TextFormField(
                          maxLines: 100,
                          initialValue:
                              _body != "" ? _body : "Write your note here...",
                          onChanged: (value) {
                            setState(
                              () {
                                _bodyController.text = value;
                              },
                            );
                          },
                          decoration: const InputDecoration(
                            hintText: "My Note",
                            label: Text("Note"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder textFieldBorder({
  bool focused = false,
  bool error = false,
}) {
  Color borderColor = const Color.fromRGBO(30, 69, 208, 1);
  if (error) {
    borderColor = Colors.red;
  }
  double width = 1.0;
  if (focused) {
    width = 2.0;
  }

  return OutlineInputBorder(
    borderSide: BorderSide(color: borderColor, width: width),
    borderRadius: BorderRadius.circular(15.0),
  );
}

InputDecoration inputDecoration({
  required String hintText,
  required String label,
}) {
  return InputDecoration(
    hintText: hintText,
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(15.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide:
          const BorderSide(color: Color.fromRGBO(30, 69, 208, 1), width: 2.0),
      borderRadius: BorderRadius.circular(15.0),
    ),
    label: Text(
      label,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    floatingLabelStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide:
          const BorderSide(color: Color.fromRGBO(30, 69, 208, 1), width: 2.0),
      borderRadius: BorderRadius.circular(15.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color.fromRGBO(30, 69, 208, 1)),
      borderRadius: BorderRadius.circular(15.0),
    ),
  );
}
