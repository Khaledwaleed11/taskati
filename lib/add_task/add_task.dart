import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../validator/app_validate.dart';
import '../widgets/custom_field.dart';

class AddTask extends StatefulWidget {
  final dynamic taskKey;

  const AddTask({super.key, this.taskKey});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController taskController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  var task = Hive.box("myTask");
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.taskKey != null) {
      var data = task.get(widget.taskKey);
      taskController.text = data["task"];
      descriptionController.text = data["description"];
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.taskKey != null;

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
                        hintText: 'Enter task title',
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
                        hintText: 'Describe your task',
                        validator: AppValidator.validateTaskDescription,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (isEdit) {
                          var data = task.get(widget.taskKey);
                          data["task"] = taskController.text;
                          data["description"] = descriptionController.text;
                          task.put(widget.taskKey, data);
                        } else {
                          var data = {
                            "task": taskController.text,
                            "description": descriptionController.text,
                            "isDone": false,
                          };
                          task.add(data);
                        }
                        Navigator.pop(context);
                      }
                    },
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
