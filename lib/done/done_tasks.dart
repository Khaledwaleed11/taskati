import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DoneTasks extends StatefulWidget {
  const DoneTasks({super.key});

  @override
  State<DoneTasks> createState() => _DoneTasksState();
}

class _DoneTasksState extends State<DoneTasks> {
  final doneBox = Hive.box("doneTask");
  final myTaskBox = Hive.box("myTask");

  void showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 40),

          title: const Text("Delete Task?", textAlign: TextAlign.center),

          content: const Text(
            "Are you sure you want to permanently delete "
            "this completed task?",
            textAlign: TextAlign.center,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                await doneBox.deleteAt(index);

                if (!context.mounted) return;

                Navigator.pop(context);

                setState(() {});
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          "Done Tasks",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: doneBox.isEmpty
          ? buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: doneBox.length,

              itemBuilder: (BuildContext context, int index) {
                final taskData = doneBox.getAt(index);

                return buildDoneTaskCard(taskData: taskData, index: index);
              },
            ),
    );
  }

  Widget buildDoneTaskCard({required dynamic taskData, required int index}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),

            blurRadius: 12,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Row(
          children: [
            Checkbox(
              value: true,

              activeColor: Colors.green,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),

              onChanged: (value) async {
                if (value == false) {
                  final task = doneBox.getAt(index);

                  final undoneTask = {
                    "task": task["task"],
                    "description": task["description"],
                    "isDone": false,
                  };

                  await myTaskBox.add(undoneTask);

                  await doneBox.deleteAt(index);

                  setState(() {});
                }
              },
            ),

            const SizedBox(width: 5),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    taskData["task"],

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,

                      decoration: TextDecoration.lineThrough,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    taskData["description"],

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 14,

                      color: Colors.grey.shade600,

                      height: 1.3,

                      decoration: TextDecoration.lineThrough,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),

                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: const Text(
                      "Completed",

                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              onPressed: () {
                showDeleteDialog(index);
              },

              icon: const Icon(
                Icons.delete_outline,
                size: 22,
                color: Colors.red,
              ),

              tooltip: "Delete",
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.10),

                shape: BoxShape.circle,
              ),

              child: const Icon(Icons.task_alt, size: 70, color: Colors.green),
            ),

            const SizedBox(height: 25),

            const Text(
              "No Completed Tasks",
              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Complete your tasks\n"
              "and they will appear here.",
              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
