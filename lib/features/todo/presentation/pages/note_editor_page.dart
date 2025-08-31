import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteEditorPage extends StatefulWidget {
  final String? noteId;
  const NoteEditorPage({Key? key, this.noteId}) : super(key: key);

  @override
  _NoteEditorPageState createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      _loadNote();
    }
  }

  Future<void> _loadNote() async {
    final noteSnapshot = await FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.noteId)
        .get();
    if (noteSnapshot.exists) {
      final note = noteSnapshot.data()!;
      _titleController.text = note['title'];
      _contentController.text = note['content'];
    }
  }

  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;

    if (widget.noteId == null) {
      // Creating a new note
      FirebaseFirestore.instance.collection('notes').add({
        'title': title,
        'content': content,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'archived': false,
        'deletedAt': null,
      });
    } else {
      // Updating the existing note
      FirebaseFirestore.instance.collection('notes').doc(widget.noteId).update({
        'title': title,
        'content': content,
        'updatedAt': Timestamp.now(),
      });
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'Create Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              maxLength: 100,
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
