import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_firebase/app_router.dart';
import 'package:todo_list_firebase/sign_up_page.dart';
@RoutePage()
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController emailEditingController = TextEditingController();
  final TextEditingController passwordEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Column(
        children: [
          TextField(
            controller: emailEditingController,
            decoration: InputDecoration(
              hintText: 'Email',
            ),
          ),
          TextField(
            controller: passwordEditingController,
            decoration: InputDecoration(
              hintText: 'Password',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                email: emailEditingController.text,
                password: passwordEditingController.text,
              ).then((value) {
                context.popRoute();
              }).catchError((error) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error.toString())));
              });
            },
            child: Text('Login'),
          ),
          TextButton(
              onPressed: () {
                context.router.push(SignUpRoute());
              },
              child: Text('Sign Up')),
        ],
      ),
    );
  }
}
