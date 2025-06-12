
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
class AuthServices
{
  static AuthServices authServices = AuthServices._();

  AuthServices._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> createAccountWithEmailAndPassword({ String? email, String? password})
  async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email??"", password: password??"");
  }

  Future<String> signInWithEmailAndPassword({ String? email, String? password})
  async {

      await _firebaseAuth.signInWithEmailAndPassword(email: email??"", password: password??"");
      return 'Success';

  }

  Future<void> signOut()
  async {
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser()
  {
    User? user = _firebaseAuth.currentUser;

    if(user!=null)
    {
      log("email : ${user.email}");
    }
    return user;
  }

  Future<String> forgotPassword(String email)
  async {
    try
    {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return 'Success';
    }
    catch (e)
    {
      return e.toString();
    }
  }
}