import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

import 'note_editor_page.dart';

class NotesGridPage extends StatelessWidget {
  // Function to show the popup dialog for adding/editing a note
  void _showNoteDialog(BuildContext context, {String? noteId}) {
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();

    if (noteId != null) {
      // If editing, load existing data
      FirebaseFirestore.instance
          .collection('notes')
          .doc(noteId)
          .get()
          .then((doc) {
        _titleController.text = doc['title'];
        _contentController.text = doc['content'];
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (ctx) {
        return AlertDialog(
          title: Text(noteId == null ? 'Add Note' : 'Edit Note'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  maxLength: 100,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final title = _titleController.text;
                final content = _contentController.text;

                if (noteId == null) {
                  // Create a new note
                  FirebaseFirestore.instance.collection('notes').add({
                    'title': title,
                    'content': content,
                    'createdAt': Timestamp.now(),
                    'updatedAt': Timestamp.now(),
                    'archived': false,
                    'deletedAt': null,
                  });
                } else {
                  // Edit existing note
                  FirebaseFirestore.instance.collection('notes').doc(noteId).update({
                    'title': title,
                    'content': content,
                    'updatedAt': Timestamp.now(),
                  });
                }

                Navigator.of(ctx).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .orderBy('updatedAt', descending: true) // Sorting by last updated
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No notes available.'));
          }

          final notes = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Customize the grid aspect ratio
            ),
            itemCount: notes.length,
            itemBuilder: (ctx, index) {
              final note = notes[index];
              return GestureDetector(
                onTap: () {
                  // Open the dialog to edit the note
                  _showNoteDialog(context, noteId: note.id);
                },
                child: Material(
                  color: Colors.transparent,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display note title with Google Font
                          Text(
                            note['title'],
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          // Display note content with Google Font
                          Text(
                            note['content'],
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          // Display note timestamp or last updated
                          Text(
                            'Last Updated: ${DateTime.now().difference(note['updatedAt'].toDate()).inHours} hours ago',
                            style: GoogleFonts.openSans(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open the dialog to add a new note
          _showNoteDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
