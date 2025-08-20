import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_tasks/homepage.dart';

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

      theme: ThemeData(fontFamily: 'Poppins', useMaterial3: true),

      home: const TasksScreen(),
    );
  }
}
