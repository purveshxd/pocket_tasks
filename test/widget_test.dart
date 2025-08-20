import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_tasks/models/task.dart';
import 'package:pocket_tasks/providers/task_provider.dart';

void main() {
  group('TaskNotifier Search and Filter Tests', () {
    late ProviderContainer container;
    late TaskNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);

      notifier = container.read(taskProvider.notifier);

      // Add test tasks directly via helper
      notifier.setTasksForTesting([
        Task(title: 'Buy groceries', done: false),
        Task(title: 'Walk the dog', done: true),
        Task(title: 'Read a book', done: false),
        Task(title: 'Clean the house', done: true),
        Task(title: 'Write code', done: false),
      ]);
    });

    test('should filter tasks by All status', () {
      notifier.setFilter(TaskFilter.all);
      final state = container.read(taskProvider);
      expect(state.filteredTasks.length, equals(5));
    });

    test('should filter tasks by Active status', () {
      notifier.setFilter(TaskFilter.active);
      final state = container.read(taskProvider);
      final activeTasks = state.filteredTasks;
      expect(activeTasks.length, equals(3));
      expect(activeTasks.every((task) => !task.done), isTrue);
    });

    test('should filter tasks by Done status', () {
      notifier.setFilter(TaskFilter.done);
      final state = container.read(taskProvider);
      final doneTasks = state.filteredTasks;
      expect(doneTasks.length, equals(2));
      expect(doneTasks.every((task) => task.done), isTrue);
    });

    test('should filter tasks by search query', () {
      notifier.setSearchQueryForTesting('dog');
      final state = container.read(taskProvider);
      final filteredTasks = state.filteredTasks;
      expect(filteredTasks.length, equals(1));
      expect(filteredTasks.first.title, equals('Walk the dog'));
    });

    test('should combine search and filter', () {
      notifier.setSearchQueryForTesting('e');
      notifier.setFilter(TaskFilter.active);
      final state = container.read(taskProvider);
      final filteredTasks = state.filteredTasks;
      expect(filteredTasks.length, equals(3)); // "Read a book", "Write code"
      expect(filteredTasks.every((task) => !task.done), isTrue);
      expect(
        filteredTasks.every((task) => task.title.toLowerCase().contains('e')),
        isTrue,
      );
    });

    test('should return empty list when no tasks match search', () {
      notifier.setSearchQueryForTesting('nonexistent');
      final state = container.read(taskProvider);
      expect(state.filteredTasks.isEmpty, isTrue);
    });
  });
}
