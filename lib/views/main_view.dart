import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterdemoapp/constants/routes.dart';
import 'package:flutterdemoapp/extensions/buildcontext/loc.dart';
import 'package:flutterdemoapp/services/auth/auth_service.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_bloc.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_event.dart';
import 'package:flutterdemoapp/services/cloud/cloud_note.dart';
import 'package:flutterdemoapp/services/cloud/firebase_cloud_service.dart';
import 'package:flutterdemoapp/utility-methods/dialogs.dart';

enum MenuAction { logout }

//Extend any stream that returns an iterable then return
//length property
extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final FirebaseCloudService _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: StreamBuilder(
            stream: _notesService.allNotes(ownerUserId: userId).getLength,
            builder: (context, AsyncSnapshot<int> snapshot) {
              if (snapshot.hasData) {
                final noteCount = snapshot.data ?? 0;
                final text = context.loc.notes_title(noteCount);
                return Text(text);
              } else {
                return const Text('');
              }
            }),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createViewNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  context.read<AuthBloc>().add(
                        const AuthEventLogout(),
                      );
                  break;
                default:
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(context.loc.logout_button),
                ),
              ];
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: allNotes.length,
                    itemBuilder: (context, index) {
                      final note = allNotes.elementAt(index);
                      return ListTile(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            createViewNoteRoute,
                            arguments: note,
                          );
                        },
                        title: Text(
                          note.text,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            final shouldDelete =
                                await showDeleteDialog(context);
                            if (shouldDelete) {
                              await _notesService.deleteNote(
                                  documentId: note.documentId);
                            }
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      );
                    });
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

//A call back function that can be used to call functions
// from the note service if a section of a view returns another
//view
typedef DeleteNoteCallBack = void Function(CloudNote note);
