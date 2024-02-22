import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_firebase/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list_firebase/task.dart';
import 'package:todo_list_firebase/task_state.dart';

import 'api.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(BlocProvider(create: (_) => TasksCubit(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TasksCubit>();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('TODO List'),
        ),
        body: Builder(builder: (context) {
          if (cubit.state is AsyncTaskStateLoaded) {
            final loadedState = cubit.state as AsyncTaskStateLoaded;
            return TasksView(loadedState: loadedState);
          }
          if (cubit.state is AsyncTaskStateLoading) {
            return CircularProgressIndicator();
          }

          return Text((cubit.state as AsyncTaskStateError).error.toString());
        }),
      ),
    );
  }
}

class TasksView extends StatelessWidget {
  const TasksView({super.key, required this.loadedState});

  final AsyncTaskStateLoaded loadedState;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TasksCubit>();
    return Column(
      children: [
        Row(children: [
          ...TaskFilter.values.map(
            (currentTaskFilter) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FilterChip(
                label: Text(currentTaskFilter.name),
                selected: loadedState.taskFilter == currentTaskFilter,
                onSelected: (newVal) {
                  if (newVal) {
                    cubit.changeFilter(currentTaskFilter);
                  }
                },
              ),
            ),
          )
        ]),
        Expanded(
          child: ListView.builder(
              itemCount: loadedState.filteredTasks.length,
              itemBuilder: (context, index) {
                final task = loadedState.filteredTasks[index];
                return CheckboxListTile(
                  title: Text(task.title),
                  value: task.completed,
                  onChanged: (newValue) {},
                );
              }),
        )
      ],
    );
  }
}

class TasksCubit extends Cubit<AsyncTasksState> {
  TasksCubit() : super(AsyncTaskStateLoading()) {
    fetchTasks();
  }
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> sub;
  void fetchTasks() async {
    try {
      final db = FirebaseFirestore.instance;
      sub =  db.collection('tasks').snapshots().listen((event) {
        final List<Task> tasks = event.docs
            .map((e) => Task.fromJson(e.data()))
            .toList(); //await fetchTodosFromAPI();

        print('${tasks}');

        emit(
          AsyncTaskStateLoaded(
            tasks: tasks,
            filteredTasks: tasks,
          ),
        );
      });
      // final tasksDocs =await db.collection('tasks').get();
      // final List<Task> tasks = tasksDocs.docs.map((e) => Task.fromJson(e.data())).toList(); //await fetchTodosFromAPI();
      //
      // emit(AsyncTaskStateLoaded(tasks: tasks, filteredTasks: tasks));
    } catch (e) {
      emit(AsyncTaskStateError(error: e));
    }
  }

  void changeFilter(TaskFilter filter) {
    if (state is AsyncTaskStateLoaded) {
      final loadedState = state as AsyncTaskStateLoaded;
      emit(
        loadedState.copyWith(
            taskFilter: filter,
            filteredTasks: loadedState.tasks.where((task) {
              switch (filter) {
                case TaskFilter.all:
                  return true;
                case TaskFilter.done:
                  return task.completed;
                case TaskFilter.notDone:
                  return !task.completed;
              }
            }).toList()),
      );
    }
  }
}
