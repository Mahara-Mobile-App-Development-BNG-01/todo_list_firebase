import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
@RoutePage()
class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final TextEditingController emailEditingController = TextEditingController();
  final TextEditingController passwordEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up Page'),
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
                  .createUserWithEmailAndPassword(
                email: emailEditingController.text,
                password: passwordEditingController.text,
              )
                  .then((value) {
                FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                  email: emailEditingController.text,
                  password: passwordEditingController.text,
                )
                    .then((value) {
                      context.router.popUntilRoot();
                });
              }).catchError((error) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error.toString())));
              });
            },
            child: Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
