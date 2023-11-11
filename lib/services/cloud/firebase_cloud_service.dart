import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdemoapp/services/cloud/cloud_exceptions.dart';
import 'package:flutterdemoapp/services/cloud/cloud_note.dart';

class FirebaseCloudService {
  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<void> deleteNote({
    required String documentId,
  }) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<Iterable<CloudNote>> getNotes({
    required String ownerUserId,
  }) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then((value) => value.docs.map((doc) {
                return CloudNote(
                  documentId: doc.id,
                  ownerUserId: doc.data()[ownerUserIdFieldName] as String,
                  text: doc.data()[textFieldName] as String,
                );
              }));
    } catch (e) {
      throw CouldNotGetNoteException();
    }
  }

  void createNewNote({
    required String ownerUserId,
  }) async {
    notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

//Create singleton
  static final FirebaseCloudService _shared =
      FirebaseCloudService._sharedInstance();
  FirebaseCloudService._sharedInstance();
  factory FirebaseCloudService() => _shared;
}
