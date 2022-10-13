import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:link/service/authservice.dart';
import '../service/Dataservice.dart' ;
import '../Widget/Widget.dart';
import 'Profile.dart';
import 'Login.dart';
import '../Page/About_page.dart';

class My_Drawer extends StatelessWidget {
  My_Drawer({Key? key, required this.username, required this.email})
      : super(key: key);

  final String username;
  final String email;
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: const EdgeInsets.symmetric(vertical: 50),
      children: <Widget>[
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image: FileImage(image!),
                fit: BoxFit.fitHeight
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          username,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 30,
        ),
        const Divider(
          thickness: 1,
          height: 2,
        ),
        ListTile(
          onTap: () {
            nextScreen(
              context,
              ProfilePage(uid : FirebaseAuth.instance.currentUser!.uid.toString(), isuser: true,),
            );
          },
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: const Icon(Icons.group),
          title: const Text(
            "Profile",
            style: TextStyle(color: Colors.black),
          ),
        ),
        const Divider(
          thickness: 1,
          height: 2,
        ),
        ListTile(
          onTap: () async {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'No',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      SizedBox(width: 120),
                      TextButton(
                        onPressed: () async {
                          await authService.signOut();
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                              (route) => false);
                        },
                        child: const Text(
                          'Yes',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),

                    ],
                  );
                });
          },
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: const Icon(Icons.exit_to_app),
          title: const Text(
            "Logout",
            style: TextStyle(color: Colors.black),
          ),
        ),
        const Divider(
          thickness: 1,
          height: 2,
        ),
        ListTile(
          onTap: () {
            Navigator.push(context,MaterialPageRoute(builder: (context) {return About();},),);
          },
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: const Icon(Icons.info),
          title: const Text(
            "About Developer",
            style: TextStyle(color: Colors.black),
          ),
        ),
        const Divider(
          thickness: 1,
          height: 2,
        ),
      ],
    ));
  }
}
