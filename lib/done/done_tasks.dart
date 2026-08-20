import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DoneTasks extends StatefulWidget {
  const DoneTasks({super.key});

  @override
  State<DoneTasks> createState() => _DoneTasksState();
}

class _DoneTasksState extends State<DoneTasks> {
  var doneBox = Hive.box("doneTask");
  var myTaskBox = Hive.box("myTask");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        title: const Text("Done Tasks"),
        centerTitle: true,
      ),

      body: ListView.builder(
        itemCount: doneBox.length,

        itemBuilder: (BuildContext context, int index) {
          var taskData = doneBox.getAt(index);

          return Card(
            child: ListTile(
              title: Text(taskData["task"]),

              subtitle: Text(taskData["description"]),

              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),

                onPressed: () {
                  doneBox.deleteAt(index);

                  setState(() {});
                },
              ),

              leading: Checkbox(
                value: true,
                onChanged: (value) async {
                  if (value == false) {
                    var taskData = doneBox.getAt(index);

                    var undoneTask = {
                      "task": taskData["task"],
                      "description": taskData["description"],
                      "isDone": false,
                    };

                    await myTaskBox.add(undoneTask);

                    await doneBox.deleteAt(index);

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
