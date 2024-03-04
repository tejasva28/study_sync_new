import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Import your PlaylistSchedule model correctly
import '../Models/time_scheduling_model.dart';

class TimeSchedulingPage extends StatefulWidget {
  final PlaylistSchedule playlistSchedule;

  TimeSchedulingPage({Key? key, required this.playlistSchedule}) : super(key: key);

  @override
  _TimeSchedulingPageState createState() => _TimeSchedulingPageState();
}

class _TimeSchedulingPageState extends State<TimeSchedulingPage> {
  DateTime selectedDateTime = DateTime.now();

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitHours = twoDigits(duration.inHours);
    return "${twoDigitHours}h $twoDigitsMinutes m";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Playlist', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black.withOpacity(0.5), // Ensures the AppBar text is visible
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fullscreen blurred background image
          Positioned.fill(
            child: Image.network(
              widget.playlistSchedule.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text('Could not load image'));
              },
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          Column(
            children: [
              // Spacer for the AppBar
              SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
              // Thumbnail image at the top
              AspectRatio(
                aspectRatio: 16 / 9, // Maintain the aspect ratio of the thumbnail
                child: Image.network(
                  widget.playlistSchedule.thumbnailUrl,
                  fit: BoxFit.cover, // Cover the aspect ratio box with the image
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Text('Could not load image'));
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black.withOpacity(0.7), // Container with a solid color
                  child: ListView(
                    padding: EdgeInsets.all(16), // Padding for the content inside the ListView
                    children: [
                      Text(
                        widget.playlistSchedule.playlistTitle,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20),
                      Text(
                        '${widget.playlistSchedule.videoCount} Videos',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Total Duration: ${formatDuration(widget.playlistSchedule.totalDuration)}',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(height: 150),
                      // CupertinoDatePicker
                      Container(
  height: 100, // Fixed height for the CupertinoDatePicker
  child: CupertinoTheme(
    data: CupertinoThemeData(
      brightness: Brightness.dark, // Used for picker items' text color
      textTheme: CupertinoTextThemeData(
        dateTimePickerTextStyle: TextStyle(
          color: Colors.white, // Text color for the items in the picker
        ),
      ),
    ),
    child: CupertinoDatePicker(
      mode: CupertinoDatePickerMode.time,
      initialDateTime: selectedDateTime,
      onDateTimeChanged: (DateTime newDateTime) {
        setState(() {
          selectedDateTime = newDateTime;
        });
      },
      backgroundColor: Colors.transparent,
    ),
  ),
),
                      SizedBox(height: 24),
                      // Confirm Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            final TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDateTime);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Time Selected'),
                                  content: Text('You have selected ${selectedTime.format(context)}.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Confirm Time'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blueAccent,
                            onPrimary: Colors.white,
                            textStyle: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
