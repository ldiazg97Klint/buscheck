import 'package:BusGo/domain/signals/tickets_signals/tickets_signal.dart';
import 'package:BusGo/ui/pages/PrinterPage/reports/report1/report1Page.dart';
import 'package:BusGo/ui/pages/PrinterPage/reports/report2/report2Page.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  bool _isButtonEnabled = true; // El botón está habilitado por defecto

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 2) {
          floatingActionButtonSignal.value = false;
        } else {
          floatingActionButtonSignal.value = true;
        }
        _pageController.jumpToPage(_tabController.index);
      }
    });
  }

  // Métodos para cada pestaña

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Padding(
            padding: EdgeInsets.all(0),
            child: Text(
              "Reportes",
              style: TextStyle(color: Colors.white),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Container(
                color: Colors.orange,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TabBar(
                      indicatorColor: const Color(0xFF42A5F5),
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicator: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      labelColor: Colors.white,
                      labelStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w200),
                      unselectedLabelColor: Colors.white,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 3),
                      tabs: [
                        _buildTab("Resumen Diario"),
                        _buildTab("Resumen de Viajes"),
                        _buildTab("Tickets"),
                        // _buildTab("Resumen Total"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            Report1Page(),
            Report2Page(),
          ],
        ));
  }

  Widget _buildTab(String title) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
