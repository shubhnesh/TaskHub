import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_taskhub/dashboard/task_model.dart';
import 'package:mini_taskhub/services/supabase_service.dart';

// Provider for SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// StateNotifier for managing tasks list
class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final SupabaseService _service;

  TasksNotifier(this._service) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final data = await _service.fetchTasks();
      final tasks = data.map((e) => Task.fromJson(e)).toList();
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTask(String title) async {
    try {
      await _service.addTask(title);
      await loadTasks(); // Reload to get updated list
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTaskStatus(int id, bool isCompleted) async {
    // Optimistic update
    state.whenData((tasks) {
      final updatedTasks = tasks.map((task) {
        if (task.id == id) {
          return task.copyWith(isCompleted: isCompleted);
        }
        return task;
      }).toList();
      state = AsyncValue.data(updatedTasks);
    });

    try {
      await _service.updateTaskStatus(id, isCompleted);
    } catch (e) {
      // Revert on error
      await loadTasks();
    }
  }

  Future<void> deleteTask(int id) async {
    // Optimistic update
    state.whenData((tasks) {
      final updatedTasks = tasks.where((task) => task.id != id).toList();
      state = AsyncValue.data(updatedTasks);
    });

    try {
      await _service.deleteTask(id);
    } catch (e) {
      // Revert on error
      await loadTasks();
    }
  }

  Future<void> updateTask(int id, String newTitle) async {
    // Optimistic update
    state.whenData((tasks) {
      final updatedTasks = tasks.map((task) {
        if (task.id == id) {
          return task.copyWith(title: newTitle);
        }
        return task;
      }).toList();
      state = AsyncValue.data(updatedTasks);
    });

    try {
      await _service.updateTask(id, newTitle);
    } catch (e) {
      // Revert on error
      await loadTasks();
    }
  }
}

// Provider for TasksNotifier
final tasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return TasksNotifier(service);
});

// Computed provider for pending tasks count
final pendingTasksCountProvider = Provider<int>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.when(
    data: (tasks) => tasks.where((task) => !task.isCompleted).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Computed provider for completed tasks count
final completedTasksCountProvider = Provider<int>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.when(
    data: (tasks) => tasks.where((task) => task.isCompleted).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Filtered provider for pending tasks
final pendingTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.when(
    data: (tasks) => tasks.where((task) => !task.isCompleted).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Filtered provider for completed tasks
final completedTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.when(
    data: (tasks) => tasks.where((task) => task.isCompleted).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});