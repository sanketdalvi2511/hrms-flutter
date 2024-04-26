import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EmployeeProvider()),
        ChangeNotifierProvider(create: (context) => LeaveProvider()),
        Provider<User>(
            create: (_) => User(name: 'Sanket Dalvi', role: 'HR Manager')),
      ],
      child: HRMSApp(),
    ),
  );
}

class HRMSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HRMS App',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.blueAccent, // Button color
            textStyle: TextStyle(color: Colors.white), // Text color
          ),
        ),
        appBarTheme: AppBarTheme(
          color: Colors.grey[900],
        ),
      ),
      home: HomePage(),
      routes: {
        '/leaveManagement': (context) => LeaveManagementPage(),
        '/employeeManagement': (context) => EmployeeManagementPage(),
        '/applyLeave': (context) => ApplyLeavePage(),
        '/addEmployee': (context) => AddEmployeePage(),
      },
    );
  }
}

class User {
  final String name;
  final String role;

  User({required this.name, required this.role});
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HRMS'),
        leading: AppMenuBar(),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/hrms.jpg', // Update with your image asset path
              fit: BoxFit.cover, // Image covers the entire background
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: _animation.value,
                  child: Text(
                    'Welcome to HRMS',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(
                          0xff273bae), // Ensure text is visible on the image
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/leaveManagement');
                  },
                  child: Text('Manage Leave'),
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/employeeManagement');
                  },
                  child: Text('Manage Employees'),
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    // Perform logout
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppMenuBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          child: ListTile(
            title: Text('Manage Leave'),
            onTap: () {
              Navigator.pushNamed(context, '/leaveManagement');
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Text('Manage Employees'),
            onTap: () {
              Navigator.pushNamed(context, '/employeeManagement');
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Text('Logout'),
            onTap: () {
              // Perform logout
            },
          ),
        ),
      ],
    );
  }
}

// Other classes remain the same as in the previous code snippet...

class LeaveManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Leave Management',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            LeaveList(),
            SizedBox(height: 20.0),
            ApplyLeaveButton(),
          ],
        ),
      ),
    );
  }
}

class LeaveList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LeaveProvider>(
      builder: (context, provider, _) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: provider.leaveRequests.length,
          itemBuilder: (context, index) {
            final leaveRequest = provider.leaveRequests[index];
            Color backgroundColor;
            if (leaveRequest.status == LeaveStatus.approved) {
              backgroundColor = Colors.green.withOpacity(0.3);
            } else if (leaveRequest.status == LeaveStatus.rejected) {
              backgroundColor = Colors.red.withOpacity(0.3);
            } else {
              backgroundColor = Colors.transparent;
            }
            return Container(
              color: backgroundColor,
              child: ListTile(
                title: Text(leaveRequest.employeeName),
                subtitle:
                    Text('${leaveRequest.startDate} - ${leaveRequest.endDate}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        provider.approveLeave(leaveRequest);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        provider.rejectLeave(leaveRequest);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ApplyLeaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/applyLeave');
      },
      child: Text('Apply Leave'),
    );
  }
}

class ApplyLeavePage extends StatefulWidget {
  @override
  _ApplyLeavePageState createState() => _ApplyLeavePageState();
}

class _ApplyLeavePageState extends State<ApplyLeavePage> {
  final TextEditingController _employeeNameController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply Leave'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _employeeNameController,
              decoration: InputDecoration(labelText: 'Employee Name'),
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text:
                            '${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                    decoration: InputDecoration(labelText: 'Start Date'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context, true);
                  },
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text:
                            '${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                    decoration: InputDecoration(labelText: 'End Date'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context, false);
                  },
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Provider.of<LeaveProvider>(context, listen: false).applyLeave(
                  LeaveRequest(
                    employeeName: _employeeNameController.text,
                    startDate: _startDate,
                    endDate: _endDate,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaveRequest {
  final String employeeName;
  final DateTime startDate;
  final DateTime endDate;
  LeaveStatus status;

  LeaveRequest(
      {required this.employeeName,
      required this.startDate,
      required this.endDate,
      this.status = LeaveStatus.pending});
}

enum LeaveStatus { pending, approved, rejected }

class LeaveProvider with ChangeNotifier {
  List<LeaveRequest> _leaveRequests = [
    LeaveRequest(
        employeeName: 'Sanket Dalvi',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 3))),
    LeaveRequest(
        employeeName: 'Amey Dhoke',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 2))),
  ];

  List<LeaveRequest> get leaveRequests => _leaveRequests;

  void approveLeave(LeaveRequest leaveRequest) {
    leaveRequest.status = LeaveStatus.approved;
    notifyListeners();
  }

  void rejectLeave(LeaveRequest leaveRequest) {
    leaveRequest.status = LeaveStatus.rejected;
    notifyListeners();
  }

  void applyLeave(LeaveRequest leaveRequest) {
    _leaveRequests.add(leaveRequest);
    notifyListeners();
  }
}

class EmployeeManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Employee Management',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            EmployeeTable(),
            SizedBox(height: 20.0),
            AddEmployeeButton(),
          ],
        ),
      ),
    );
  }
}

class EmployeeTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, provider, _) {
        return DataTable(
          columns: [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Position')),
            DataColumn(label: Text('Action')),
          ],
          rows: provider.employees.map((employee) {
            final nameController = TextEditingController(text: employee.name);
            final positionController =
                TextEditingController(text: employee.position);
            return DataRow(
              cells: [
                DataCell(
                  TextFormField(
                    controller: nameController,
                    onChanged: (value) => employee.name = value,
                  ),
                ),
                DataCell(
                  TextFormField(
                    controller: positionController,
                    onChanged: (value) => employee.position = value,
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      provider.removeEmployee(employee);
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class AddEmployeeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/addEmployee');
      },
      child: Text('Add Employee'),
    );
  }
}

class AddEmployeePage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Employee'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _positionController,
              decoration: InputDecoration(labelText: 'Position'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Provider.of<EmployeeProvider>(context, listen: false)
                    .addEmployee(
                  Employee(
                    name: _nameController.text,
                    position: _positionController.text,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class Employee {
  String name;
  String position;

  Employee({required this.name, required this.position});
}

class EmployeeProvider with ChangeNotifier {
  List<Employee> _employees = [
    Employee(name: 'Sanket Dalvi', position: 'Manager'),
    Employee(name: 'Amey Dhoke', position: 'Developer'),
    Employee(name: 'Amaan', position: 'Designer'),
    Employee(name: 'Ayush Rajpro', position: 'HR Manager'),
  ];

  List<Employee> get employees => _employees;

  void addEmployee(Employee employee) {
    _employees.add(employee);
    notifyListeners();
  }

  void removeEmployee(Employee employee) {
    _employees.remove(employee);
    notifyListeners();
  }
}
