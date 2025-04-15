import 'package:flutter/material.dart';
import 'package:my_project/navigation_bar.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
        Navigator.pushNamed(context, '/urubuga');
        break;
      case 3:
        Navigator.pushNamed(context, '/raporo');
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          'Ibikubiyemo',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileItem(title: 'Amazina', value: 'TRESOR Tresor'),
                  ProfileItem(title: 'Nomero ya telephone', value: '250788435996'),
                  ProfileItem(title: 'Igitsina', value: 'Male'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ProfileItem(title: 'Ururimi', value: 'Kinyarwanda'),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ProfileItem(title: 'Hindura umubare w\'ibanga', value: ''),
                      IconButton(
                        icon: const Icon(Icons.vpn_key, color: Colors.blue),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Kuvamo', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const PoweredBySection(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex, 
        onTap: _onNavItemTapped,
        )
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String title;
  final String value;

  const ProfileItem({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        '$title: $value',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class PoweredBySection extends StatelessWidget {
  const PoweredBySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          const Text('Powered by', style: TextStyle(fontSize: 14)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Innovative VAS',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 5),
              Image.network(
                'https://your-logo-url.com/logo.png', // Replace with actual logo URL
                height: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
