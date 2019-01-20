import 'package:anonymous_chat/main_page.dart';
import 'package:anonymous_chat/my_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _titleFieldController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    prefs = await SharedPreferences.getInstance();
    isLoggedIn = await firebaseAuth.currentUser() != null;
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                MainPage(currentUserId: prefs.getString('id'))),
      );
    }
  }

  Future<Null> signIn() async {
    if (_nameFieldController.text.trim().isEmpty) return;
    prefs = await SharedPreferences.getInstance();
    FirebaseUser firebaseUser = await firebaseAuth.signInAnonymously();
    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData(
          {
            'nickname': _nameFieldController.text.trim(),
            'id': firebaseUser.uid,
            'avatar':
                'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
            'aboutMe': _titleFieldController.text.trim(),
          },
        );

        // Write data to local
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
      } else {
        // Write data to local
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
        await prefs.setString('avatar', documents[0]['avatar']);
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainPage(currentUserId: firebaseUser.uid),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Anonymous Chat",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            TextField(
              controller: _nameFieldController,
              decoration: InputDecoration(
                labelText: "Nickname",
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _titleFieldController,
              decoration: InputDecoration(
                labelText: "Title",
              ),
            ),
            SizedBox(height: 16),
            MyButton(
              onTap: signIn,
              title: 'Sign In Anonymously',
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              font: 16,
            ),
          ],
        ),
      ),
    );
  }
}
