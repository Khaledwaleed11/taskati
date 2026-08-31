import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DoneTasks extends StatefulWidget {
  final String userEmail;

  const DoneTasks({super.key, required this.userEmail});

  @override
  State<DoneTasks> createState() => _DoneTasksState();
}

class _DoneTasksState extends State<DoneTasks> {
  late final Box doneBox;
  late final Box myTaskBox;

  @override
  void initState() {
    super.initState();

    doneBox = Hive.box("doneTask");
    myTaskBox = Hive.box("myTask");
  }

  String formatDate(String date) {
    if (date.isEmpty) {
      return "No date";
    }

    try {
      final parsedDate = DateTime.parse(date);

      return "${parsedDate.day.toString().padLeft(2, '0')}/"
          "${parsedDate.month.toString().padLeft(2, '0')}/"
          "${parsedDate.year}";
    } catch (_) {
      return "No date";
    }
  }

  String formatTime(dynamic hour, dynamic minute) {
    if (hour == null || minute == null) {
      return "No time";
    }

    final int? parsedHour = int.tryParse(hour.toString());
    final int? parsedMinute = int.tryParse(minute.toString());

    if (parsedHour == null || parsedMinute == null) {
      return "No time";
    }

    final time = TimeOfDay(hour: parsedHour, minute: parsedMinute);

    return time.format(context);
  }

  bool isUserTask(Map<dynamic, dynamic> taskData) {
    final String taskEmail =
        taskData["userEmail"]?.toString().trim().toLowerCase() ?? "";

    final String currentEmail = widget.userEmail.trim().toLowerCase();

    return taskEmail == currentEmail;
  }

  List<dynamic> getUserDoneTaskKeys() {
    return doneBox.keys.where((key) {
      final rawData = doneBox.get(key);

      if (rawData == null || rawData is! Map) {
        return false;
      }

      final taskData = Map<dynamic, dynamic>.from(rawData);

      return isUserTask(taskData);
    }).toList();
  }

  void showDeleteDialog(dynamic taskKey) {
    showDialog(
      context: context,
      builder: (dialogContext) {
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
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await doneBox.delete(taskKey);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);
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

  Future<void> moveToPending(dynamic taskKey) async {
    final rawData = doneBox.get(taskKey);

    if (rawData == null || rawData is! Map) {
      return;
    }

    final taskData = Map<dynamic, dynamic>.from(rawData);

    final undoneTask = {
      "task": taskData["task"] ?? "",
      "description": taskData["description"] ?? "",
      "priority": taskData["priority"] ?? "Medium",
      "isDone": false,

      "userEmail": taskData["userEmail"] ?? widget.userEmail,

      // DATE & TIME
      "date": taskData["date"],
      "hour": taskData["hour"],
      "minute": taskData["minute"],
    };
    await myTaskBox.add(undoneTask);

    await doneBox.delete(taskKey);
  }

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.red;

      case "low":
        return Colors.green;

      case "medium":
      default:
        return Colors.orange;
    }
  }

  IconData getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Icons.priority_high_rounded;

      case "low":
        return Icons.keyboard_arrow_down_rounded;

      case "medium":
      default:
        return Icons.remove_rounded;
    }
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

      body: ValueListenableBuilder<Box>(
        valueListenable: doneBox.listenable(),

        builder: (context, box, child) {
          final userTaskKeys = getUserDoneTaskKeys();

          if (userTaskKeys.isEmpty) {
            return buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),

            itemCount: userTaskKeys.length,

            itemBuilder: (context, index) {
              final taskKey = userTaskKeys[index];

              final rawData = box.get(taskKey);

              if (rawData == null || rawData is! Map) {
                return const SizedBox.shrink();
              }

              final taskData = Map<dynamic, dynamic>.from(rawData);

              return buildDoneTaskCard(taskKey: taskKey, taskData: taskData);
            },
          );
        },
      ),
    );
  }

  Widget buildDoneTaskCard({
    required dynamic taskKey,
    required Map<dynamic, dynamic> taskData,
  }) {
    final String taskTitle = (taskData["task"] ?? "").toString();

    final String description = (taskData["description"] ?? "").toString();

    final String priority = (taskData["priority"] ?? "Medium").toString();

    final String date = taskData["date"]?.toString() ?? "";

    final dynamic hour = taskData["hour"];

    final dynamic minute = taskData["minute"];

    final Color priorityColor = getPriorityColor(priority);

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
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Checkbox(
              value: true,

              activeColor: Colors.green,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),

              onChanged: (value) async {
                if (value == false) {
                  await moveToPending(taskKey);
                }
              },
            ),

            const SizedBox(width: 5),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    taskTitle,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),

                  const SizedBox(height: 6),
                  if (description.isNotEmpty)
                    Text(
                      description,

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

                  Wrap(
                    spacing: 7,
                    runSpacing: 7,

                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: const Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Colors.green,
                            ),

                            SizedBox(width: 4),

                            Text(
                              "Completed",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            Icon(
                              getPriorityIcon(priority),
                              size: 14,
                              color: priorityColor,
                            ),

                            const SizedBox(width: 4),

                            Text(
                              priority,
                              style: TextStyle(
                                color: priorityColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.12),

                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 14,
                              color: Colors.blue,
                            ),

                            const SizedBox(width: 4),

                            Text(
                              formatDate(date),

                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatTime(hour, minute),
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                showDeleteDialog(taskKey);
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
