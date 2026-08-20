import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../widgets/custom_field.dart';

class AddTask extends StatefulWidget {
  final dynamic taskKey;

  const AddTask({
    super.key,
    this.taskKey,
  });

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
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        title: Text(
          isEdit ? "Edit Task" : "Add Task",
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Form(
          key: formKey,

          child: Column(

            children: [

              const SizedBox(height: 20),

              CustomFormField(
                keyboardType: TextInputType.text,
                controller: taskController,
                hintText: 'Enter task title',
              ),

              const SizedBox(height: 20),

              CustomFormField(
                keyboardType: TextInputType.text,
                controller: descriptionController,
                hintText: 'Describe your task',
              ),

              const SizedBox(height: 20),

              ElevatedButton(
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

                style: ElevatedButton.styleFrom(
                  fixedSize: Size(
                    MediaQuery.of(context).size.width,
                    40,
                  ),
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                ),

                child: Text(
                  isEdit ? "Update Task" : "Add Task",
                ),
              ),
            ],
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