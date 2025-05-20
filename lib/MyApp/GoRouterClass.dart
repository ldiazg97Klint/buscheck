// Configuración de rutas con GoRouter
import 'package:BusGo/myApp/MyApp.dart';
import 'package:BusGo/ui/pages/HomePage/Home/HomePage.dart';
import 'package:BusGo/ui/pages/HomePage/ReportPage.dart';
import 'package:BusGo/ui/pages/Login/loginPage.dart';
import 'package:BusGo/ui/pages/PrinterPage/reports/report1/report1Page.dart';
import 'package:BusGo/ui/pages/PrinterPage/reports/reportsPage.dart';
import 'package:BusGo/ui/pages/ProfilePage/ProfilePage.dart';
import 'package:BusGo/ui/pages/Statistics/StatisticsPage.dart';
import 'package:BusGo/ui/pages/Statistics/StatisticsPageAll.dart';
import 'package:go_router/go_router.dart';

import '../ui/pages/HomePage/Home/widget/ScannerPage.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      // redirect: (context, state) => '/DashboardPage',
      redirect: (context, state) => '/LoginFormPage',
    ),
    GoRoute(
      path: '/HomePage',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/ScannerPage',
      builder: (context, state) => const QrScannerPage(),
    ),
    GoRoute(
      path: '/LoginFormPage',
      builder: (context, state) => const LoginFormPage(),
    ),
    GoRoute(
      path: '/StatisticsPage',
      builder: (context, state) => StatisticsPage(),
    ),
    GoRoute(
      path: '/DashboardPage',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/StatisticsPageAll',
      builder: (context, state) => StatisticsPageAll(),
    ),
    GoRoute(
      path: '/ReportPage',
      builder: (context, state) => ReportPage(),
    ),
    GoRoute(
      path: '/ProfilePage',
      builder: (context, state) => ProfilePage(),
    ),
    GoRoute(
      path: '/ReportsPage',
      builder: (context, state) => const ReportsPage(),
    ),
    GoRoute(
      path: '/Report1Page',
      builder: (context, state) => const Report1Page(),
    ),
  ],
);
