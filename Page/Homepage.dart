import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Widget/Widget.dart';
import 'package:link/service/authservice.dart';
import '../SP.dart';
import 'package:link/service/Dataservice.dart';
import 'package:link/Widget/tile.dart';
import 'Drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? pairs;
  bool _isLoading = false;
  String frienEmail = "";
  bool load = true;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });

    await DatabaseService(uid: uid).gettingUserData(email).then((snap) {
      setState(() {
        pairs = snap;
        load = false;
      });
    });
  }

  Widget addbutton() {
    return InkWell(
      onTap: (){
        popUpDialog(context);
      },
        borderRadius: BorderRadius.circular(15),
        child: Container(
      margin: EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xffee3a18),
      ),
      child: Row(
        children: [SizedBox(width: 5,), Text('Add'), Icon(Icons.add_box_outlined), SizedBox(width: 5,)],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white,Colors.white, Colors.red.shade100])),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            addbutton(),
            SizedBox(width: 5,)
          ],
          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            "Link",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
          ),
        ),
        drawer: My_Drawer(
          username: userName,
          email: email,
        ),
        backgroundColor: Colors.transparent,
        body: load
            ? Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor),
              )
            : groupList(),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: const Text(
                "Find a Friend",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontStyle: FontStyle.italic, fontWeight: FontWeight.w300),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isLoading == true
                        ? Center(
                            child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor),
                          )
                        : TextField(
                            onChanged: (val) {
                              setState(() {
                                frienEmail = val;
                              });
                            },
                            style: const TextStyle(color: Colors.black),
                            decoration: textInputDecoration.copyWith(
                                labelText: "Email",
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Theme.of(context).primaryColor,
                                )),
                          ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      child: const Text("CANCEL"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (frienEmail != "") {
                          setState(() {
                            _isLoading = true;
                          });
                          await DatabaseService(uid: uid)
                              .isUserExist(frienEmail)
                              .whenComplete(() async {
                            if (flag == false || frienEmail == email) {
                              _isLoading = false;
                              Navigator.of(context).pop();
                              showSnackbar(
                                  context, Colors.red, "Invalid Credential");
                            } else {
                              QuerySnapshot snap =
                                  await DatabaseService(uid: uid)
                                      .userCollection
                                      .where('email', isEqualTo: frienEmail)
                                      .get();
                              var temp =
                                  snap.docs.map((e) => e.data()).toList();
                              var temp2 = temp[0] as Map<String, dynamic>;
                              String name = temp2['name'] as String;
                              await DatabaseService(uid: uid)
                                  .isPairExist(userName, name)
                                  .whenComplete(() {
                                if (flag2 == true) {
                                  _isLoading = false;
                                  Navigator.of(context).pop();
                                  showSnackbar(context, Colors.red,
                                      "This Email is in your already your Friend List ");
                                } else {
                                  DatabaseService(
                                          uid: FirebaseAuth
                                              .instance.currentUser!.uid)
                                      .createPair(userName, frienEmail)
                                      .whenComplete(() {
                                    gettingUserData();
                                    _isLoading = false;
                                  });
                                  Navigator.of(context).pop();
                                  showSnackbar(context, Colors.green,
                                      "Group created successfully.");
                                }
                              });
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      child: const Text("ADD"),
                    ),
                  ],
                ),
              ],
            );
          }));
        });
  }

  groupList() {
    return StreamBuilder(
      stream: pairs,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (pairs == null) {
          return noGroupWidget();
        }
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            if (snapshot.data.size != 0) {
              return ListView.builder(
                itemCount: snapshot.data.size,
                itemBuilder: (context, index) {
                  return GroupTile(
                    pairId: snapshot.data.docs[index]['pairId'],
                    tileName: snapshot.data.docs[index]['uid1'] == userName
                        ? snapshot.data.docs[index]['uid2']
                        : snapshot.data.docs[index]['uid1'],
                    RecentMessage: snapshot.data.docs[index]
                                ['recentMessageSender'] ==
                            userName
                        ? "You : " + snapshot.data.docs[index]['recentMessage']
                        : snapshot.data.docs[index]['uid2'] == userName
                            ? snapshot.data.docs[index]['uid1'] +
                                " : " +
                                snapshot.data.docs[index]['recentMessage']
                            : snapshot.data.docs[index]['uid2'] +
                                " : " +
                                snapshot.data.docs[index]['recentMessage'],
                    image_url: snapshot.data.docs[index]['dp_1'] == image_url
                        ? snapshot.data.docs[index]['dp_2']
                        : snapshot.data.docs[index]['dp_1'],
                  );
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You have not added any friends yet. Tap on the add icon to add a friend.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
