import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:study_sync/models/video_model.dart'; // Ensure this import path is correct

class VideoDetailsPage extends StatefulWidget {
  final VideoModel video;

  const VideoDetailsPage({Key? key, required this.video}) : super(key: key);

  @override
  _VideoDetailsPageState createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends State<VideoDetailsPage> {
  List<Note> notes = [];
  final TextEditingController _noteController = TextEditingController();

  Future<void> _launchURL() async {
    if (!await launch(widget.video.videoUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch video URL')),
      );
    }
  }

  void _showRescheduleDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = DateTime.now();
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: CupertinoDatePicker(
            initialDateTime: selectedDate,
            mode: CupertinoDatePickerMode.dateAndTime,
            onDateTimeChanged: (DateTime newDate) {
              // Implement your rescheduling logic here
            },
          ),
        );
      },
    );
  }

  void _addOrEditNote({Note? existingNote}) {
    final isEditing = existingNote != null;
    if (isEditing) {
      _noteController.text = existingNote.content; // Ensure existingNote is not null here
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteController,
              decoration: InputDecoration(hintText: 'Write your note here...'),
              autofocus: true,
            ),
            ElevatedButton(
              onPressed: () {
                final noteText = _noteController.text.trim();
                if (noteText.isNotEmpty) {
                  if (isEditing) {
                    setState(() {
                      existingNote!.content = noteText; // Update existing note
                    });
                  } else {
                    final newNote = Note(
                      id: DateTime.now().toString(),
                      content: noteText,
                    );
                    setState(() => notes.add(newNote)); // Add new note
                  }
                  Navigator.of(context).pop();
                  _noteController.clear();
                }
              },
              child: Text(isEditing ? 'Update Note' : 'Add Note'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteNote(Note note) {
    setState(() => notes.removeWhere((n) => n.id == note.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                widget.video.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.red, size: 100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.video.title, style: Theme.of(context).textTheme.headline6),
                  SizedBox(height: 8),
                  Text('Duration: ${widget.video.duration.inMinutes} minutes', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 20),
                  OutlinedButton.icon(
                    icon: Icon(Icons.play_circle_outline, color: Colors.red),
                    label: Text('Watch on YouTube'),
                    onPressed: _launchURL,
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red)),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showRescheduleDialog,
                    child: Text('Reschedule Video'),
                    style: ElevatedButton.styleFrom(primary: Theme.of(context).colorScheme.secondary),
                  ),
                  SizedBox(height: 20),
                  Text('Notes', style: Theme.of(context).textTheme.headline6),
                  ...notes.map((note) => ListTile(
                        title: Text(note.content),
                        trailing: Wrap(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _addOrEditNote(existingNote: note),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteNote(note),
                            ),
                          ],
                        ),
                      )).toList(),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(hintText: 'Add a note...'),
                    maxLines: null,
                  ),
                  ElevatedButton(
                    onPressed: () => _addOrEditNote(),
                    child: Text('Save Note'),
                    style: ElevatedButton.styleFrom(primary: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
