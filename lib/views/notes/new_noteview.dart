import 'package:flutter/material.dart';
import 'package:flutterdemoapp/services/auth/auth_service.dart';
import 'package:flutterdemoapp/services/cloud/cloud_note.dart';
import 'package:flutterdemoapp/services/cloud/firebase_cloud_service.dart';
import 'package:flutterdemoapp/services/crud/notes_service.dart';
import 'package:flutterdemoapp/utility-methods/dialogs.dart';
import 'package:flutterdemoapp/utility-methods/util.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNotePage extends StatefulWidget {
  const CreateUpdateNotePage({super.key});

  @override
  State<CreateUpdateNotePage> createState() => _CreateUpdateNotePageState();
}

class _CreateUpdateNotePageState extends State<CreateUpdateNotePage> {
  CloudNote? _note;
  late final FirebaseCloudService _notesService;
  late final TextEditingController _textEditingController;

  Future<CloudNote> createGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textEditingController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final newNote =
        await _notesService.createNewNote(ownerUserId: currentUser.id);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_textEditingController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    logger.d('Note in save if $_note');
    if (_textEditingController.text.isNotEmpty && note != null) {
      await _notesService.updateNote(
          documentId: note.documentId, text: _textEditingController.text);
    }
  }

//Gets text and updates database note
  void _textControllerListner() async {
    final note = _note;
    final text = _textEditingController.text;
    if (note == null) {
      return;
    }
    await _notesService.updateNote(documentId: note.documentId, text: text);
  }

//Removes listner from text editing controller(if it exists)
//and adds it again
  void _setupTextControllerListner() {
    _textEditingController.removeListener(_textControllerListner);
    _textEditingController.addListener(_textControllerListner);
  }

  @override
  void initState() {
    _notesService = FirebaseCloudService();
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
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textEditingController.text;
              if (text.isEmpty || _note == null) {
                await showCannotShareEmptyNoteDialog(context);
              }
              Share.share(text);
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: FutureBuilder(
        future: createGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              logger.d("Snapshot note is $_note");
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
