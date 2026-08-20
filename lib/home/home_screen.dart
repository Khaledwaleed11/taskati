import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../add_task/add_task.dart';
import '../done/done_tasks.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomeScreen> createState() => _HomeState();
}
class _HomeState extends State<HomeScreen> {
  var taskBox = Hive.box("myTask");
  var doneBox = Hive.box("doneTask");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        title: const Text("Taskati"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoneTasks(),
                ),
              ).then((value) {
                setState(() {});
              });
            },
            icon: const Icon(Icons.check_box),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.person_2_outlined,
            ),
          ),        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTask(),
            ),
          ).then((value) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: taskBox.length,
        itemBuilder: (BuildContext context, int index) {
          var taskKey = taskBox.keyAt(index);
          var taskData = taskBox.get(taskKey);
          return Card(
            child: ListTile(
              title: Text(
                taskData["task"],
              ),
              subtitle: Text(
                taskData["description"],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.deepPurpleAccent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTask(
                            taskKey: taskKey,
                          ),
                        ),
                      ).then((value) {
                        setState(() {});
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      taskBox.delete(taskKey);
                      setState(() {});
                    },
                  ),
                ],
              ),
              leading: Checkbox(
                value: taskData["isDone"] ?? false,
                onChanged: (value) async {
                  if (value == true) {
                    var doneTask = {
                      "task": taskData["task"],
                      "description": taskData["description"],
                      "isDone": true,
                    };
                    await doneBox.add(doneTask);
                    await taskBox.delete(taskKey);
                    setState(() {});
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}