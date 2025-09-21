import 'dart:math';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_app/home.dart';
import 'package:mobile_app/main.dart';
import 'package:image_picker/image_picker.dart';

class Groups extends StatelessWidget {
  const Groups({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MyHomePage(title: 'Home Page'),
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
  TextEditingController cmntController = TextEditingController();
  TextEditingController descController = TextEditingController();

  var _pubpriv = false;
  var selectedVisibility;

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Group Creation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: cmntController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Group Name',
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            maxLines: null,
            controller: descController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Description',
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            final name = cmntController.text.trim();
            final desc = descController.text.trim();
            final visibility = selectedVisibility ?? "Public";
            final userEmail = auth!.email;

            if (name.isEmpty || userEmail == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please fill in all fields")),
              );
              return;
            }

            // Save group to Firestore
            await FirebaseFirestore.instance.collection("groups").add({
              "name": name,
              "visibility": visibility,
              "createdBy": userEmail,
              "description": desc,
              "members": [userEmail],
              "createdAt": DateTime.now(),
            });

            cmntController.clear();
            descController.clear();
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Create'),
        ),
        ElevatedButton(
          onPressed: () {
            cmntController.clear();
            descController.clear();
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildGroupDialog(
      BuildContext context, String groupId, String desc, String name) {
    return AlertDialog(
      title: const Text('Group Description'),
      content: Text(
        desc,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            final userEmail = auth!.email;

            if (userEmail == null) return;

            await FirebaseFirestore.instance
                .collection("groups")
                .doc(groupId)
                .update({
              "members": FieldValue.arrayUnion([userEmail]),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Joined group: $name")),
            );

            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Join'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Location",
      home: Scaffold(
        backgroundColor: Colors.lightGreen[100],
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/assets/mountain.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen.shade300,
                          minimumSize: const Size(64, 64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            side: BorderSide(color: Colors.lightGreen.shade300),
                          ),
                        ),
                        child: const Icon(
                          Icons.home,
                          size: 30.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Home()),
                          );
                        },
                      ),
                      const SizedBox(width: 60),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade300),
                        child: const Text('Create a Group'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                _buildPopupDialog(context),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Existing Groups",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.indigo.shade300),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        height: 30,
                        width: 380,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 95,
                              child: Text(
                                "Name",
                                style:
                                    TextStyle(color: Colors.indigo.shade500),
                              ),
                            ),
                            SizedBox(
                              width: 75,
                              child: Text(
                                "Visibility",
                                style:
                                    TextStyle(color: Colors.indigo.shade500),
                              ),
                            ),
                            SizedBox(
                              width: 110,
                              child: Text(
                                "Creator",
                                style:
                                    TextStyle(color: Colors.indigo.shade500),
                              ),
                            ),
                            const SizedBox(width: 95, child: Text("")),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("groups")
                          .orderBy("createdAt", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final groups = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            final group = groups[index];
                            final groupId = group.id;
                            final name = group["name"];
                            final visibility = group["visibility"];
                            final createdBy = group["createdBy"];
                            final desc = group["description"];

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  height: 70,
                                  width: 380,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: 95,
                                        child: Text(name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color:
                                                    Colors.indigo.shade500)),
                                      ),
                                      SizedBox(
                                        width: 75,
                                        child: Text(visibility,
                                            style: TextStyle(
                                                color: Colors.indigo.shade500)),
                                      ),
                                      SizedBox(
                                        width: 110,
                                        child: Text(createdBy,
                                            style: TextStyle(
                                                color: Colors.indigo.shade500)),
                                      ),
                                      SizedBox(
                                        width: 95,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.indigo.shade300),
                                          child: const Text(
                                            "Join Group",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => _buildGroupDialog(
                                                  context, groupId, desc, name),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}