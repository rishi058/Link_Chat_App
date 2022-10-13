import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:link/Page/Login.dart';
import 'package:link/Widget/Widget.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' ;

bool flag = false;
bool flag2 = false;

Map userData = {};
String UserEmail = "";
String UserName = "" ;
String UserId = "" ;
String image_url = "";
String dummy_network_image = "https://firebasestorage.googleapis.com/v0/b/link-e5390.appspot.com/o/dummy.png?alt=media&token=82d31d96-a7ef-482e-a5be-e121b05b918e" ;
File? image ;


class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference pairCollection = FirebaseFirestore.instance.collection("all_pairs");

  // saving the userdata
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "name": fullName,
      "email": email,
      "pairs": [],
      "profilePic": dummy_network_image ,
      "uid": uid,
      "Bio" : "",
    });
  }

  Future<File> fileFromImageUrl(String url) async {
    final response = await http.get(Uri.parse(url));

    final documentDirectory = await getApplicationDocumentsDirectory();

    final file = File(join(documentDirectory.path, 'profilepic.png'));

    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  Future<String> getname(String email) async {
    QuerySnapshot snap = await userCollection.where('email', isEqualTo: email).get() ;
    var myData = snap.docs.map((e) => e.data()).toList() ;
    var data = myData[0] as Map;
    return data['name'] ;
  }

  // getting user data
  Future gettingUserData(String email) async {
    if(uid==null){nextScreen(context, LoginPage());}
    List<dynamic> data;
    DocumentSnapshot snap = await userCollection.doc(uid).get() ;
    var temp = snap.data() as Map ;

    userData = temp;
    data = temp['pairs'] ;
    UserEmail = temp['email'] ;
    image = await fileFromImageUrl(temp['profilePic']) ;
    UserName = temp['name'] ;
    UserId = temp['uid'] ;
    image_url = temp['profilePic'] ;

    if(data.isEmpty){return;}
    Stream info =  pairCollection.where('pairId', whereIn: data).orderBy("recentMessageTime", descending: true).snapshots();
    return info;

  }

  // creating a group
  Future createPair(String username,String friendEmail) async {

    QuerySnapshot snapshot = await userCollection.where("email", isEqualTo: friendEmail).get();
    var myData = snapshot.docs.map((e) => e.data()).toList() ;
    var data = myData[0] as Map;
    String uid2 = data['uid'] ;
    String friendName = data['name'];
    String image2 = data['profilePic'] ;


    DocumentReference groupDocumentReference = await pairCollection.add({
      "uid1" : username,
      "uid2" : friendName,
      "recentMessage": "Send Your Friend a message",
      "recentMessageSender": username,
      "recentMessageTime" : DateTime.now().microsecondsSinceEpoch.toString(),
      "dp_1" : image_url ,
      "dp_2" : image2,
    });
    // update the members
    await groupDocumentReference.update({
      "pairId": groupDocumentReference.id,
    });


    DocumentReference userDocumentReference2 = userCollection.doc(uid2);
    await userDocumentReference2.update({
      "pairs":
      FieldValue.arrayUnion([groupDocumentReference.id])
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "pairs":
      FieldValue.arrayUnion([groupDocumentReference.id])
    });

  }

  // getting the chats
  getChats(String pairId) async {
    return pairCollection
        .doc(pairId)
        .collection("messages")
        .orderBy("time", descending: true)
        .snapshots();
  }

  updatebio(String newBio){
    userCollection.doc(uid).update({
      'Bio': newBio,
    });
  }

  updateDp(String url){
    userCollection.doc(uid).update({
      'profilePic' : url ,
    });
  }

  Future isUserExist(String email) async {
    await userCollection.where("email", isEqualTo: email).get().then((value) {
      print(value.size);
      if(value.size==0){flag = false;}
      else {flag = true;}
    });
  }

  Future isPairExist(String userName, String name) async {

    QuerySnapshot snapshot1 = await pairCollection.where("uid1", isEqualTo: name).get();
    QuerySnapshot snapshot2 = await pairCollection.where("uid2", isEqualTo: name).get();
    var myData1 = snapshot1.docs.map((e) => e.data()).toList() ;
    var myData2 = snapshot2.docs.map((e) => e.data()).toList() ;

    for(int i=0; i<myData1.length; i++){
      var data = myData1[i] as Map;
      if(data['uid2']==userName){flag2 = true; break;}
    }

    for(int i=0; i<myData2.length; i++){
      var data = myData2[i] as Map;
      if(data['uid1']==userName){flag2 = true; break;}
    }

  }

  // send message
  sendMessage(String pairId, Map<String, dynamic> chatMessageData) async {

    pairCollection.doc(pairId).collection("messages").add(chatMessageData);

    pairCollection.doc(pairId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });

  }

  deletepair(String pairId) async {

    DocumentSnapshot snap = await pairCollection.doc(pairId).get() ;
    var temp = snap.data() as Map ;
    String username1 = temp['uid1'] as String ;
    String username2 = temp['uid2'] as String ;

    pairCollection.doc(pairId).delete() ;

    QuerySnapshot snp1 = await userCollection.where('name', isEqualTo: username1).get() ;
    var myData1 = snp1.docs.map((e) => e.data()).toList() ;
    var data1 = myData1[0] as Map;
    String uid1 = data1['uid'] ;

    QuerySnapshot snp2 = await userCollection.where('name', isEqualTo: username2).get() ;
    var myData2 = snp2.docs.map((e) => e.data()).toList() ;
    var data2 = myData2[0] as Map;
    String uid2 = data2['uid'] ;

    DocumentReference ref1 = userCollection.doc(uid1);
    await ref1.update({
      "pairs":
      FieldValue.arrayRemove([pairId])
    });

    DocumentReference ref2 = userCollection.doc(uid2);
    await ref2.update({
      "pairs":
      FieldValue.arrayRemove([pairId])
    });

  }

}
