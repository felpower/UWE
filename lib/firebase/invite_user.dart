import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> inviteUser(String email, String role) async {
  try {
    // Send email invite link (This part would typically use a backend to send the actual email)
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: "temporaryPassword", // Generate a secure temporary password
    );

    // Save user role to Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
      'role': role, // 'admin' or 'user'
    });
  } catch (e) {
    print("Error inviting user: $e");
  }
}

Future<String?> getUserRole(String uid) async {
  DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
  return doc['role'] as String?;
}

void checkUserRole() async {
  User? user = _auth.currentUser;
  if (user != null) {
    String? role = await getUserRole(user.uid);
    if (role == 'admin') {
      // Show admin features
    } else {
      // Show normal user features
    }
  }
}


Future<void> uploadImage(String uid, File imageFile) async {
  Reference storageRef =
  FirebaseStorage.instance.ref().child('user_images/$uid/profile.jpg');
  await storageRef.putFile(imageFile);
}
