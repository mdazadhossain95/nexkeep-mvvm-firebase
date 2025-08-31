class NoteItem {
  final String text;
  final bool checked;

  const NoteItem({required this.text, required this.checked});

  factory NoteItem.fromMap(Map<String, dynamic> m) =>
      NoteItem(text: m['text'] ?? '', checked: m['checked'] ?? false);

  Map<String, dynamic> toMap() => {'text': text, 'checked': checked};
}

class NoteImage {
  final String path;
  final String url;
  final int w;
  final int h;

  const NoteImage({
    required this.path,
    required this.url,
    required this.w,
    required this.h,
  });

  factory NoteImage.fromMap(Map<String, dynamic> m) => NoteImage(
    path: m['path'] ?? '',
    url: m['url'] ?? '',
    w: (m['w'] ?? 0) as int,
    h: (m['h'] ?? 0) as int,
  );

  Map<String, dynamic> toMap() => {'path': path, 'url': url, 'w': w, 'h': h};
}

class Note {
  final String id;
  final String ownerId;
  final List<String> participants;
  final String title;
  final String body;
  final String type; // text|list
  final List<NoteItem> items;
  final String color;
  final List<String> labels;
  final List<NoteImage> images;
  final bool pinned;
  final bool archived;
  final DateTime? deletedAt;
  final DateTime? reminderAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.ownerId,
    required this.participants,
    required this.title,
    required this.body,
    required this.type,
    required this.items,
    required this.color,
    required this.labels,
    required this.images,
    required this.pinned,
    required this.archived,
    required this.deletedAt,
    required this.reminderAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromMap(String id, Map<String, dynamic> m) => Note(
    id: id,
    ownerId: m['ownerId'] ?? '',
    participants: List<String>.from(m['participants'] ?? const []),
    title: m['title'] ?? '',
    body: m['body'] ?? '',
    type: m['type'] ?? 'text',
    items: (m['items'] as List? ?? [])
        .map((e) => NoteItem.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
    color: m['color'] ?? '#FFFFFF',
    labels: List<String>.from(m['labels'] ?? const []),
    images: (m['images'] as List? ?? [])
        .map((e) => NoteImage.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
    pinned: m['pinned'] ?? false,
    archived: m['archived'] ?? false,
    deletedAt: (m['deletedAt'] != null)
        ? DateTime.tryParse(m['deletedAt'])
        : null,
    reminderAt: (m['reminderAt'] != null)
        ? DateTime.tryParse(m['reminderAt'])
        : null,
    createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(m['updatedAt'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'participants': participants,
    'title': title,
    'body': body,
    'type': type,
    'items': items.map((e) => e.toMap()).toList(),
    'color': color,
    'labels': labels,
    'images': images.map((e) => e.toMap()).toList(),
    'pinned': pinned,
    'archived': archived,
    'deletedAt': deletedAt?.toIso8601String(),
    'reminderAt': reminderAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
