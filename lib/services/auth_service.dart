import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserType userType,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(name);

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(result.user?.uid).set({
        'id': result.user?.uid,
        'name': name,
        'email': email,
        'userType': userType.name,
        'createdAt': FieldValue.serverTimestamp(),
        'isProfileComplete': false,
      });

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential result = await _auth.signInWithCredential(credential);

      // Save user data to Firestore if it's a new user
      if (result.additionalUserInfo?.isNewUser == true) {
        await _firestore.collection('users').doc(result.user?.uid).set({
          'id': result.user?.uid,
          'name': result.user?.displayName ?? '',
          'email': result.user?.email ?? '',
          'userType': UserType.cliente.name,
          'createdAt': FieldValue.serverTimestamp(),
          'isProfileComplete': false,
        });
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error with Google Sign-In: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update user profile
  Future<void> updateUserProfile({String? name, String? phone}) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        if (name != null) {
          await user.updateDisplayName(name);
        }

        // Update Firestore document
        Map<String, dynamic> updateData = {};
        if (name != null) updateData['name'] = name;
        if (phone != null) updateData['phone'] = phone;

        if (updateData.isNotEmpty) {
          await _firestore.collection('users').doc(user.uid).update(updateData);
        }
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró un usuario con este correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      case 'operation-not-allowed':
        return 'Esta operación no está permitida.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }

  // Remember user functionality
  static const String _rememberUserKey = 'remember_user';
  static const String _savedEmailKey = 'saved_email';

  // Save user credentials
  Future<void> saveUserCredentials(String email, bool rememberUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberUserKey, rememberUser);
    if (rememberUser) {
      await prefs.setString(_savedEmailKey, email);
    } else {
      await prefs.remove(_savedEmailKey);
    }
  }

  // Get saved email
  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberUser = prefs.getBool(_rememberUserKey) ?? false;
    if (rememberUser) {
      return prefs.getString(_savedEmailKey);
    }
    return null;
  }

  // Check if user should be remembered
  Future<bool> shouldRememberUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberUserKey) ?? false;
  }

  // Clear saved credentials
  Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberUserKey);
    await prefs.remove(_savedEmailKey);
  }

  // Update profile complete status
  Future<void> updateProfileComplete(String userId, bool isComplete) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isProfileComplete': isComplete,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating profile status: $e');
    }
  }

  // Save cliente profile
  Future<void> saveClienteProfile(PerfilCliente perfil) async {
    try {
      await _firestore
          .collection('perfiles_cliente')
          .doc(perfil.usuarioId)
          .set(perfil.toJson());
    } catch (e) {
      throw Exception('Error saving cliente profile: $e');
    }
  }

  // Save proveedor profile
  Future<void> saveProveedorProfile(PerfilProveedor perfil) async {
    try {
      await _firestore
          .collection('perfiles_proveedor')
          .doc(perfil.usuarioId)
          .set(perfil.toJson());
    } catch (e) {
      throw Exception('Error saving proveedor profile: $e');
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }

  // Get cliente profile
  Future<PerfilCliente?> getClienteProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('perfiles_cliente')
          .doc(userId)
          .get();
      if (doc.exists) {
        return PerfilCliente.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting cliente profile: $e');
    }
  }

  // Get proveedor profile
  Future<PerfilProveedor?> getProveedorProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('perfiles_proveedor')
          .doc(userId)
          .get();
      if (doc.exists) {
        return PerfilProveedor.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting proveedor profile: $e');
    }
  }

  // Update user type
  Future<void> updateUserType(String userId, UserType userType) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'userType': userType.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating user type: $e');
    }
  }
}
