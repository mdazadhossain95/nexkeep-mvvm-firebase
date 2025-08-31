import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trash'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .where('deletedAt', isNotEqualTo: null)
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No deleted notes'));
          }

          final notes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (ctx, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note['title']),
                subtitle: Text(note['content']),
                trailing: IconButton(
                  icon: Icon(Icons.restore),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('notes')
                        .doc(note.id)
                        .update({'deletedAt': null});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
