import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;

import '../chat/message.dart';

class ChatBotScreen extends StatefulWidget {
  static const String idScreen = "ChatBotScreen";

  @override
  _ChatBotScreen createState() => _ChatBotScreen();
}

class _ChatBotScreen extends State<ChatBotScreen> {
  final LocalStorage storage = new LocalStorage('localstorage_app');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController message = new TextEditingController();

  String name = "", email = "", imgUrl = "";
  int members=0;
  bool member_in_available=true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  initialise() {

  }

  void _displayChat(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
            padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: messages(
                      email: storage.getItem('email'),
                      id: storage.getItem('user_id')
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: message,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black12,
                            hintText: 'Type a message...',
                            enabled: true,
                            contentPadding: const EdgeInsets.only(
                                left: 14.0, bottom: 8.0, top: 8.0),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(50),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderRadius: new BorderRadius.circular(50),
                            ),
                          ),
                          validator: (value) {},
                          onSaved: (value) {
                            message.text = value!;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (message.text.isNotEmpty) {
                            firestore.collection("bots").doc(storage.getItem('user_id')).collection('messages').doc().set({
                              'message': message.text.trim(),
                              'time': DateTime.now(),
                              'date_time': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()).toString(),
                              'email': storage.getItem('email'),
                              'name':storage.getItem('name')
                            });

                            var url ='http://192.168.1.101:5000/bot';

                            var response = await http.post( Uri.parse(url),
                                body: json.encode({'msg': message.text.trim()}) );
                            var decoded = json.decode(response.body) as Map<String, dynamic>;
                            print(decoded['reply']);
                            if(decoded['reply']!=""){
                              firestore.collection("bots").doc(storage.getItem('user_id')).collection('messages').doc().set({
                                'message': decoded['reply'],
                                'time': DateTime.now(),
                                'date_time': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()).toString(),
                                'email': "Bot",
                                'name': "Bot"
                              });
                            }

                            message.clear();
                          }
                        },
                        icon: Icon(Icons.send_sharp),
                        color: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.clear,
              color: Colors.white,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    var body = new SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 35.0,
            ),
            Image(
              image: AssetImage("images/logo.png"),
              width: 250.0,
              height: 250.0,
              alignment: Alignment.center,
            ),
            SizedBox(
              height: 1.0,
            ),
            Text(
              "Chat Bot",
              style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  ElevatedButton(
                    child: Container(
                      height: 50.0,
                      child: Center(
                        child: Text(
                          "Open Chat",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                              color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _displayChat(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text("Chat Bot"),
        ),
        backgroundColor: Colors.white,
        body: new Container(child: body));
  }

}
