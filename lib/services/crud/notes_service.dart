import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

@immutable
class DatabaseUser {
  final int id;
  final String email;

  DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person,ID =$id,email=$email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const databaseName = 'Notes.db';
const noteTable = 'Note';
const userTable = 'User';

class DatabaseNotes {
  final int id;
  final int userId;
  final String text;

  DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String;

  //overwrie toString method
  //       @override
  // String toString() => 'Person,ID =$id,userId=$userId';
}

class DatabaseOpenException implements Exception {}

class UnableToGetDirectory implements Exception {}

class CouldNotDeleteUserExcpetion implements Exception {}

class CouldNotDeleteNoteExcpetion implements Exception {}

class UserAlreadyExistsException implements Exception {}

class UserDoesNotExistException implements Exception {}

class NoteNoteFoundException implements Exception {}

class CouldNotUpdateNoteException implements Exception {}

class NotesService {
  Database? _db;

  List<DatabaseNotes> _notes = [];
  final _notesStreamController =
      StreamController<List<DatabaseNotes>>.broadcast();

  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;
  //Make Note service a singleton class(Can be instantiated only once)
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  Future<void> _cacheNotes() async {
    final allNotes = await getUserNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNotes> updateNotes({
    required DatabaseNotes note,
    required String text,
  }) async {
    final db = getDatabase();
    //get note
    await getNote(id: note.id);

    final updateCount = await db.update(
      noteTable,
      {textColumn: text},
      where: 'id=?',
      whereArgs: [note.id],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNotes>> getUserNotes() async {
    final db = getDatabase();
    final notes = await db.query(
      noteTable,
    );
    return notes.map((e) => DatabaseNotes.fromRow(e));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    final db = getDatabase();
    final note = await db.query(
      noteTable,
      where: 'id=?',
      whereArgs: [id],
    );
    if (note.isEmpty) {
      throw NoteNoteFoundException();
    } else {
      final _note = DatabaseNotes.fromRow(note.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(_note);
      _notesStreamController.add(_notes);
      return _note;
    }
  }

  Future<DatabaseNotes> createNote({
    required DatabaseUser user,
    required String text,
  }) async {
    final db = getDatabase();
    final databaseUser = await getUser(email: user.email);
    if (databaseUser == user) {
      throw UserDoesNotExistException();
    }
    final noteId = await db.insert(
      noteTable,
      {userIdColumn: user.id, textColumn: text},
    );

    final note = DatabaseNotes(
      id: noteId,
      userId: user.id,
      text: text,
    );
    //Cache note
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = getDatabase();
    final result = await db.query(
      userTable,
      where: 'email=${email.toLowerCase()}',
    );
    if (result.isEmpty) {
      throw UserDoesNotExistException();
    }
    return DatabaseUser.fromRow(result.first);
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on UserDoesNotExistException {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (_) {
      rethrow;
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = getDatabase();
    final result = await db.query(
      userTable,
      where: 'email=${email.toLowerCase()}',
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final userId =
        await db.insert(userTable, {emailColumn: email.toLowerCase()});

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteNote({required int id}) async {
    final db = getDatabase();
    final deletedCount =
        await db.delete(noteTable, where: 'id=?', whereArgs: [id]);
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteExcpetion();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    final db = getDatabase();
    final deleteCount = db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return deleteCount;
  }

  Database getDatabase() {
    final db = _db;
    if (db == null) {
      throw DatabaseOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseOpenException();
    } else {
      await db.close();
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, databaseName);
      final db = await openDatabase(dbPath);
      _db = db;
      const createUserTable = '';
      await db.execute(createUserTable);

      const createNoteTable = '';
      await db.execute(createNoteTable);
      //Cache notes
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDirectory();
    }
  }
}
