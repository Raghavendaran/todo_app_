import 'dart:math';
import 'package:ToDo_App/favorite_page.dart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ToDo_App/data/database.dart';
import 'package:ToDo_App/utli/add_task.dart';
import 'package:ToDo_App/utli/main_interface.dart';
import 'package:ToDo_App/remainder.dart';
import 'package:ToDo_App/stop_watch.dart'; // Adjust the path if necessary

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('mybox');
  late ToDoDataBase db;

  @override
  void initState() {
    db = ToDoDataBase();
    if (_myBox.get('TODOLIST') == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    super.initState();
  }

  final _controller = TextEditingController();

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDolist[index][1] = !db.toDolist[index][1];
    });
    db.updateBase();
  }

  void saveNewTask() {
    setState(() {
      String taskText = _controller.text;
      // Remove unwanted characters
      taskText = taskText.replaceAll(RegExp(r'[^\w\s]'), '');
      db.toDolist.add([taskText, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateBase();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      db.toDolist.removeAt(index);
    });
    db.updateBase();
  }

  int calculateFinishedTasks() {
    return db.toDolist.where((task) => task[1]).length;
  }

  int calculateTotalTasks() {
    return db.toDolist.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('To Do', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff0000),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff104CFD),
        onPressed: createNewTask,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: db.toDolist.length,
        itemBuilder: (context, index) {
          return TodoTile(
            taskName: db.toDolist[index][0],
            taskCompleted: db.toDolist[index][1],
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 10, 2, 8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Reminder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Stopwatch',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompletionProgressPage(
                    finishedTasks: calculateFinishedTasks,
                    totalTasks: calculateTotalTasks,
                  ),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TickBoxPage(),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritePage(),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StopwatchPage(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}

class CompletionProgressPage extends StatelessWidget {
  final int Function() finishedTasks;
  final int Function() totalTasks;

  const CompletionProgressPage({
    Key? key,
    required this.finishedTasks,
    required this.totalTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int finished = finishedTasks();
    int total = totalTasks();
    double percentage = (finished / (total == 0 ? 1 : total)) * 100;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Tasks', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff),
      ),
      body: Column(
        children: [
          SizedBox(height: 26),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 300,
              width: 600,
              decoration: BoxDecoration(
                color: Color(0xff131418),
                borderRadius: BorderRadius.circular(70),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ProgressCircleWidget(
                        finishedTasks: finished,
                        totalTasks: total,
                      ),
                      SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressCircleWidget extends StatelessWidget {
  final int finishedTasks;
  final int totalTasks;

  const ProgressCircleWidget({
    Key? key,
    required this.finishedTasks,
    required this.totalTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: CustomPaint(
              painter: CircleProgressPainterWidget(
                progress: finishedTasks / (totalTasks == 0 ? 1 : totalTasks),
              ),
              size: Size(250, 250),
            ),
          ),
          Center(
            child: Text(
              '$finishedTasks / $totalTasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleProgressPainterWidget extends CustomPainter {
  final double progress;

  CircleProgressPainterWidget({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // White color for finished part
    paint.color = Colors.white;

    double radius = size.width / 2;
    double arcAngle = 2 * progress * pi;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(radius, radius),
        radius: radius - paint.strokeWidth / 2,
      ),
      -pi / 2,
      arcAngle,
      false,
      paint,
    );

    // Light Orange color for unfinished part
    paint.color = Color(0xFFF26262A);

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(radius, radius),
        radius: radius - paint.strokeWidth / 2,
      ),
      arcAngle - pi / 2,
      2 * pi * (1 - progress),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
