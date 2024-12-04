import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/style.dart';

// Screens
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'home_staff.dart';
import 'profile_screen.dart';
import 'map_screen.dart';
import 'pages/chat_screen.dart';
import 'weather_screen.dart';
import 'ticket_screen.dart';
import 'transaction_screen.dart';
import 'event_screen.dart';
import 'report_screen.dart';
import 'analysis_screen.dart';
import 'add_ticket_screen.dart';
import 'edit_price_screen.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:myapp/utils/style.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tahura Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: TahuraColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: TahuraColors.textPrimary),
          titleTextStyle: TahuraTextStyles.appBarTitle,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: TahuraButtons.primaryButton,
        ),
        inputDecorationTheme: TahuraInputDecorations.defaultInputTheme, // Gunakan defaultInputTheme
      ),
      builder: (context, child) {
        ScreenUtils().init(context);
        return MediaQuery(

          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => HomeScreen(
            email: ModalRoute.of(context)!.settings.arguments as String),
        '/home_staff': (context) => const HomeStaff(),
        '/profile': (context) => ProfileScreen(
            email: ModalRoute.of(context)!.settings.arguments as String),
        '/map': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          final email = args is String ? args : 'user';
          return OSMFlutterMap(
              isAdminOrStaff: email == 'admin' || email == 'staff');
        },
        '/chat': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String;
          return ChatScreen(
              isAdminOrStaff: email == 'admin' || email == 'staff');
        },
        '/weather': (context) => WeatherScreen(),
        '/ticket': (context) => const TicketScreen(),
        '/event': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String?;
          return EventScreen(
              isAdminOrStaff: args == 'admin' || args == 'staff');
        },
        '/payment': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          final totalPrice = args?['totalPrice'] ?? 0.0;
          return TransactionScreen(totalPrice: totalPrice);
        },
        '/analysis': (context) => AnalysisScreen(),
        '/report': (context) => ReportScreen(),
      },
    );
  }
}
