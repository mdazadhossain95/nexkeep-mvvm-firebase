import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/note_repository.dart';
import '../data/note_model.dart';

final _repoProvider = Provider((_) => NoteRepository());
final currentUserProvider = StreamProvider<User?>(
  (_) => FirebaseAuth.instance.authStateChanges(),
);

final homeNotesProvider = StreamProvider.autoDispose<List<Note>>((ref) {
  final u = ref.watch(currentUserProvider).value;
  if (u == null) return const Stream.empty();
  return ref.watch(_repoProvider).watchHome(u.uid);
});

final archiveNotesProvider = StreamProvider.autoDispose<List<Note>>((ref) {
  final u = ref.watch(currentUserProvider).value;
  if (u == null) return const Stream.empty();
  return ref.watch(_repoProvider).watchArchive(u.uid);
});

final trashNotesProvider = StreamProvider.autoDispose<List<Note>>((ref) {
  final u = ref.watch(currentUserProvider).value;
  if (u == null) return const Stream.empty();
  return ref.watch(_repoProvider).watchTrash(u.uid);
});

final labelNotesProvider = StreamProvider.autoDispose
    .family<List<Note>, String>((ref, label) {
      final u = ref.watch(currentUserProvider).value;
      if (u == null) return const Stream.empty();
      return ref.watch(_repoProvider).watchByLabel(u.uid, label);
    });
