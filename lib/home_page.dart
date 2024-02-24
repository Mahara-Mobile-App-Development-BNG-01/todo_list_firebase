import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list_firebase/app_router.dart';
import 'package:todo_list_firebase/login_page.dart';
import 'package:todo_list_firebase/main.dart';
import 'package:todo_list_firebase/profile_page.dart';
import 'package:todo_list_firebase/task_state.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TasksCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text('TODO List'),
        leading: IconButton(
          icon: Icon(Icons.person_2_rounded),
          onPressed: () {
            if (FirebaseAuth.instance.currentUser == null) {
              context.router.push(LoginRoute());
            } else {
              context.router.push(ProfileRoute());
            }
          },
        ),
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
    );
  }
}
