import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../services/task_storage.dart';

enum TaskFilter { all, active, done }

class TaskState {
  final List<Task> tasks;
  final String searchQuery;
  final TaskFilter filter;
  final String? addTaskError;

  TaskState({
    required this.tasks,
    this.searchQuery = '',
    this.filter = TaskFilter.all,
    this.addTaskError,
  });

  int get activeTasksCount => tasks.where((task) => !task.done).length;
  int get completedTasksCount => tasks.where((task) => task.done).length;

  List<Task> get filteredTasks {
    var filtered = tasks;

    // Apply text filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (task) =>
                task.title.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply status filter
    switch (filter) {
      case TaskFilter.active:
        filtered = filtered.where((task) => !task.done).toList();
        break;
      case TaskFilter.done:
        filtered = filtered.where((task) => task.done).toList();
        break;
      case TaskFilter.all:
        break;
    }

    return filtered;
  }

  TaskState copyWith({
    List<Task>? tasks,
    String? searchQuery,
    TaskFilter? filter,
    String? addTaskError,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      addTaskError: addTaskError,
    );
  }
}

class TaskNotifier extends AutoDisposeNotifier<TaskState> {
  Timer? _debounceTimer;

  @override
  TaskState build() {
    _loadTasks();
    return TaskState(tasks: []);
  }

  Future<void> _loadTasks() async {
    final loaded = await TaskStorage.loadTasks();
    state = state.copyWith(tasks: loaded);
  }

  Future<void> _saveTasks() async {
    await TaskStorage.saveTasks(state.tasks);
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) {
      state = state.copyWith(addTaskError: 'Task title cannot be empty');
      return;
    }
    title = title[0].toUpperCase() + title.substring(1);
    final task = Task(title: title.trim(), done: false);
    final updated = [task, ...state.tasks];
    state = state.copyWith(tasks: updated, addTaskError: null);
    await _saveTasks();
  }

  //! just for add 100 task at once
  // void addTestTasks() async {
  //   final taskTitle = "tasks";
  //   var updated = <Task>[...state.tasks];

  //   for (var i = 0; i <= 50; i++) {
  //     final task = Task(title: taskTitle + i.toString(), done: false);
  //     updated = [task, ...state.tasks];
  //     state = state.copyWith(tasks: updated, addTaskError: null);
  //   }
  //   await _saveTasks();
  // }

  void clearAddTaskError() {
    if (state.addTaskError != null) {
      state = state.copyWith(addTaskError: null);
    }
  }

  Future<void> toggleTask(String taskId) async {
    final updated = state.tasks.map((t) {
      if (t.id == taskId) return t.copyWith(done: !t.done);
      return t;
    }).toList();

    state = state.copyWith(tasks: updated);
    await _saveTasks();
  }

  Future<void> deleteTask(String taskId) async {
    final updated = state.tasks.where((t) => t.id != taskId).toList();
    state = state.copyWith(tasks: updated);
    await _saveTasks();
  }

  Future<void> restoreTask(Task task, int index) async {
    final updated = [...state.tasks];
    updated.insert(index, task);
    state = state.copyWith(tasks: updated);
    await _saveTasks();
  }

  void updateSearchQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      state = state.copyWith(searchQuery: query);
    });
  }

  void setFilter(TaskFilter filter) {
    state = state.copyWith(filter: filter);
  }

  @visibleForTesting
  void setTasksForTesting(List<Task> tasks) {
    state = state.copyWith(tasks: tasks);
  }

  @visibleForTesting
  void setSearchQueryForTesting(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

// Riverpod provider
final taskProvider = AutoDisposeNotifierProvider<TaskNotifier, TaskState>(() {
  return TaskNotifier();
});
