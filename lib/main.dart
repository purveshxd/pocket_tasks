import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_tasks/style/app_style.dart';
import 'package:pocket_tasks/widgets/custom_progress_ring.dart';
import 'package:pocket_tasks/widgets/custom_textfield.dart';

import 'providers/task_provider.dart';
import 'widgets/task_item.dart';

void main() {
  runApp(ProviderScope(child: const PocketTasksApp()));
}

class PocketTasksApp extends ConsumerWidget {
  const PocketTasksApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'PocketTasks',
      themeMode: ref.watch(isDarkTheme) ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(fontFamily: 'Poppins', useMaterial3: true),

      home: const TasksScreen(),
    );
  }
}

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showUndoSnackBar(String message, VoidCallback onUndo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: 'Undo', onPressed: onUndo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskProvider);
    final notifier = ref.read(taskProvider.notifier);

    final tasks = state.filteredTasks;
    final totalTasks = state.activeTasksCount + state.completedTasksCount;
    final progress = totalTasks > 0
        ? state.completedTasksCount / totalTasks
        : 0.0;

    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [Color(0xFF321059), Color(0xFF1d052d)]
                    : [Color(0xFF974EEA), Color(0xFF321059)],
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(top: 8),
                child: Column(
                  spacing: 18,
                  children: [
                    // header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: CustomProgressRing(
                            totalTasks: totalTasks,
                            completedTasks: state.completedTasksCount,
                            strokeWidth: 8,
                            progress: progress,
                            progressColor: Color(0xFF8cc78f),
                            backgroundColor: Color(0xFF424758),
                            size: MediaQuery.of(context).size.width * 0.22,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(isDarkTheme.notifier)
                                .update((state) => !state);
                          },
                          child: Text(
                            "PocketTasks",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.085,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Add Task Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 16,
                      children: [
                        Flexible(
                          child: CustomTextfield(
                            controller: _textController,
                            hintText: 'Add Task',
                            errorText: state.addTaskError,
                            onChanged: (_) => notifier.clearAddTaskError(),
                            onSubmitted: (value) => _addTask(notifier, state),
                          ),
                        ),

                        GestureDetector(
                          onTap: () => _addTask(notifier, state),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 26,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF48298a), Color(0xFF321C5B)],
                              ),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Search Box
                    CustomTextfield(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      onChanged: notifier.updateSearchQuery,
                    ),

                    // Filter Chips
                    Row(
                      spacing: 8,
                      children: [
                        _buildFilterChip(
                          'All',
                          TaskFilter.all,
                          notifier,
                          state,
                        ),
                        _buildFilterChip(
                          'Active',
                          TaskFilter.active,
                          notifier,
                          state,
                        ),
                        _buildFilterChip(
                          'Done',
                          TaskFilter.done,
                          notifier,
                          state,
                        ),
                      ],
                    ),

                    // Tasks List
                    Expanded(
                      child: tasks.isEmpty
                          ? Center(
                              child: Text(
                                state.searchQuery.isNotEmpty
                                    ? 'No tasks found'
                                    : 'No tasks yet. Add one above!',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return TaskItem(
                                  task: task,
                                  onToggle: () {
                                    notifier.toggleTask(task.id);
                                    _showUndoSnackBar(
                                      task.done
                                          ? 'Task marked as active'
                                          : 'Task completed',
                                      () => notifier.toggleTask(task.id),
                                    );
                                  },
                                  onDelete: () {
                                    final taskIndex = state.tasks.indexOf(task);
                                    notifier.deleteTask(task.id);
                                    _showUndoSnackBar(
                                      'Task deleted',
                                      () =>
                                          notifier.restoreTask(task, taskIndex),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    TaskFilter filter,
    TaskNotifier notifier,
    TaskState state,
  ) {
    final isSelected = state.filter == filter;

    return ChoiceChip(
      shape: StadiumBorder(),
      label: Text(label, style: TextStyle(color: Colors.white)),
      side: BorderSide.none,
      backgroundColor: Color.fromARGB(255, 47, 16, 76),
      selectedColor: Color(0xFF3E1A64),
      showCheckmark: false,
      selected: isSelected,
      onSelected: (_) => notifier.setFilter(filter),
    );
  }

  void _addTask(TaskNotifier notifier, TaskState state) {
    var title = _textController.text.trim();
    title = title[0].toUpperCase() + title.substring(1);
    notifier.addTask(title).then((_) {
      if (state.addTaskError == null) {
        _textController.clear();
      }
    });
  }
}
