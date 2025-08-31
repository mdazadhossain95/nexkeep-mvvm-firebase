import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _fa = FirebaseAuth.instance;

  Stream<User?> authState() => _fa.authStateChanges();

  User? get currentUser => _fa.currentUser;

  Future<UserCredential> signInAnon() => _fa.signInAnonymously();

  Future<void> signOut() => _fa.signOut();
}
