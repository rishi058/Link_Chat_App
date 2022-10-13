import 'package:flutter/material.dart';
import 'package:link/service/Dataservice.dart';
import 'Widget.dart';
import '../Page/chat_page.dart';

class GroupTile extends StatefulWidget {
  final String tileName;
  final String pairId;
  final String RecentMessage;
  final String image_url;
  const GroupTile(
      {Key? key,
        required this.pairId,
        required this.tileName,
        required this.RecentMessage,
        required this.image_url,
        })
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {

  void deleteDialog(){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete"),
            content: Text("Are you sure you want to Unfriend\n${widget.tileName} ?",),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.blue,),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await DatabaseService().deletepair(widget.pairId) ;
                  Navigator.pop(context) ;
                  // nextScreen(context, const HomePage());
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.blue,),
                ),
              ),

            ],
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              pairId: widget.pairId,
              tileName: widget.tileName,
              userName: UserName,
            ));
      },
      onLongPress: (){deleteDialog();},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Container(
          // color: Colors.redAccent,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xFFee7b64).withOpacity(0.5),
          ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: NetworkImage(widget.image_url),
                    fit: BoxFit.fill
                ),
              ),
            ),
            title: Text(
              widget.tileName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              widget.RecentMessage,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}
