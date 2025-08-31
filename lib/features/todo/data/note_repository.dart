import 'package:cloud_firestore/cloud_firestore.dart';
import 'note_model.dart';

class NoteRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('notes');

  Stream<List<Note>> watchHome(String uid) => _col
      .where('participants', arrayContains: uid)
      .where('archived', isEqualTo: false)
      .where('deletedAt', isNull: true)
      .orderBy('pinned', descending: true)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Note.fromMap(d.id, d.data())).toList());

  Stream<List<Note>> watchArchive(String uid) => _col
      .where('participants', arrayContains: uid)
      .where('archived', isEqualTo: true)
      .where('deletedAt', isNull: true)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Note.fromMap(d.id, d.data())).toList());

  Stream<List<Note>> watchTrash(String uid) => _col
      .where('participants', arrayContains: uid)
      .where('deletedAt', isNull: false)
      .orderBy('deletedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Note.fromMap(d.id, d.data())).toList());

  Stream<List<Note>> watchByLabel(String uid, String label) => _col
      .where('participants', arrayContains: uid)
      .where('labels', arrayContains: label)
      .where('archived', isEqualTo: false)
      .where('deletedAt', isNull: true)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Note.fromMap(d.id, d.data())).toList());

  Future<String> create(Note note) async {
    final ref = await _col.add(note.toMap());
    await ref.update({'id': ref.id});
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> data) =>
      _col.doc(id).update(data);

  Future<void> archive(String id, bool v) => update(id, {
    'archived': v,
    'updatedAt': DateTime.now().toIso8601String(),
  });

  Future<void> pin(String id, bool v) =>
      update(id, {'pinned': v, 'updatedAt': DateTime.now().toIso8601String()});

  Future<void> trash(String id) =>
      update(id, {'deletedAt': DateTime.now().toIso8601String()});

  Future<void> restore(String id) => update(id, {'deletedAt': null});

  Future<void> deleteHard(String id) => _col.doc(id).delete();
}
