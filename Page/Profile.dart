import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../service/Dataservice.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  String uid;
  bool isuser;
  ProfilePage({
    Key? key,
    required this.uid,
    required this.isuser,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map temp = {};
  bool is_Loading = true;
  TextEditingController _bioController = TextEditingController() ;
  File? _pickedImage ;


  void chooseImage0() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxWidth: 150,
    );
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
      image = _pickedImage ;
    });
    Navigator.pop(context);
    uploadtask();
  }

  void chooseImage1() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 150,
    );
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
      image = _pickedImage ;
    });
    Navigator.pop(context);
    uploadtask();
  }

  void uploadtask() async {
    String uid = FirebaseAuth.instance.currentUser!.uid.toString() ;


    final ref = FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child('$uid.jpg');

    await ref.putFile(_pickedImage!).whenComplete(() async {
      String url = await ref.getDownloadURL();
      DatabaseService(uid : uid).updateDp(url) ;
      DatabaseService(uid:uid).gettingUserData(UserEmail);
    });
  }


  void run() async {
    DocumentSnapshot snap = await DatabaseService().userCollection.doc(widget.uid).get() ;
    var dataa = snap.data() as Map ;

    setState(() {
      temp = dataa;
      is_Loading = false;
      _bioController.text = temp['Bio'] ;
    });
  }

  void pressed() async {
    setState(() {
      temp['Bio'] = _bioController.text ;
    });
    String uid  = await FirebaseAuth.instance.currentUser!.uid ;
    await DatabaseService(uid: uid).updatebio(_bioController.text) ;
    await DatabaseService(uid: uid).gettingUserData(UserEmail) ;
    run();
  }

  void showForm(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            // this will prevent the soft keyboard from covering the text fields
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(hintText: 'Bio'),
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                   pressed();
                   Navigator.pop(context) ;
                },
                child: Text('Save'),
              ),
            ],
          ),
        ));
  }

  void showForm0(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            // this will prevent the soft keyboard from covering the text fields
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Center(
                child: MaterialButton(onPressed: (){
                  chooseImage0();
                },
                  child: const Text('Open Camera', style: TextStyle(color: Colors.white),),
                  color: Color(0xFFee7b64),
                ),
              ),
              const Divider(
                thickness: 2,
                height: 20,
              ),
              Center(
                child: MaterialButton(onPressed: (){
                  chooseImage1();
                },
                  child: const Text('Choose from Gallery', style: TextStyle(color: Colors.white),),
                  color: Color(0xFFee7b64),

                ),
              ),

            ],
          ),
        ));
  }


  @override
  void initState() {
    super.initState();
    run();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          widget.isuser == true ? PopupMenuButton(
              itemBuilder: (context){
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text("Edit Profile Picture"),
                  ),

                  PopupMenuItem<int>(
                    value: 1,
                    child: Text("Edit Bio"),
                  ),
                ];
              },
              onSelected:(value){
                if(value == 0){
                  showForm0(context);
                }else if(value == 1){
                  showForm(context) ;
                }
              }
          ) : SizedBox(),
        ],

      ),
      body: is_Loading || temp.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : SingleChildScrollView(
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: widget.isuser==false? NetworkImage(temp['profilePic']) : _pickedImage==null ? FileImage(image!) : FileImage(_pickedImage!) as ImageProvider,
                            fit: BoxFit.fitHeight
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Full Name", style: TextStyle(fontSize: 17)),
                            Text(temp["name"], style: const TextStyle(fontSize: 17),),
                      ],
                    ),
                    const Divider(
                      thickness: 2,
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Email", style: TextStyle(fontSize: 17)),
                        Text(temp["email"], style: const TextStyle(fontSize: 17)),
                      ],
                    ),
                    const Divider(
                      thickness: 2,
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Friends ", style: TextStyle(fontSize: 17)),
                        Text(temp["pairs"].length.toString(), style: const TextStyle(fontSize: 17)),
                      ],
                    ),
                    const Divider(
                      thickness: 2,
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Bio ", style: TextStyle(fontSize: 17)),
                        Container(
                          alignment: Alignment.centerRight,
                          width: 250,
                          child : Text(temp["Bio"], style: const TextStyle(fontSize: 17),),
                        ),
                      ],
                    ),
                    const Divider(
                      thickness: 2,
                      height: 20,
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}
