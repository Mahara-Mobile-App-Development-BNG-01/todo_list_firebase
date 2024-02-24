import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_firebase/app_router.dart';
import 'package:todo_list_firebase/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list_firebase/home_page.dart';
import 'package:todo_list_firebase/login_page.dart';
import 'package:todo_list_firebase/profile_page.dart';
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
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
      routerConfig: _appRouter.config(),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Type To Add',
            ),
            onSubmitted: (text) {
              cubit.addTask(text);
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: loadedState.filteredTasks.length,
              itemBuilder: (context, index) {
                final task = loadedState.filteredTasks[index];
                return CheckboxListTile(
                  title: Text(task.title),
                  value: task.completed,
                  onChanged: (newValue) {
                    cubit.changeTask(task.id, newValue ?? false);
                  },
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
  final db = FirebaseFirestore.instance;

  void fetchTasks() async {
    try {
      sub = db.collection('tasks').snapshots().listen((event) {
        final List<Task> tasks =
            event.docs.map((e) => Task.fromJsonID(e.id, e.data())).toList();

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

  void addTask(String text) {
    db.collection('tasks').add(
      {
        'title': text,
        'completed': false,
      },
    );
  }

  void changeTask(String id, bool completed) {
    db.collection('tasks').doc(id).update(
      {
        'completed': completed,
      },
    );
  }
}
