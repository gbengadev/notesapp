import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdemoapp/services/cloud/cloud_exceptions.dart';
import 'package:flutterdemoapp/services/cloud/cloud_note.dart';
import 'package:logger/logger.dart';

class FirebaseCloudService {
  var logger = Logger();
  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allnotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    logger.d('Note is $notes');
    return allnotes;
  }

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

  // Future<Iterable<CloudNote>> getNotes({
  //   required String ownerUserId,
  // }) async {
  //   try {
  //     return await notes
  //         .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
  //         .get()
  //         .then(
  //             (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)));
  //   } catch (e) {
  //     throw CouldNotGetNoteException();
  //   }
  // }

  Future<CloudNote> createNewNote({
    required String ownerUserId,
  }) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    //Get snapshot from 'document'

    final fetchedNote = await document.get();
    logger.d('just added ${fetchedNote.id}');
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

//Create singleton
  static final FirebaseCloudService _shared =
      FirebaseCloudService._sharedInstance();
  FirebaseCloudService._sharedInstance();
  factory FirebaseCloudService() => _shared;
}
