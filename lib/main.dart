import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_toolkit/firebase_toolkit.dart';
import 'package:go_router/go_router.dart'; // For navigation
import 'features/todo/presentation/pages/archive_page.dart';
import 'features/todo/presentation/pages/note_editor_page.dart';
import 'features/todo/presentation/pages/notes_grid_page.dart';
import 'features/todo/presentation/pages/trash_page.dart';
import 'firebase_options.dart';
import 'app.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.init(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler for Firebase
  MessagingService.configureBackgroundHandler();

  final goRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => NotesGridPage()),
      GoRoute(
        path: '/note/:id',
        builder: (context, state) {
          final noteId = state.pathParameters['id'] ?? '';
          return NoteEditorPage(noteId: noteId);
        },
      ),
      GoRoute(
        path: '/note/new',
        builder: (context, state) => NoteEditorPage(noteId: ''),
      ),
      GoRoute(path: '/archive', builder: (context, state) => ArchivePage()),
      GoRoute(path: '/trash', builder: (context, state) => TrashPage()),
    ],
  );

  runApp(ProviderScope(child: App(goRouter: goRouter)));
}
