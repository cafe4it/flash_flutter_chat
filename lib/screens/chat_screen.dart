import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = auth.FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  auth.User loggedInUser;
  final txtMessage = TextEditingController();
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async{
    try{
      final user = await _auth.currentUser;
      if(user != null){
        loggedInUser = user;
        print(loggedInUser);
      }else{
        Navigator.pushNamed(context, LoginScreen.id);
      }
    }catch(ex){
      print(ex);
    }
  }

  void handleSendMessage() async{
    if(txtMessage.text.isNotEmpty){
      await _firestore.collection('messages').add({
        'text': txtMessage.text,
        'sender': loggedInUser.email,
        'sendAt': new DateTime.now()
      });
      txtMessage.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').orderBy('sendAt', descending: false).snapshots(),
              builder: (context, snapshot){
                List<MessageBubble> items = [];
                if(snapshot.hasData){
                  final messages = snapshot.data.documents;
                  for(var message in messages){
                    // print(message.get('text'));
                    final text = message.get('text');
                    final sender = message.get('sender');
                    items.add(MessageBubble(sender: sender, text: text, isMe: loggedInUser.email == sender,));
                  }
                }
                return Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    children: items,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: txtMessage,
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: handleSendMessage,
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({@required this.sender, @required this.text, @required this.isMe});

  final String text;
  final String sender;
  final bool isMe;

  BorderRadiusGeometry _messageBorder = BorderRadius.only(
      topLeft: Radius.circular(30),
      bottomLeft: Radius.circular(30),
      bottomRight: Radius.circular(30)
  );

  @override
  Widget build(BuildContext context) {
    if(isMe == true){
      _messageBorder = BorderRadius.only(
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30)
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(sender, style: TextStyle(
            fontSize: 12,
            color: Colors.black54
          ),),
          Material(
            color: isMe ? Colors.white : Colors.lightBlueAccent,
            elevation: 5,
            borderRadius: _messageBorder,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe ? Colors.black : Colors.white
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

