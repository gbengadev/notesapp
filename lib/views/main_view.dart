import 'package:flutter/material.dart';
import 'package:flutterdemoapp/constants/routes.dart';
import 'package:flutterdemoapp/services/auth/auth_service.dart';
import 'package:flutterdemoapp/services/cloud/cloud_note.dart';
import 'package:flutterdemoapp/services/cloud/firebase_cloud_service.dart';
import 'package:flutterdemoapp/utility-methods/dialogs.dart';

enum MenuAction { logout }

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
    //  _notesService.open();
    super.initState();
  }

  //  @override
  // void dispose() {
  //   _notesService.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Main'),
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
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        loginPageRoute, (route) => false);
                    break;
                  default:
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text('Log Out'),
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
        ));
  }
}

//A call back function that can be used to call functions
// from the note service if a section of a view returns another
//view
typedef DeleteNoteCallBack = void Function(CloudNote note);

// Future<void> _showMyDialog(BuildContext context) async {
//   return showDialog<void>(
//     context: context,
//     barrierDismissible: false, // user must tap button!
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('AlertDialog Title'),
//         content: const SingleChildScrollView(
//           child: ListBody(
//             children: <Widget>[
//               Text('This is a demo alert dialog.'),
//               Text('Would you like to approve of this message?'),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Approve'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }