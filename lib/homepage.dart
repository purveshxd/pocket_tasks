import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_tasks/providers/task_provider.dart';
import 'package:pocket_tasks/widgets/custom_chip.dart';
import 'package:pocket_tasks/widgets/custom_progress_ring.dart';
import 'package:pocket_tasks/widgets/custom_textfield.dart';
import 'package:pocket_tasks/widgets/task_tile.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final searchFocusNode = FocusNode();
  final taskFocusNode = FocusNode();
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
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: StadiumBorder(),
        showCloseIcon: false,
        action: SnackBarAction(label: 'Undo', onPressed: onUndo),
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: StadiumBorder(),
        showCloseIcon: true,
        backgroundColor: Colors.red,
      ),
    );
  }

  void _addTask(TaskNotifier notifier, TaskState state) {
    var title = _textController.text;

    notifier.addTask(title).then((_) {
      if (state.addTaskError != null) {
        _showErrorSnackBar(state.addTaskError!);
      } else if (state.addTaskError == null) {
        _textController.clear();
      }
    });
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
      child:
          // App Background Gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                end: Alignment.bottomLeft,
                begin: Alignment.topRight,

                colors: [
                  Color.fromARGB(255, 52, 16, 93),
                  Color.fromARGB(255, 20, 2, 32),
                ],
              ),
            ),
            child: Scaffold(
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
                              // notifier.addTestTasks();
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
                              focusNode: taskFocusNode,
                              onTapOutside: (p0) {
                                taskFocusNode.unfocus();
                              },
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
                                  colors: [
                                    Color(0xFF48298a),
                                    Color(0xFF321C5B),
                                  ],
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
                        focusNode: searchFocusNode,
                        onTapOutside: (p0) {
                          searchFocusNode.unfocus();
                        },
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        onChanged: notifier.updateSearchQuery,
                      ),

                      // Filter Chips
                      Row(
                        spacing: 8,
                        children: List.generate(
                          TaskFilter.values.length,
                          (index) => CustomChip(
                            label: TaskFilter.values[index].name,
                            filter: TaskFilter.values[index],
                            isSelected:
                                TaskFilter.values[index] == state.filter,
                            onSelected: () {
                              notifier.setFilter(TaskFilter.values[index]);
                            },
                          ),
                        ),
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
                                physics: BouncingScrollPhysics(),
                                controller: _scrollController,
                                itemCount: tasks.length,
                                itemBuilder: (context, index) {
                                  final task = tasks[index];
                                  return TaskTile(
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
                                      final taskIndex = state.tasks.indexOf(
                                        task,
                                      );
                                      notifier.deleteTask(task.id);
                                      _showUndoSnackBar(
                                        'Task deleted',
                                        () => notifier.restoreTask(
                                          task,
                                          taskIndex,
                                        ),
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
          ),
    );
  }
}
