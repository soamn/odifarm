import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odifarm/pages/auth_gate.dart';
import 'package:odifarm/pages/cart.dart';
import 'package:odifarm/pages/categories.dart';
import 'package:odifarm/pages/home.dart';
import 'package:odifarm/pages/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:odifarm/notifiers/cart_notifier.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // your desired color
      statusBarIconBrightness: Brightness.light, // icons color (light/dark)
    ),
  );
  await Supabase.initialize(
    url: 'db',
    anonKey:
        'anon key',
  );
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartNotifier())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(), // all pages wrapped in one shell
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    Home(),
    Categories(),
    const CartPage(),
    const Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 2) {
      // Refresh cart when Cart tab is tapped
      Provider.of<CartNotifier>(context, listen: false).fetchCart();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartNotifier>(context, listen: false).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Consumer<CartNotifier>(
        builder: (context, cartNotifier, _) {
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Color.fromARGB(255, 146, 99, 95)),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.category,
                  color: Color.fromARGB(255, 146, 99, 95),
                ),
                label: "Categories",
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: Color.fromARGB(255, 146, 99, 95),
                    ),
                    if (cartNotifier.cartCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 146, 99, 95),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cartNotifier.cartCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: "Cart",
              ),

              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 146, 99, 95),
                ),
                label: "Profile",
              ),
            ],
          );
        },
      ),
    );
  }
}
