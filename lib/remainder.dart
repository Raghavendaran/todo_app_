import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TickBoxPage extends StatefulWidget {
  const TickBoxPage({Key? key}) : super(key: key);

  @override
  _TickBoxPageState createState() => _TickBoxPageState();
}

class _TickBoxPageState extends State<TickBoxPage> {
  late PageController _pageController;
  int _currentMonthIndex = DateTime.now().month - 1;
  int _currentYear = DateTime.now().year;
  DateTime? _selectedDate;

  final Map<DateTime, List<String>> _reminders = {};

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentMonthIndex);
    _loadReminders();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPreviousMonth() {
    if (_pageController.hasClients) {
      setState(() {
        if (_currentMonthIndex > 0) {
          _currentMonthIndex--;
        } else {
          _currentMonthIndex = 11;
          _currentYear--;
        }
        _pageController.jumpToPage(_currentMonthIndex);
      });
    }
  }

  void _goToNextMonth() {
    if (_pageController.hasClients) {
      setState(() {
        if (_currentMonthIndex < 11) {
          _currentMonthIndex++;
        } else {
          _currentMonthIndex = 0;
          _currentYear++;
        }
        _pageController.jumpToPage(_currentMonthIndex);
      });
    }
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersString = prefs.getString('reminders') ?? '{}';
    final Map<String, dynamic> decodedReminders = json.decode(remindersString);
    setState(() {
      _reminders.clear();
      decodedReminders.forEach((key, value) {
        final date = DateTime.parse(key);
        final remindersList = List<String>.from(value);
        _reminders[date] = remindersList;
      });
    });
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersString = json.encode(_reminders.map((key, value) => MapEntry(key.toIso8601String(), value)));
    await prefs.setString('reminders', remindersString);
  }

  void _showReminders(DateTime date) async {
    setState(() {
      _selectedDate = date;
    });

    final reminders = _reminders[date] ?? [];

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reminders for ${date.day}/${date.month}/${date.year}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...reminders.map((reminder) => ListTile(
                title: Text(reminder),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _reminders[date]?.remove(reminder);
                      if (_reminders[date]?.isEmpty ?? false) {
                        _reminders.remove(date);
                      }
                    });
                    _saveReminders();
                    Navigator.of(context).pop();
                  },
                ),
              )),
              ListTile(
                title: Text('Add Reminder'),
                onTap: () => _addReminder(date),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addReminder(DateTime date) async {
    final TextEditingController _reminderController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Reminder'),
          content: TextField(
            controller: _reminderController,
            decoration: InputDecoration(hintText: 'Enter your reminder'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_reminderController.text.isNotEmpty) {
                    if (_reminders[date] == null) {
                      _reminders[date] = [];
                    }
                    _reminders[date]!.add(_reminderController.text);
                    _saveReminders();
                  }
                });
                Navigator.of(context).pop();
                _showReminders(date);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Reminder', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _goToPreviousMonth,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${months[_currentMonthIndex]} $_currentYear',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: _goToNextMonth,
                ),
              ],
            ),
          ),
          Container(
            height: 80,
            color: Colors.black,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 12,
              itemBuilder: (context, monthIndex) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _getDaysInMonth(monthIndex + 1, _currentYear),
                  itemBuilder: (context, dayIndex) {
                    DateTime day = DateTime(_currentYear, monthIndex + 1, dayIndex + 1);
                    bool isToday = now.year == day.year && now.month == day.month && now.day == day.day;

                    return GestureDetector(
                      onTap: () => _showReminders(day),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isToday ? Color(0xffE3FA53) : Colors.black,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${dayIndex + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isToday ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: _reminders.isNotEmpty
                ? ListView(
                    children: _reminders.entries.map((entry) {
                      return ListTile(
                        title: Text(
                          '${entry.value.join(", ")}',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${entry.key.day}/${entry.key.month}/${entry.key.year}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _reminders.remove(entry.key);
                              _saveReminders();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  )
                : Center(
                    child: Text(
                      'No Reminders for Today',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  int _getDaysInMonth(int month, int year) {
    if (month == 2) {
      if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
        return 29; // Leap year
      } else {
        return 28;
      }
    } else if (month == 4 || month == 6 || month == 9 || month == 11) {
      return 30;
    } else {
      return 31;
    }
  }
}
