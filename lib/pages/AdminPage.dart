import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isAdmin = true;
  bool isLoading = false;
  bool isAdminRole = false; // Default to User role

  @override
  void initState() {
    super.initState();
    checkAdminStatus();
  }

  Future<void> checkAdminStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        isAdmin = doc['role'] == 'admin';
        print(isAdmin);
        isAdmin = true; // For testing purposes
      });
    }
  }

  Future<void> inviteUser(String email) async {
    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: "temporaryPassword123!", // Use a secure temporary password
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': isAdminRole ? 'admin' : 'user', // Use the switch state
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitation sent to $email')),
      );

      _emailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to invite user: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text("Admin Page")),
        body: Center(child: Text("Access Denied. Admins only.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Admin Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Invite a New User",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "User Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an email";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Admin Role'),
                  Switch(
                    value: isAdminRole,
                    onChanged: (bool value) {
                      setState(() {
                        isAdminRole = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    inviteUser(_emailController.text.trim());
                  }
                },
                child: Text("Send Invitation"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}