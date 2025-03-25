import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rxn<User> firebaseUser = Rxn<User>();

  final RxBool isLoading = false.obs;
  final RxBool isLogin = true.obs;

  final RxnString photoURL = RxnString();

  @override
  void onInit() {
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _handleAuthChanged);
    super.onInit();
  }

  void _handleAuthChanged(User? user) {
    print("🔁 Auth state changed: ${user?.email}");
    if (user == null) {
      Get.offAllNamed('/auth');
    } else {
      _createUserDocumentIfNeeded(user);
      photoURL.value = user.photoURL;
      Get.offAllNamed('/home');
    }
  }


  Future<void> _createUserDocumentIfNeeded(User user) async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await userDocRef.get();

    final photoURL = user.photoURL;

    if (!docSnapshot.exists) {
      // New user → create document with photo
      await userDocRef.set({
        'email': user.email,
        'photoURL': photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("🆕 Created Firestore user doc for ${user.email}");
    } else {
      // Existing user → update photo if it's missing or changed
      final existingData = docSnapshot.data()!;
      if (existingData['photoURL'] != photoURL) {
        await userDocRef.update({
          'photoURL': photoURL,
        });
        print("🔄 Updated profile photo for ${user.email}");
      }
    }
  }


  Future<void> submitAuth(String email, String password) async {
    try {
      isLoading.value = true;
      if (isLogin.value) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
      }
    } catch (e) {
      Get.snackbar("Auth Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      Get.snackbar("Google Sign-In Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void toggleAuthMode() {
    isLogin.value = !isLogin.value;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
