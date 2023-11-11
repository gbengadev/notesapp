//Constants
const ownerUserIdFieldName = 'user_id';
const textFieldName = 'text';

class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotGetNoteException extends CloudStorageException {}

class CouldNotUpdateNoteException extends CloudStorageException {}

class CouldNotDeleteNoteException extends CloudStorageException {}
