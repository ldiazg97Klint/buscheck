import 'package:BusGo/myApp/GoRouterClass.dart';
import 'package:BusGo/myApp/ThemeDataClass.dart';
import 'package:BusGo/ui/app_bar/AppBarWidget.dart';
import 'package:BusGo/ui/pages/HomePage/Home/HomePage.dart';
import 'package:BusGo/ui/pages/Statistics/StatisticsPage.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: themeDataInitial(),
      debugShowCheckedModeBanner: false,
      // home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBarWidget(context),
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Evita deslizar entre páginas
        children: [
          HomePage(),
          StatisticsPage(),
        ],
      ),
    );
  }
}
