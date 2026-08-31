import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../add_task/add_task.dart';

class TaskDetails extends StatefulWidget {
  final dynamic taskKey;
  final String userEmail;

  const TaskDetails({
    super.key,
    required this.taskKey,
    required this.userEmail,
  });

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  late final Box taskBox;

  @override
  void initState() {
    super.initState();

    taskBox = Hive.box("myTask");
  }

  String formatDate(String date) {
    if (date.isEmpty) {
      return "No date selected";
    }

    try {
      final parsedDate = DateTime.parse(date);

      return "${parsedDate.day.toString().padLeft(2, '0')}/"
          "${parsedDate.month.toString().padLeft(2, '0')}/"
          "${parsedDate.year}";
    } catch (_) {
      return "No date selected";
    }
  }

  String formatTime(int? hour, int? minute) {
    if (hour == null || minute == null) {
      return "No time selected";
    }

    final time = TimeOfDay(hour: hour, minute: minute);

    return time.format(context);
  }

  String getPriority(Map<dynamic, dynamic>? taskData) {
    final value = taskData?["priority"];

    if (value == null || value.toString().isEmpty) {
      return "Medium";
    }

    return value.toString();
  }

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.red;

      case "low":
        return Colors.green;

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

      default:
        return Icons.remove_rounded;
    }
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 40),
          title: const Text("Delete Task?", textAlign: TextAlign.center),
          content: const Text(
            "Are you sure you want to delete this task? "
            "This action cannot be undone.",
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
                await taskBox.delete(widget.taskKey);

                if (!mounted) return;

                Navigator.pop(dialogContext);
                Navigator.pop(context);
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

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPriorityCard(String priority) {
    final color = getPriorityColor(priority);
    final icon = getPriorityIcon(priority);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Priority",
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  priority,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              priority.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: taskBox.listenable(),
      builder: (context, box, child) {
        final taskData = box.get(widget.taskKey);
        if (taskData == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Task Details"),
              centerTitle: true,
            ),
            body: const Center(
              child: Text(
                "Task not found or deleted.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        final Map<dynamic, dynamic> dataMap = Map<dynamic, dynamic>.from(
          taskData,
        );

        final String taskTitle = dataMap["task"]?.toString() ?? "";

        final String description = dataMap["description"]?.toString() ?? "";

        final String priority = getPriority(dataMap);
        final String date = dataMap["date"]?.toString() ?? "";

        final int? hour = dataMap["hour"] != null
            ? int.tryParse(dataMap["hour"].toString())
            : null;

        final int? minute = dataMap["minute"] != null
            ? int.tryParse(dataMap["minute"].toString())
            : null;

        final Color priorityColor = getPriorityColor(priority);
        final IconData priorityIcon = getPriorityIcon(priority);
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Task Details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              // EDIT
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTask(
                        taskKey: widget.taskKey,
                        userEmail: widget.userEmail,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                tooltip: "Edit",
              ),
              IconButton(
                onPressed: showDeleteDialog,
                icon: const Icon(Icons.delete_outline),
                tooltip: "Delete",
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurpleAccent.withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.task_alt,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "Task",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        taskTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // PRIORITY BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(priorityIcon, color: Colors.white, size: 15),
                            const SizedBox(width: 4),
                            Text(
                              "$priority Priority",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Task Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                buildInfoCard(
                  icon: Icons.description_outlined,
                  title: "Description",
                  value: description.isEmpty
                      ? "No description available"
                      : description,
                  color: Colors.deepPurpleAccent,
                ),
                buildPriorityCard(priority),
                buildInfoCard(
                  icon: Icons.calendar_month_rounded,
                  title: "Due Date",
                  value: formatDate(date),
                  color: Colors.blue,
                ),
                buildInfoCard(
                  icon: Icons.access_time_rounded,
                  title: "Due Time",
                  value: formatTime(hour, minute),
                  color: Colors.orange,
                ),
                buildInfoCard(
                  icon: Icons.pending_actions,
                  title: "Status",
                  value: "Pending",
                  color: Colors.orange,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTask(
                            taskKey: widget.taskKey,
                            userEmail: widget.userEmail,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text(
                      "Edit Task",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: showDeleteDialog,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text(
                      "Delete Task",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Center(
                  child: Text(
                    "Taskati",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Center(
                  child: Text(
                    "Manage your tasks. Stay organized.",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }
}
