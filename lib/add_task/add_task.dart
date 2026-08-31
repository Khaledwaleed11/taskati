import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../validator/app_validate.dart';
import '../widgets/custom_field.dart';

class AddTask extends StatefulWidget {
  final dynamic taskKey;
  final String userEmail;

  const AddTask({super.key, this.taskKey, required this.userEmail});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final TextEditingController taskController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final Box taskBox = Hive.box("myTask");

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String selectedPriority = "Medium";

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();

    if (widget.taskKey != null) {
      final data = taskBox.get(widget.taskKey);

      if (data != null) {
        taskController.text = data["task"]?.toString() ?? "";

        descriptionController.text = data["description"]?.toString() ?? "";

        selectedPriority = data["priority"]?.toString() ?? "Medium";
        if (data["date"] != null) {
          try {
            selectedDate = DateTime.parse(data["date"].toString());
          } catch (_) {
            selectedDate = null;
          }
        }
        if (data["hour"] != null && data["minute"] != null) {
          selectedTime = TimeOfDay(
            hour: int.tryParse(data["hour"].toString()) ?? 0,
            minute: int.tryParse(data["minute"].toString()) ?? 0,
          );
        }
      }
    }
  }

  Future<void> pickDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red;

      case "Medium":
        return Colors.orange;

      case "Low":
        return Colors.green;

      default:
        return Colors.orange;
    }
  }

  IconData getPriorityIcon(String priority) {
    switch (priority) {
      case "High":
        return Icons.priority_high;

      case "Medium":
        return Icons.remove;

      case "Low":
        return Icons.keyboard_arrow_down;

      default:
        return Icons.remove;
    }
  }

  Widget buildPriorityOption({required String priority}) {
    final bool isSelected = selectedPriority == priority;

    final Color color = getPriorityColor(priority);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPriority = priority;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.12)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(getPriorityIcon(priority), color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                priority,
                style: TextStyle(
                  color: isSelected ? color : null,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDateTimeSection() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: Colors.deepPurpleAccent,
                ),
              ),

              const SizedBox(width: 12),

              const Text(
                "Task Schedule",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              // DATE
              Expanded(
                child: InkWell(
                  onTap: pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.blue,
                          size: 28,
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Date",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          selectedDate == null
                              ? "Select Date"
                              : "${selectedDate!.day.toString().padLeft(2, '0')}/"
                                    "${selectedDate!.month.toString().padLeft(2, '0')}/"
                                    "${selectedDate!.year}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // TIME
              Expanded(
                child: InkWell(
                  onTap: pickTime,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.orange,
                          size: 28,
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Time",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          selectedTime == null
                              ? "Select Time"
                              : selectedTime!.format(context),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (selectedDate != null || selectedTime != null) ...[
            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: () {
                setState(() {
                  selectedDate = null;
                  selectedTime = null;
                });
              },
              icon: const Icon(Icons.clear, size: 18),
              label: const Text("Clear Schedule"),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> saveTask() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    final String taskTitle = taskController.text.trim();
    final String description = descriptionController.text.trim();
    final bool isEdit = widget.taskKey != null;
    if (isEdit) {
      final rawData = taskBox.get(widget.taskKey);
      if (rawData == null) {
        return;
      }
      final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
        rawData as Map,
      );
      data["task"] = taskTitle;
      data["description"] = description;
      data["priority"] = selectedPriority;

      data["userEmail"] = data["userEmail"]?.toString().isNotEmpty == true
          ? data["userEmail"]
          : widget.userEmail;
      data["date"] = selectedDate?.toIso8601String();
      data["hour"] = selectedTime?.hour;

      data["minute"] = selectedTime?.minute;

      await taskBox.put(widget.taskKey, data);
    } else {
      final Map<String, dynamic> data = {
        "task": taskTitle,
        "description": description,
        "isDone": false,
        "priority": selectedPriority,

        "userEmail": widget.userEmail,

        // DATE
        "date": selectedDate?.toIso8601String(),

        // TIME
        "hour": selectedTime?.hour,

        "minute": selectedTime?.minute,
      };
      await taskBox.add(data);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.taskKey != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Task" : "Add Task",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),

          child: Form(
            key: formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                const SizedBox(height: 10),

                // ICON
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_task_rounded,
                    size: 55,
                    color: Colors.deepPurpleAccent,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  isEdit ? "Update Your Task" : "Create New Task",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isEdit
                      ? "Make changes to your task"
                      : "Add a new task and stay organized",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.title_rounded,
                              size: 20,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Text(
                            "Task Title",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      CustomFormField(
                        keyboardType: TextInputType.text,
                        controller: taskController,
                        hintText: "Enter task title",
                        validator: AppValidator.validateTaskTitle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              size: 20,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      CustomFormField(
                        keyboardType: TextInputType.text,
                        controller: descriptionController,
                        hintText: "Describe your task",
                        validator: AppValidator.validateTaskDescription,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                buildDateTimeSection(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.flag_outlined,
                              size: 20,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Text(
                            "Priority",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          buildPriorityOption(priority: "High"),

                          const SizedBox(width: 10),

                          buildPriorityOption(priority: "Medium"),

                          const SizedBox(width: 10),

                          buildPriorityOption(priority: "Low"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: saveTask,
                    icon: Icon(
                      isEdit ? Icons.save_outlined : Icons.add_task_rounded,
                      size: 22,
                    ),

                    label: Text(
                      isEdit ? "Update Task" : "Add Task",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  isEdit
                      ? "Keep your tasks updated and organized."
                      : "Stay organized. One task at a time.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    taskController.dispose();
    descriptionController.dispose();

    super.dispose();
  }
}
