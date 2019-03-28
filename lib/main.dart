// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:sonar_frontend/pages/contact.dart';
import 'package:sonar_frontend/pages/home.dart';
import 'package:sonar_frontend/pages/profile.dart';
import 'package:sonar_frontend/utils/profile_util.dart';

class Sonar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: <String, WidgetBuilder>{
        '/': (context) => HomePage(),
        '/profile': (context) => ProfilePage(profileStorage: ProfileStorage()),
        '/contact': (context) => ContactPage(),
      },
    );
  }
}

void main() {
  runApp(Sonar());
}