import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Constants/AppString.dart';
import 'objects/clients.dart';
import 'screens/actions.dart';

class UserListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          }

          final List users =
              snapshot.data!.docs.map((QueryDocumentSnapshot doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Todo(
               id: doc.id,
              name: data['name'],
              email: data['email'],
              address: data['address'],
              completed: false,
            );
          }).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              final user = users[index];
              return Card(
                child: ListTile(
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Age: ${user.email}'),
                      Text('Address: ${user.address}'),
                      ElevatedButton(
                        onPressed: ()  {
                         Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => actions(user: user,),
                            ),
                          );
                        },
                        child: Text(AppStrings.openCall),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
