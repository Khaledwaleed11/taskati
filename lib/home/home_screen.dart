import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../add_task/add_task.dart';
import '../done/done_tasks.dart';
import '../profile/profile_screen.dart';
import '../task_details/task_details.dart';
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Box taskBox;
  late final Box doneBox;
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<String> searchTextNotifier = ValueNotifier("");
  final GlobalKey pendingTasksKey = GlobalKey();
  final ScrollController taskScrollController = ScrollController();

  Widget buildTaskSchedule(Map<dynamic, dynamic> taskData) {
    final date = taskData["date"];
    final hour = taskData["hour"];
    final minute = taskData["minute"];

    if (date == null && hour == null && minute == null) {
      return const SizedBox.shrink();
    }

    DateTime? taskDate;

    if (date != null) {
      try {
        taskDate = DateTime.parse(date.toString());
      } catch (_) {}
    }

    String dateText = "";

    if (taskDate != null) {
      dateText =
          "${taskDate.day.toString().padLeft(2, '0')}/"
          "${taskDate.month.toString().padLeft(2, '0')}/"
          "${taskDate.year}";
    }

    String timeText = "";

    if (hour != null && minute != null) {
      final time = TimeOfDay(
        hour: int.tryParse(hour.toString()) ?? 0,
        minute: int.tryParse(minute.toString()) ?? 0,
      );

      timeText = time.format(context);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (dateText.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_month, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  dateText,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        if (timeText.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.10),
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
                  timeText,
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
    );
  }

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box("myTask");
    doneBox = Hive.box("doneTask");
    migrateOldTasks();
  }

  void resetSearch() {
    if (searchController.text.isNotEmpty ||
        searchTextNotifier.value.isNotEmpty) {
      searchController.clear();
      searchTextNotifier.value = "";
    }

    FocusManager.instance.primaryFocus?.unfocus();
  }

  bool isUserTask(Map<dynamic, dynamic> taskData) {
    final String taskEmail =
        taskData["userEmail"]?.toString().trim().toLowerCase() ?? "";

    final String currentEmail = widget.userEmail.trim().toLowerCase();

    return taskEmail == currentEmail;
  }

  List<dynamic> getUserTaskKeys(Box box) {
    return box.keys.where((key) {
      final rawData = box.get(key);

      if (rawData == null || rawData is! Map) {
        return false;
      }
      final taskData = Map<dynamic, dynamic>.from(rawData);
      return isUserTask(taskData);
    }).toList();
  }

  void goToPendingTasks() {
    resetSearch();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = pendingTasksKey.currentContext;

      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0.05,
        );
      }
    });
  }

  void goToCompletedTasks() {
    resetSearch();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoneTasks(userEmail: widget.userEmail),
      ),
    );
  }

  void showDeleteDialog({required dynamic taskKey}) {
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
                await taskBox.delete(taskKey);

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

  Future<void> markAsDone(
    dynamic taskKey,
    Map<dynamic, dynamic> taskData,
  ) async {
    final doneTask = {
      "task": taskData["task"] ?? "",
      "description": taskData["description"] ?? "",
      "priority": taskData["priority"] ?? "Medium",
      "isDone": true,
      "userEmail": widget.userEmail,
      "date": taskData["date"],
      "hour": taskData["hour"],
      "minute": taskData["minute"],
    };
    await doneBox.add(doneTask);

    await taskBox.delete(taskKey);
  }

  List<dynamic> getFilteredTaskKeys(Box box, String query) {
    final keys = getUserTaskKeys(box);

    if (query.trim().isEmpty) {
      return keys;
    }

    final search = query.trim().toLowerCase();

    return keys.where((key) {
      final rawData = box.get(key);

      if (rawData == null || rawData is! Map) {
        return false;
      }

      final taskData = Map<dynamic, dynamic>.from(rawData);

      final task = (taskData["task"] ?? "").toString().toLowerCase();

      final description = (taskData["description"] ?? "")
          .toString()
          .toLowerCase();

      final priority = (taskData["priority"] ?? "Medium")
          .toString()
          .toLowerCase();

      return task.contains(search) ||
          description.contains(search) ||
          priority.contains(search);
    }).toList();
  }

  String getPriority(Map<dynamic, dynamic>? taskData) {
    final priority = taskData?["priority"];

    if (priority == null || priority.toString().isEmpty) {
      return "Medium";
    }

    return priority.toString();
  }

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.red;

      case "medium":
        return Colors.orange;

      case "low":
        return Colors.green;

      default:
        return Colors.orange;
    }
  }

  IconData getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Icons.priority_high;

      case "medium":
        return Icons.remove;

      case "low":
        return Icons.keyboard_arrow_down;

      default:
        return Icons.remove;
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    }

    if (hour < 17) {
      return "Good Afternoon";
    }

    if (hour < 21) {
      return "Good Evening";
    }

    return "Good Night";
  }

  @override
  void dispose() {
    searchController.dispose();
    searchTextNotifier.dispose();
    taskScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,

        title: const Text(
          "Taskati",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

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

          // DONE TASKS
          IconButton(
            onPressed: goToCompletedTasks,

            icon: const Icon(Icons.check_box),

            tooltip: "Done Tasks",
          ),

          IconButton(
            onPressed: () {
              resetSearch();

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

            icon: const Icon(Icons.person_2_outlined),

            tooltip: "Profile",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          resetSearch();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTask(userEmail: widget.userEmail),
            ),
          );
        },

        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: taskBox.listenable(),

        builder: (context, pendingBox, child) {
          return ValueListenableBuilder<Box>(
            valueListenable: doneBox.listenable(),

            builder: (context, completedBox, child) {
              final int pendingCount = getUserTaskKeys(pendingBox).length;

              final int completedCount = getUserTaskKeys(completedBox).length;

              final int totalCount = pendingCount + completedCount;

              final double progress = totalCount == 0 ? 0 : completedCount / totalCount;

              final int highCount = getPriorityCount(pendingBox, "High");

              final int mediumCount = getPriorityCount(pendingBox, "Medium");

              final int lowCount = getPriorityCount(pendingBox, "Low");

              return ListView(
                controller: taskScrollController,

                physics: const BouncingScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(12, 15, 12, 90),

                children: [
                  buildGreetingCard(primaryColor: primaryColor),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: buildDashboardStatCard(
                          icon: Icons.task_alt_rounded,
                          title: "Total",
                          count: totalCount,
                          color: primaryColor,
                          onTap: null,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: buildDashboardStatCard(
                          icon: Icons.check_circle_outline,
                          title: "Completed",
                          count: completedCount,
                          color: Colors.green,
                          onTap: goToCompletedTasks,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: buildDashboardStatCard(
                          icon: Icons.pending_actions,
                          title: "Pending",
                          count: pendingCount,
                          color: Colors.orange,
                          onTap: goToPendingTasks,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildProgressCard(
                    progress: progress,
                    completedCount: completedCount,
                    totalCount: totalCount,
                    primaryColor: primaryColor,
                  ),

                  const SizedBox(height: 16),
                  buildPrioritySummary(
                    highCount: highCount,
                    mediumCount: mediumCount,
                    lowCount: lowCount,
                  ),

                  const SizedBox(height: 20),
                  Container(
                    key: pendingTasksKey,

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Your Tasks",

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (pendingCount > 0)
                          Text(
                            "$pendingCount Pending",

                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<String>(
                    valueListenable: searchTextNotifier,
                    builder: (context, searchText, child) {
                      return TextField(
                        controller: searchController,

                        onChanged: (value) {
                          searchTextNotifier.value = value;
                        },

                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),

                        cursorColor: primaryColor,

                        decoration: InputDecoration(
                          hintText: "Search tasks...",

                          hintStyle: TextStyle(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.45),
                          ),

                          prefixIcon: const Icon(Icons.search),

                          suffixIcon: searchText.isNotEmpty
                              ? IconButton(
                                  onPressed: resetSearch,
                                  icon: const Icon(Icons.clear),
                                )
                              : null,

                          filled: true,

                          fillColor: theme.cardColor,

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
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),
                  ValueListenableBuilder<String>(
                    valueListenable: searchTextNotifier,

                    builder: (context, query, child) {
                      final userTaskKeys = getUserTaskKeys(pendingBox);

                      if (userTaskKeys.isEmpty) {
                        return buildEmptyState();
                      }

                      final filteredKeys = getFilteredTaskKeys(
                        pendingBox,
                        query,
                      );

                      if (filteredKeys.isEmpty) {
                        return buildNoSearchResult();
                      }

                      return ListView.builder(
                        shrinkWrap: true,

                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: filteredKeys.length,

                        itemBuilder: (context, index) {
                          final taskKey = filteredKeys[index];

                          final rawData = pendingBox.get(taskKey);

                          if (rawData == null) {
                            return const SizedBox.shrink();
                          }

                          final taskData = Map<dynamic, dynamic>.from(
                            rawData as Map,
                          );

                          return buildTaskCard(
                            taskKey: taskKey,
                            taskData: taskData,
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget buildGreetingCard({required Color primaryColor}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "${getGreeting()},",

                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.userName,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  "Stay productive and get things done!",

                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.waving_hand_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDashboardStatCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    final card = Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),

      decoration: BoxDecoration(
        color: theme.cardColor,

        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(9),

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: color, size: 22),
          ),

          const SizedBox(height: 8),

          Text(
            "$count",

            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 2),

          Text(
            title,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.60),
              fontWeight: FontWeight.w500,
            ),
          ),

          if (onTap != null) ...[
            const SizedBox(height: 5),

            Icon(
              Icons.touch_app_outlined,
              size: 13,
              color: color.withValues(alpha: 0.55),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(17),

        child: card,
      ),
    );
  }

  Widget buildProgressCard({
    required double progress,
    required int completedCount,
    required int totalCount,
    required Color primaryColor,
  }) {
    final percentage = (progress * 100).round();

    return Container(
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

      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(Icons.insights_rounded, color: primaryColor),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Overall Progress",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      "Keep going, you're doing great!",

                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              Text(
                "$percentage%",

                style: TextStyle(
                  color: primaryColor,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: progress,

              minHeight: 10,

              backgroundColor: primaryColor.withValues(alpha: 0.10),

              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerLeft,

            child: Text(
              "$completedCount of $totalCount tasks completed",

              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.60),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPrioritySummary({
    required int highCount,
    required int mediumCount,
    required int lowCount,
  }) {
    return Container(
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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Priority Overview",

            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: buildPriorityItem(
                  title: "High",
                  count: highCount,
                  color: Colors.red,
                  icon: Icons.priority_high,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: buildPriorityItem(
                  title: "Medium",
                  count: mediumCount,
                  color: Colors.orange,
                  icon: Icons.remove,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: buildPriorityItem(
                  title: "Low",
                  count: lowCount,
                  color: Colors.green,
                  icon: Icons.keyboard_arrow_down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPriorityItem({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(13),
      ),

      child: Column(
        children: [
          Icon(icon, color: color, size: 22),

          const SizedBox(height: 5),

          Text(
            "$count",

            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,

            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  int getPriorityCount(Box box, String targetPriority) {
    int count = 0;

    final userKeys = getUserTaskKeys(box);

    for (final key in userKeys) {
      final rawData = box.get(key);

      if (rawData == null || rawData is! Map) {
        continue;
      }

      final taskData = Map<dynamic, dynamic>.from(rawData);

      final priority = getPriority(taskData).toLowerCase();

      if (priority == targetPriority.toLowerCase()) {
        count++;
      }
    }

    return count;
  }

  Widget buildTaskCard({
    required dynamic taskKey,
    required Map<dynamic, dynamic> taskData,
  }) {
    final String taskTitle = (taskData["task"] ?? "").toString();

    final String description = (taskData["description"] ?? "").toString();

    final String priority = getPriority(taskData);

    final Color priorityColor = getPriorityColor(priority);

    String? taskDate;

    if (taskData["date"] != null && taskData["date"].toString().isNotEmpty) {
      try {
        final date = DateTime.parse(taskData["date"].toString());

        taskDate =
            "${date.day.toString().padLeft(2, '0')}/"
            "${date.month.toString().padLeft(2, '0')}/"
            "${date.year}";
      } catch (_) {
        taskDate = null;
      }
    }

    String? taskTime;

    if (taskData["hour"] != null && taskData["minute"] != null) {
      final hour = int.tryParse(taskData["hour"].toString());

      final minute = int.tryParse(taskData["minute"].toString());

      if (hour != null && minute != null) {
        final time = TimeOfDay(hour: hour, minute: minute);

        taskTime = time.format(context);
      }
    }

    return InkWell(
      onTap: () {
        resetSearch();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TaskDetails(taskKey: taskKey, userEmail: widget.userEmail),
          ),
        );
      },

      borderRadius: BorderRadius.circular(18),

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),

        padding: const EdgeInsets.all(14),

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
            Checkbox(
              value: false,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),

              onChanged: (value) async {
                if (value == true) {
                  await markAsDone(taskKey, taskData);
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
                    ),
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),

                    Text(
                      description,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  if (taskDate != null || taskTime != null) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // DATE
                        if (taskDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.10),

                              borderRadius: BorderRadius.circular(8),
                            ),

                            child: Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  size: 14,
                                  color: Colors.blue,
                                ),

                                const SizedBox(width: 5),

                                Text(
                                  taskDate,

                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // TIME
                        if (taskTime != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.10),

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

                                const SizedBox(width: 5),

                                Text(
                                  taskTime,

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

                  const SizedBox(height: 10),

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
                ],
              ),
            ),

            IconButton(
              onPressed: () {
                showDeleteDialog(taskKey: taskKey);
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
          children: [
            const Icon(Icons.task_alt, size: 70, color: Colors.grey),

            const SizedBox(height: 16),

            const Text(
              "No Pending Tasks",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Tap '+' to create a new task.",

              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> migrateOldTasks() async {
    for (final key in taskBox.keys) {
      final rawData = taskBox.get(key);

      if (rawData == null || rawData is! Map) {
        continue;
      }

      final data = Map<dynamic, dynamic>.from(rawData);

      final userEmail = data["userEmail"];

      if (userEmail == null || userEmail.toString().trim().isEmpty) {
        data["userEmail"] = widget.userEmail;

        await taskBox.put(key, data);
      }
    }

    for (final key in doneBox.keys) {
      final rawData = doneBox.get(key);

      if (rawData == null || rawData is! Map) {
        continue;
      }

      final data = Map<dynamic, dynamic>.from(rawData);

      final userEmail = data["userEmail"];

      if (userEmail == null || userEmail.toString().trim().isEmpty) {
        data["userEmail"] = widget.userEmail;

        await doneBox.put(key, data);
      }
    }
  }

  Widget buildNoSearchResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),

            const SizedBox(height: 16),

            const Text(
              "No Matching Tasks",

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Try searching with another keyword.",

              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
