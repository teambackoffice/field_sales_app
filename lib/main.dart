import 'package:flutter/material.dart';
import 'package:location_tracker_app/controller/create_sales_order_controller.dart';
import 'package:location_tracker_app/controller/customer_list_controller.dart';
import 'package:location_tracker_app/controller/item_list_controller.dart';
import 'package:location_tracker_app/controller/login_controller.dart';
import 'package:location_tracker_app/controller/sales_order_controller.dart';
import 'package:location_tracker_app/service/login_service.dart';
import 'package:location_tracker_app/view/login/login_page.dart';
import 'package:location_tracker_app/view/mainscreen/homepage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = LoginService();
  final isLoggedIn = await authService.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => GetCustomerListController()),
        ChangeNotifierProvider(create: (_) => SalesOrderController()),
        ChangeNotifierProvider(create: (_) => ItemListController()),
        ChangeNotifierProvider(create: (_) => CreateSalesOrderController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Location Tracker',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: isLoggedIn ? MainScreen() : LoginPage(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final LoginService _authService = LoginService();

  MyApp({super.key});

  Future<bool> checkLogin() async {
    return await _authService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Location Tracker',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: FutureBuilder<bool>(
        future: checkLogin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data! ? MainScreen() : LoginPage();
        },
      ),
    );
  }
}
