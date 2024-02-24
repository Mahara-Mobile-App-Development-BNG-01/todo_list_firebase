import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
@RoutePage()

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Profile Page ${FirebaseAuth.instance.currentUser!.email}'),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                context.popRoute();
              },
              child: Text('Signout'),
            )
          ],
        ),
      ),
    );
  }
}
