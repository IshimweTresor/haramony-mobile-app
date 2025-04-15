import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_project/navigation_bar.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/nta_interineti');
        break;
      case 2:
        Navigator.pushNamed(context, '/forum');
        break;
      case 3:
        Navigator.pushNamed(context, '/report');
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 17, 39),
      
      body: 
        Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 80, left: 20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Text("Hello,",
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.white)),
                  Text("TRESOR",
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("Households survey",
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
                ],
                    ),
                  ),
                  Container(
                    child: Column(
                     children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                         icon: Icon(Icons.settings, color: Colors.white)
                         ),
                         IconButton(onPressed: () {},
                         icon: Icon(Icons.search, color: Colors.white)
                         )
                     ],
                    ),
                    
                  )

                ],
              )
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)
                  ),
              color: Color.fromARGB(255, 199, 205, 209),
                  
                ),
                padding: const EdgeInsets.only(top: 30, left: 10),
               child:  Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ListTile(
              tileColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: Icon(Icons.folder, color: Colors.black),
              title: Text("Ibibazo by'umurwayi", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {},
            ),
                      ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: ListTile(
              tileColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: Icon(Icons.folder, color: Colors.black),
              title: Text("Ibibazo by'ibitaro", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {},
            ),
            )
                    ],
                  ),
                )
              )
              )
          ],
        ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
