import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_advance/UI/main_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailField = TextEditingController();
  TextEditingController usernameField = TextEditingController();
  TextEditingController passwordField = TextEditingController();
  bool statusObsecure = true;

  String messageError = '';
  void setObsecurePass() {
    statusObsecure = !statusObsecure;
    notifyListeners();
  }

  void processLogin(BuildContext context) async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    if (formKey.currentState!.validate()) {
      await _sharedPreferences.setString('username', usernameField.text);
      await _sharedPreferences.setString('email', emailField.text);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(emailField.text, usernameField.text),
          ));
    }
    notifyListeners();
  }

  void loginWithGoogle(BuildContext context) async {
    try {
      GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User dataUser = userCredential.user!;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(dataUser.email ?? '-', dataUser.uid),
          ));
    } on FirebaseAuthException catch (error) {
      messageError = error.message!;
    } catch (e) {
      messageError = e.toString();
    }

    notifyListeners();
  }
}
