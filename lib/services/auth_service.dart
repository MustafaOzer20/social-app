import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_app/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String activeUserId;

  Users _buildUser(User user) {
    return user == null ? null : Users.firebaseBuildUser(user);
  }
  Stream<Users> get stateManagment {
    return _auth.authStateChanges().map(_buildUser);
  }

  Future<Users> signUpWithEmail(String email, String passwd)async{
    var loginCard = await _auth.createUserWithEmailAndPassword(email: email, password: passwd);
    return _buildUser(loginCard.user);
  }

  Future<Users> signInWithEmail(String email, String passwd)async{
    var loginCard = await _auth.signInWithEmailAndPassword(email: email, password: passwd);
    return _buildUser(loginCard.user);
  }

  Future<void> logOut(){
    return _auth.signOut();
  }

  resetMyPassword(String email){
    _auth.sendPasswordResetEmail(email: email);
  }

  Future<Users> signInWithGoogle() async{
    try{
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().disconnect();
    }catch(e){
      print(e.code);
    }
    GoogleSignInAccount googleAcc = await GoogleSignIn().signIn();
    GoogleSignInAuthentication googleAuth = await googleAcc.authentication;
    AuthCredential noPasswordLogIn = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken
    );
    UserCredential logCard = await _auth.signInWithCredential(noPasswordLogIn);
    return _buildUser(logCard.user);
  }

}