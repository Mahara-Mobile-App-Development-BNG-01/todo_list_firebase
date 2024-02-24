import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_firebase/home_page.dart';
import 'package:todo_list_firebase/profile_page.dart';
import 'package:todo_list_firebase/sign_up_page.dart';

import 'login_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: HomeRoute.page,
          initial: true,
        ),
        AutoRoute(page: SignUpRoute.page),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ];
}
