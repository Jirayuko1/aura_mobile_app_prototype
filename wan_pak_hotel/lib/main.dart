import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/staff_tasks_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Hotel Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Change to StaffTasksScreen() to see the staff view
      home: const RootNavigator(),
    );
  }
}

// A simple wrapper to easily switch between User and Staff views for demo
class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  bool _isStaffView = false;

  void _toggleView() {
    setState(() {
      _isStaffView = !_isStaffView;
    });
  }

  @override
  Widget build(BuildContext context) {
    // We pass a way to toggle back and forth through a floating button for easy testing
    return Scaffold(
      body: _isStaffView ? const StaffTasksScreen() : const HomeScreen(),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _toggleView,
        backgroundColor: Colors.black,
        child: Icon(
          _isStaffView ? Icons.person : Icons.badge,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
