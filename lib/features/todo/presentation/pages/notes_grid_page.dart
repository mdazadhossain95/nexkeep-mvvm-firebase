import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class NotesGridPage extends StatelessWidget {
  const NotesGridPage({super.key});

  // Helper: "time ago" text
  String _timeAgo(Timestamp ts) {
    final dt = ts.toDate();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    final weeks = (diff.inDays / 7).floor();
    return '${weeks} w ago';
  }

  // Modern popup editor as a modal bottom sheet
  Future<void> _openNoteSheet(
    BuildContext context, {
    DocumentSnapshot<Map<String, dynamic>>? note,
  }) async {
    final isEdit = note != null;
    final titleCtl = TextEditingController(text: note?['title'] ?? '');
    final contentCtl = TextEditingController(text: note?['content'] ?? '');
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets.bottom;
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> save() async {
              if (!formKey.currentState!.validate()) return;
              setState(() => saving = true);
              final now = Timestamp.now();
              final data = {
                'title': titleCtl.text.trim(),
                'content': contentCtl.text.trim(),
                'updatedAt': now,
              };
              if (isEdit) {
                await FirebaseFirestore.instance
                    .collection('notes')
                    .doc(note!.id)
                    .update(data);
              } else {
                await FirebaseFirestore.instance.collection('notes').add({
                  ...data,
                  'createdAt': now,
                  'archived': false,
                  'deletedAt': null,
                });
              }
              if (ctx.mounted) Navigator.pop(ctx);
            }

            Future<void> deleteNote() async {
              if (!isEdit) return;
              setState(() => saving = true);
              await FirebaseFirestore.instance
                  .collection('notes')
                  .doc(note!.id)
                  .delete();
              if (ctx.mounted) Navigator.pop(ctx);
            }

            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(bottom: viewInsets),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isEdit ? 'Edit note' : 'Add note',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: titleCtl,
                              maxLength: 100,
                              style: GoogleFonts.lato(fontSize: 16),
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Title required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: contentCtl,
                              minLines: 4,
                              maxLines: 8,
                              style: GoogleFonts.roboto(fontSize: 14),
                              decoration: const InputDecoration(
                                labelText: 'Content',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (isEdit)
                            IconButton.outlined(
                              tooltip: 'Delete',
                              onPressed: saving ? null : deleteNote,
                              icon: const Icon(Icons.delete_outline),
                            ),
                          const Spacer(),
                          TextButton(
                            onPressed: saving ? null : () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: saving ? null : save,
                            icon: saving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: Text(isEdit ? 'Save' : 'Create'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.openSansTextTheme(
      Theme.of(context).textTheme,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nex Keep',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text('No notes yet', style: textTheme.titleMedium),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 110),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final n = docs[i].data();
              return InkWell(
                onTap: () => _openNoteSheet(context, note: docs[i]),
                borderRadius: BorderRadius.circular(18),
                child: Card(
                  elevation: 3,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n['title'] ?? '',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            n['content'] ?? '',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Updated ${_timeAgo(n['updatedAt'] as Timestamp)}',
                              style: GoogleFonts.openSans(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      // Centered, larger FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 200,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[900], // navy blue
            foregroundColor: Colors.white,       // text color
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          onPressed: () => _openNoteSheet(context),
          child: const Text(
            'Add Notes +',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),


    );
  }
}
