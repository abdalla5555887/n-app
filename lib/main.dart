
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models.dart';
import 'logic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(NabatchyApp());
}

class NabatchyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام إدارة النبطشيات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Segoe UI',
      ),
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [Locale("ar", "AE")],
      locale: Locale("ar", "AE"),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  List<ShiftAssignment> currentAssignments = [];
  List<String> workers = ScheduleLogic.defaultWorkers;
  List<String> selectedForBulk = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String? savedWorkers = prefs.getString('workers');
      if (savedWorkers != null) {
        workers = List<String>.from(json.decode(savedWorkers));
      }
      
      String key = 'shifts_${selectedYear}_${selectedMonth}';
      String? savedShifts = prefs.getString(key);
      if (savedShifts != null) {
        Iterable l = json.decode(savedShifts);
        currentAssignments = List<ShiftAssignment>.from(l.map((model) => ShiftAssignment.fromJson(model)));
      } else {
        currentAssignments = ScheduleLogic.generateMonthDays(selectedYear, selectedMonth);
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workers', json.encode(workers));
    String key = 'shifts_${selectedYear}_${selectedMonth}';
    await prefs.setString(key, json.encode(currentAssignments.map((e) => e.toJson()).toList()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الحفظ بنجاح')));
  }

  void _updateTable() {
    setState(() {
      currentAssignments = ScheduleLogic.generateMonthDays(selectedYear, selectedMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('نظام إدارة النبطشيات - Nabatchy Pro'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.print), onPressed: () {}),
          IconButton(icon: Icon(Icons.save), onPressed: _saveData),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildSetupBar(),
              SizedBox(height: 10),
              _buildMainTable(),
              SizedBox(height: 20),
              _buildControlsPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DropdownButton<int>(
              value: selectedMonth,
              items: List.generate(12, (index) => DropdownMenuItem(
                value: index + 1,
                child: Text('شهر ${index + 1}'),
              )),
              onChanged: (val) {
                setState(() {
                  selectedMonth = val!;
                  _updateTable();
                });
              },
            ),
            Container(
              width: 80,
              child: TextField(
                decoration: InputDecoration(labelText: 'السنة'),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: selectedYear.toString()),
                onSubmitted: (val) {
                  setState(() {
                    selectedYear = int.parse(val);
                    _updateTable();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTable() {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: {
        0: FixedColumnWidth(40),
        1: FixedColumnWidth(70),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: [
            _tableCell('تاريخ', isHeader: true),
            _tableCell('يوم', isHeader: true),
            _tableCell('8ص - 2ظ', isHeader: true),
            _tableCell('2ظ - 8م', isHeader: true),
            _tableCell('8م - 8ص', isHeader: true),
          ],
        ),
        ...currentAssignments.map((day) => TableRow(
          children: [
            _tableCell(day.date.split('-').last),
            _tableCell(day.dayName),
            _buildShiftCell(day, 'morning'),
            _buildShiftCell(day, 'evening'),
            _buildShiftCell(day, 'night'),
          ],
        )).toList(),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildShiftCell(ShiftAssignment day, String shiftType) {
    List<String> assigned;
    if (shiftType == 'morning') assigned = day.morningWorkers;
    else if (shiftType == 'evening') assigned = day.eveningWorkers;
    else assigned = day.nightWorkers;

    return InkWell(
      onTap: () {
        // logic to add selected workers to this cell
        setState(() {
          if (selectedForBulk.isNotEmpty) {
            assigned.addAll(selectedForBulk.where((w) => !assigned.contains(w)));
          }
        });
      },
      onLongPress: () {
        setState(() {
          assigned.clear();
        });
      },
      child: Container(
        constraints: BoxConstraints(minHeight: 30),
        padding: EdgeInsets.all(2),
        child: Text(
          assigned.join('\n'),
          style: TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildControlsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('الأسماء المتاحة (اضغط للاختيار ثم اضغط على خلية في الجدول):', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 5,
          children: workers.map((worker) => ChoiceChip(
            label: Text(worker),
            selected: selectedForBulk.contains(worker),
            onSelected: (selected) {
              setState(() {
                if (selected) selectedForBulk.add(worker);
                else selectedForBulk.remove(worker);
              });
            },
          )).toList(),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedForBulk.clear();
            });
          }, 
          child: Text('إلغاء تحديد الكل')
        ),
      ],
    );
  }
}
