import 'dart:convert';

import 'package:api_request/models/users.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Users>> getUsers() async {
    var url = Uri.parse("https://randomuser.me/api/?results=20");
    late http.Response response;
    List<Users> users = [];

    try {
      response = await http.get(url);
      if (response.statusCode == 200) {
        Map peopleData = jsonDecode(response.body);
        List<dynamic> peoples = peopleData["results"];

        for (var people in peoples) {
          var email = people["email"];
          var name = people["name"]["title"] +
              "." +
              people["name"]["first"] +
              " " +
              people["name"]["last"];

          var country = people["country"];
          var picture = people["picture"]["medium"];
          Users user = Users(
              email: email, name: name, country: country, picture: picture);

          users.add(user);
        }
      } else {
        return Future.error("Somthing wrong, ${response.statusCode}");
      }
    } catch (e) {
      return Future.error(e.toString());
    }

    return users;
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
            future: getUsers(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(snapshot.data[index].picture)),
                        title: Text(snapshot.data[index].name),
                        subtitle: Text(snapshot.data[index].email),
                        onTap: () {},
                      );
                    });
              }
            }));
  }
}
