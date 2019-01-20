import 'package:anonymous_chat/chat_page.dart';
import 'package:anonymous_chat/theme.dart';
import 'package:anonymous_chat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final String currentUserId;

  MainPage({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == widget.currentUserId) {
      return Container();
    } else {
      return Column(
        children: <Widget>[
          Divider(height: 1),
          ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: Container(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/avatar.png'),
              ),
            ),
            title: Column(
              children: <Widget>[
                Container(
                  child: Text(
                    '${document['nickname']}',
                  ),
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                ),
                Container(
                  child: Text(
                    '${document['aboutMe'] ?? 'No Title'}',
                  ),
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                )
              ],
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(
                            peerName: document['nickname'],
                            peerId: document.documentID,
                          )));
            },
          ),
        ],
      );
    }
  }

  Future<Null> signOut() async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anonymous Chat'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: signOut,
          ),
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: Firestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
              );
            } else {
              return ListView.builder(
                itemBuilder: (context, index) =>
                    buildItem(context, snapshot.data.documents[index]),
                itemCount: snapshot.data.documents.length,
              );
            }
          },
        ),
      ),
    );
  }
}
