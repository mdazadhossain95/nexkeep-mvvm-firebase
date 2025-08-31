import 'package:flutter/material.dart';
import '../../data/note_model.dart';


class NoteCard extends StatelessWidget {
  final Note note; const NoteCard({super.key, required this.note});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/note/${note.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _parseColor(note.color),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(note.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            if (note.type == 'list')
              ...note.items.take(5).map((it)=> Row(children:[
                Icon(it.checked?Icons.check_box:Icons.check_box_outline_blank, size: 18),
                const SizedBox(width: 6), Expanded(child: Text(it.text)),
              ]))
            else
              Text(note.body, maxLines: 8, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}


Color _parseColor(String hex){
  try{ final v = int.parse(hex.substring(1), radix:16); return Color(0xFF000000 | v).withOpacity(1); } catch(_){ return Colors.white; }
}