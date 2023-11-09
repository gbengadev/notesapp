import 'package:flutter/material.dart';
import 'package:flutterdemoapp/services/auth/auth_service.dart';
import 'package:flutterdemoapp/services/crud/notes_service.dart';
import 'package:flutterdemoapp/utility-methods/util.dart';

class CreateUpdateNotePage extends StatefulWidget {
  const CreateUpdateNotePage({super.key});

  @override
  State<CreateUpdateNotePage> createState() => _CreateUpdateNotePageState();
}

class _CreateUpdateNotePageState extends State<CreateUpdateNotePage> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;

  Future<DatabaseNotes> createGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNotes>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textEditingController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    const text = '';
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    print("Email: $email");
    final databaseUser = await _notesService.getUser(email: email);
    print("Dbuser is: $databaseUser");
    final newNote =
        await _notesService.createNote(user: databaseUser, text: text);
    _note = newNote;
    print('create note is $_note');
    return newNote;
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_textEditingController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    print('Note in save if $_note');
    if (_textEditingController.text.isNotEmpty && note != null) {
      final currentUser = AuthService.firebase().currentUser!;
      final email = currentUser.email!;
      await _notesService.getUser(email: email);
      _notesService.updateNote(note: note, text: _textEditingController.text);
    }
  }

//Gets text and updates database note
  void _textControllerListner() async {
    final note = _note;
    final text = _textEditingController.text;
    if (note == null) {
      return;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    await _notesService.getUser(email: email);
    _notesService.updateNote(note: note, text: text);
  }

//Removes listner from text editing controller(if it exists)
//and adds it again
  void _setupTextControllerListner() {
    _textEditingController.removeListener(_textControllerListner);
    _textEditingController.addListener(_textControllerListner);
  }

  @override
  void initState() {
    _notesService = NotesService();
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();

    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create Note'),
      ),
      body: FutureBuilder(
        future: createGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              print("Snap shot is $_note");
              _setupTextControllerListner();
              //Create a multiline textfield that expands with user input
              return TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(hintText: 'Type here'),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}