import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void authStateChanges() async {
    await Future.delayed(const Duration(seconds: 4));
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }
}
