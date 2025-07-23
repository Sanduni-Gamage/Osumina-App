import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class messages extends StatefulWidget {
  final String email,id;
  messages({required this.email,required this.id});
  @override
  _messagesState createState() => _messagesState();
}

class _messagesState extends State<messages> {

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> _messageStream = FirebaseFirestore.instance
        .collection('bots')
        .doc(widget.id)
        .collection('messages')
        .orderBy('time')
        .snapshots();
    return StreamBuilder(
      stream: _messageStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("something is wrong");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          physics: ScrollPhysics(),
          shrinkWrap: true,
          primary: true,
          itemBuilder: (_, index) {
            QueryDocumentSnapshot qs = snapshot.data!.docs[index];
            return Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Column(
                crossAxisAlignment: widget.email == qs['email']
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 300,
                    child: ListTile(
                      textColor: widget.email == qs['email']
                          ? Colors.white
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: widget.email == qs['email']
                            ? BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20),topLeft: Radius.circular(20))
                            : BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20),topRight: Radius.circular(20)),
                      ),
                      title: Text(
                        qs['name'],
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 200,
                            child: Text(
                              qs['message'],
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),SizedBox(
                      width: 55,
                      child:Text(
                            qs['date_time'],
                            style: TextStyle(
                              fontSize: 10,
                              overflow: TextOverflow.fade,
                            ),
                            maxLines: 2,
                          )
                          )
                        ],
                      ),
                      tileColor: widget.email == qs['email']
                          ? Colors.blue
                          : Colors.black12
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}