import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../add_task/add_task.dart';
import '../done/done_tasks.dart';
import '../profile/profile_screen.dart';
import '../theme/theme_controller.dart';

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

  final searchController = TextEditingController();

  String searchText = "";

  void showDeleteDialog({required dynamic taskKey}) {
    showDialog(
      context: context,
      builder: (context) {
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
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await taskBox.delete(taskKey);

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

  int get pendingTasks => taskBox.length;

  int get completedTasks => doneBox.length;

  List<dynamic> get filteredTaskKeys {
    final keys = taskBox.keys.toList();

    if (searchText.trim().isEmpty) {
      return keys;
    }

    return keys.where((key) {
      final taskData = taskBox.get(key);

      final task = taskData["task"].toString().toLowerCase();

      final description = taskData["description"].toString().toLowerCase();

      final search = searchText.trim().toLowerCase();

      return task.contains(search) || description.contains(search);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredKeys = filteredTaskKeys;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Taskati"),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, child) {
              return IconButton(
                onPressed: () {
                  ThemeController.toggleTheme();
                },
                icon: Icon(
                  mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: mode == ThemeMode.dark ? "Light Mode" : "Dark Mode",
              );
            },
          ),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DoneTasks()),
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
              ).then((value) {
                setState(() {});
              });
            },
            icon: const Icon(Icons.person_2_outlined),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTask()),
          ).then((value) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 15, 12, 5),
            child: Row(
              children: [
                // PENDING
                Expanded(
                  child: buildCounterCard(
                    icon: Icons.pending_actions,
                    title: "Pending",
                    count: pendingTasks,
                  ),
                ),

                const SizedBox(width: 12),

                // DONE
                Expanded(
                  child: buildCounterCard(
                    icon: Icons.task_alt,
                    title: "Done",
                    count: completedTasks,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchText = "";
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Colors.deepPurpleAccent,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),

          Expanded(
            child: taskBox.isEmpty
                ? buildEmptyState()
                : filteredKeys.isEmpty
                ? buildNoSearchResult()
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredKeys.length,
                    itemBuilder: (BuildContext context, int index) {
                      var taskKey = filteredKeys[index];
                      var taskData = taskBox.get(taskKey);

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
                                value: taskData["isDone"] ?? false,
                                activeColor: Colors.deepPurpleAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
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
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "Pending",
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddTask(taskKey: taskKey),
                                        ),
                                      ).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 21,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    tooltip: "Edit",
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      showDeleteDialog(taskKey: taskKey);
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 21,
                                      color: Colors.red,
                                    ),
                                    tooltip: "Delete",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildCounterCard({
    required IconData icon,
    required String title,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.deepPurpleAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 3),
                Text(
                  "$count",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                color: Colors.deepPurpleAccent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt,
                size: 70,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "No Tasks Yet",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Start adding your tasks\nand stay organized!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddTask()),
                ).then((value) {
                  setState(() {});
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Task"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNoSearchResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 70,
              color: Colors.deepPurpleAccent.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Tasks Found",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Try searching with another word.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
