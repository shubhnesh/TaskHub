import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_taskhub/auth/auth_service.dart';
import 'package:mini_taskhub/dashboard/task_model.dart';
import 'package:mini_taskhub/dashboard/task_notifer.dart';
import '../auth/login_screen.dart';
import 'task_tile.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedTab = 0; // 0 = pending, 1 = completed

  void _showAddTaskDialog(BuildContext context) {
    final controller = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final keyboardHeight = MediaQuery.of(dialogCtx).viewInsets.bottom;

          return Padding(
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(dialogCtx).size.width * 0.84,
                  ),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.add_task,
                            color: Colors.blue.shade300,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Add New Task',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        style: const TextStyle(fontSize: 14.5),
                        decoration: InputDecoration(
                          hintText: 'Enter task title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.blue.shade300, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(dialogCtx),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: submitting
                                ? null
                                : () async {
                                    final title = controller.text.trim();
                                    if (title.isEmpty) return;

                                    setDialogState(() => submitting = true);
                                    await ref
                                        .read(tasksProvider.notifier)
                                        .addTask(title);
                                    if (dialogCtx.mounted) {
                                      Navigator.pop(dialogCtx);
                                    }
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: submitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Add Task',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 70,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tasks here',
              style: TextStyle(fontSize: 17, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a new task',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          key: ValueKey(task.id),
          task: task,
          onToggle: (v) => ref
              .read(tasksProvider.notifier)
              .updateTaskStatus(task.id, v ?? false),
          onDelete: () => ref.read(tasksProvider.notifier).deleteTask(task.id),
          onEdit: (newTitle) =>
              ref.read(tasksProvider.notifier).updateTask(task.id, newTitle),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final pendingTasks = ref.watch(pendingTasksProvider);
    final completedTasks = ref.watch(completedTasksProvider);
    final pendingCount = ref.watch(pendingTasksCountProvider);
    final completedCount = ref.watch(completedTasksCountProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Mini TaskHub',
          style: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.grey.shade400,
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade200,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.task_alt,
                  color: Colors.white,
                  size: 42,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Tasks',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$pendingCount pending • $completedCount completed',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Custom segmented control
          Container(
            height: 43,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? Colors.white : null,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: _selectedTab == 0
                            ? [
                                const BoxShadow(
                                    color: Colors.black12, blurRadius: 1)
                              ]
                            : null,
                      ),
                      child: Text(
                        'Pending',
                        style: TextStyle(
                          fontWeight: _selectedTab == 0
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: _selectedTab == 0
                              ? Colors.blue.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? Colors.white : null,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: _selectedTab == 1
                            ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                            : null,
                      ),
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          fontWeight: _selectedTab == 1
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: _selectedTab == 1
                              ? Colors.blue.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: tasksAsync.when(
              data: (_) => _selectedTab == 0
                  ? _buildTaskList(pendingTasks)
                  : _buildTaskList(completedTasks),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 60, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text('Error: $err'),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => ref.read(tasksProvider.notifier).loadTasks(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: Colors.blue.shade300,
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
