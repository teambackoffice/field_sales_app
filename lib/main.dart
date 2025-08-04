import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker_app/api/fiebase_api.dart';
import 'package:location_tracker_app/controller/create_payment_entry_controller.dart';
import 'package:location_tracker_app/controller/create_sales_order_controller.dart';
import 'package:location_tracker_app/controller/create_sales_return_contoller.dart';
import 'package:location_tracker_app/controller/customer_list_controller.dart';
import 'package:location_tracker_app/controller/invoice_list_controller.dart';
import 'package:location_tracker_app/controller/item_list_controller.dart';
import 'package:location_tracker_app/controller/login_controller.dart';
import 'package:location_tracker_app/controller/mode_of_pay_controller.dart';
import 'package:location_tracker_app/controller/pay_sales_invoice_controller.dart';
import 'package:location_tracker_app/controller/payment_entry_controller.dart';
import 'package:location_tracker_app/controller/sales_order_controller.dart';
import 'package:location_tracker_app/controller/sales_return_controller.dart';
import 'package:location_tracker_app/firebase_options.dart';
import 'package:location_tracker_app/service/login_service.dart';
import 'package:location_tracker_app/view/login/login_page.dart';
import 'package:location_tracker_app/view/mainscreen/homepage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Start notifications but don’t wait indefinitely
  FirebaseApi().initNotification();

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
        ChangeNotifierProvider(create: (_) => InvoiceListController()),
        ChangeNotifierProvider(create: (_) => PaySalesInvoiceController()),
        ChangeNotifierProvider(create: (_) => PaymentEntryController()),
        ChangeNotifierProvider(create: (_) => ModeOfPayController()),
        ChangeNotifierProvider(create: (_) => CraetePaymentEntryController()),
        ChangeNotifierProvider(create: (_) => CreateSalesReturnController()),
        ChangeNotifierProvider(create: (_) => SalesReturnController()),
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
