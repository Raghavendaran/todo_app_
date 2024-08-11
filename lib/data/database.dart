import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  List toDolist = [];
  final _myBox = Hive.box('mybox');

  void createInitialData() {
    toDolist = [
      ["Make tutorial", false],
      ["Do exercise", false],
    ];
  }

  void loadData() {
    toDolist = _myBox.get('TODOLIST');
  }

  void updateBase() {
    _myBox.put('TODOLIST', toDolist);
  }
}
