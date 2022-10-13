import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFee7b64)])),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFee7b64),
            title: const Text(' About - Developer '),
          ),
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 80,
                ),
                Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage('assets/images/444.png'),
                        fit: BoxFit.fill
                    ),
                  ),
                ),


                const SizedBox(
                  height: 20,
                ),
                const Text('Rishi Raj', style: TextStyle(
                    fontSize: 30,
                    // color: Colors.white
                ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text('Link Id   ->   rishi1@rishi.com'),

                const SizedBox(
                  height: 100,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                      onTap: () async {
                        // final url = Uri.parse('https://www.instagram.com/_rishi_ryan_/');
                        // await launchUrl(url);
                        await launch('https://www.instagram.com/_rishi_ryan_/');

                      },

                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage('assets/images/insta.png'),
                              fit: BoxFit.fill
                          ),
                        ),
                      ),
                    ),

                    InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                      onTap: () async {
                        // final url = Uri.parse('https://www.linkedin.com/in/rishi-raj-32648a196/');
                        // await launchUrl(url);
                        await launch('https://www.linkedin.com/in/rishi-raj-32648a196/');

                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage('assets/images/link.jpg'),
                              fit: BoxFit.fill
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
      ),
    );
  }
}
