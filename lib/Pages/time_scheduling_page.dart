import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../Models/video_model.dart';
import 'package:study_sync/Pages/home.dart';
import '../Models/time_scheduling_model.dart';

class TimeSchedulingPage extends StatefulWidget {
  final PlaylistSchedule playlistSchedule;

  const TimeSchedulingPage({Key? key, required this.playlistSchedule})
      : super(key: key);

  @override
  _TimeSchedulingPageState createState() => _TimeSchedulingPageState();
}

class _TimeSchedulingPageState extends State<TimeSchedulingPage> {
  DateTime selectedDateTime = DateTime.now();
  late Future<List<PlaylistSchedule>> futureScheduledPlaylists;

  @override
  void initState() {
    super.initState();
    futureScheduledPlaylists = fetchScheduledPlaylists();
  }

 Future<List<PlaylistSchedule>> fetchScheduledPlaylists() async {
  try {
    final response = await http.get(
      Uri.parse('https://fe00-117-220-236-245.ngrok-free.app/api/playlistSchedule/create'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> playlistData = jsonDecode(response.body);
      return playlistData.map((data) => PlaylistSchedule.fromJson(data)).toList();
    } else {
      // Handle error
      throw Exception('Failed to load scheduled playlists');
    }
  } catch (e) {
    // Handle any errors that occur during the HTTP request
    throw Exception('An error occurred: $e');
  }
}
@override
Widget (BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Schedule Playlist', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.black.withOpacity(0.5), // Ensures the AppBar text is visible
      elevation: 0,
    ),
    extendBodyBehindAppBar: true,
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            widget.playlistSchedule.thumbnailUrl, // Corrected reference
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
            SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                widget.playlistSchedule.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text('Could not load image'));
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    Text(widget.playlistSchedule.playlistTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 20),
                    Text('${widget.playlistSchedule.videoCount} Videos', style: TextStyle(fontSize: 18, color: Colors.white)),
                    SizedBox(height: 8),
                    Text('Total Duration: ${formatDuration(widget.playlistSchedule.totalDuration)}', style: TextStyle(fontSize: 18, color: Colors.white)),
                    SizedBox(height: 24),
                    Container(
                      height: 100,
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
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          final TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDateTime);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text('Time Selected'),
                              content: Text('You have selected ${selectedTime.format(context)}.'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text('Confirm Time'),
                        style: ElevatedButton.styleFrom(primary: Colors.blueAccent, onPrimary: Colors.white, textStyle: TextStyle(fontSize: 18)),
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

  Widget buildBackgroundImage() {
    return Positioned.fill(
      child: Image.network(
        widget.playlistSchedule.thumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Center(child: Text('Could not load image')),
      ),
    );
  }

  Widget buildContent() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Column(
          children: [
            SizedBox(
                height: MediaQuery.of(context as BuildContext).padding.top +
                    kToolbarHeight),
            buildThumbnailImage(),
            buildListView(),
          ],
        ),
      ),
    );
  }

  Widget buildThumbnailImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        widget.playlistSchedule.thumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Center(child: Text('Could not load image')),
      ),
    );
  }

  Widget buildListView() {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(widget.playlistSchedule.playlistTitle,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 20),
          Text('${widget.playlistSchedule.videoCount} Videos',
              style: TextStyle(fontSize: 18, color: Colors.white)),
          SizedBox(height: 8),
          Text(
              'Total Duration: ${formatDuration(widget.playlistSchedule.totalDuration)}',
              style: TextStyle(fontSize: 18, color: Colors.white)),
          SizedBox(height: 24),
          buildDatePicker(),
          SizedBox(height: 24),
          buildConfirmButton(),
        ],
      ),
    );
  }

  Widget buildDatePicker() {
    return Container(
      height: 100,
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: selectedDateTime,
        onDateTimeChanged: (newDateTime) {
          setState(() {
            selectedDateTime = newDateTime;
          });
        },
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Widget buildConfirmButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _onConfirmTimePressed,
        child: Text('Confirm Time'),
        style: ElevatedButton.styleFrom(
            primary: Colors.blueAccent, onPrimary: Colors.white),
      ),
    );
  }

  void _onConfirmTimePressed() {
    final TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDateTime);
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Time Selected'),
        content: Text('You have selected ${selectedTime.format(context)}.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    return "$hours:$minutes";
  }
}










//  Future<void> savePlaylistSchedule() async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:4000/api/playlistSchedule/create'), // Your API endpoint
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode({
//           // Add your fields according to the backend requirements
//           'playlistLink': widget.playlistSchedule.playlistLink,
//           'scheduleTime': selectedDateTime.toIso8601String(),
//           // Include other fields as required
//         }),
//       );

//       // It's important to check mounted here, after the async gap and before any state updates
//       if (!mounted) return;

//   if (response.statusCode == 201) {
//     // Fetch the updated list of playlist schedules
//     List<PlaylistSchedule> playlistSchedules = await fetchPlaylistSchedules();

//     // Check again to ensure the widget is still in the widget tree
//     if (!mounted) return;

//     // Navigate to MonthDateRow with the fetched playlist schedules
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (_) => MonthDateRow(playlistSchedules: playlistSchedules)),
//     );
//   } else {
//     // Handle errors
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to save the schedule: ${response.body}')),
//     );
//   }
// } catch (e) {
//       // Handle any errors that occur during the HTTP request
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save the schedule: $e')),
//       );
//     }
//   }


// Assuming you have a method to get the current user's ID
String getCurrentUserId() {
  // Placeholder for actual user ID logic
  return "userId";
}

// Placeholder for fetchPlaylistSchedules
Future<List<PlaylistSchedule>> fetchPlaylistSchedules() async {
  // Placeholder: Implement the logic to fetch or generate your playlist schedules
  // This could be an API call to your backend or a query to a local database

  // For demonstration, returning an empty list
  return [];
}

// Future<void> savePlaylistSchedule() async {

//   var response = await http.post(
//     Uri.parse('http://localhost:4000/api/playlistSchedule/create'),
//     headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
//     body: jsonEncode({
//       'userId': "exampleUserId", // Assuming you have a way to get the current user's ID
//       'playlistLink': widget.playlistSchedule.playlistLink,
//       'playlistTitle': widget.playlistSchedule.playlistTitle,
//       'thumbnailUrl': widget.playlistSchedule.thumbnailUrl,
//       'scheduleTime': selectedDateTime.toIso8601String(),
//       // Add additional required fields here
//     }),
//   );

//   if (response.statusCode == 201) {
//     // Assuming you have a way to fetch updated schedules after saving
//     // This could be a redirect to a page showing all schedules or simply popping back to a previous page
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MonthDateRow())); // Adjust as necessary
//   } else {
//     // Error handling
//     print('Failed to save the schedule');
//   }
// }
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Text('Schedule Playlist', style: TextStyle(color: Colors.white)),
//       backgroundColor:
//           Colors.black.withOpacity(0.5), // Ensures the AppBar text is visible
//       elevation: 0,
//     ),
//     extendBodyBehindAppBar: true,
//     body: Stack(
//       children: [
//         // Fullscreen blurred background image
//         Positioned.fill(
//           child: Image.network(
//             widget.PlaylistSchedule.thumbnailUrl,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return Center(child: Text('Could not load image'));
//             },
//           ),
//         ),
//         Positioned.fill(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//             child: Container(
//               color: Colors.black.withOpacity(0.3),
//             ),
//           ),
//         ),
//         Column(
//           children: [
//             // Spacer for the AppBar
//             SizedBox(
//                 height: MediaQuery.of(context).padding.top + kToolbarHeight),
//             // Thumbnail image at the top
//             AspectRatio(
//               aspectRatio: 16 / 9, // Maintain the aspect ratio of the thumbnail
//               child: Image.network(
//                 widget.playlistSchedule.thumbnailUrl,
//                 fit: BoxFit.cover, // Cover the aspect ratio box with the image
//                 errorBuilder: (context, error, stackTrace) {
//                   return Center(child: Text('Could not load image'));
//                 },
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 color: Colors.black
//                     .withOpacity(0.7), // Container with a solid color
//                 child: ListView(
//                   padding: EdgeInsets.all(
//                       16), // Padding for the content inside the ListView
//                   children: [
//                     Text(
//                       widget.playlistSchedule.playlistTitle,
//                       style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white),
//                       textAlign: TextAlign.left,
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       '${widget.playlistSchedule.videoCount} Videos',
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Total Duration: ${formatDuration(widget.playlistSchedule.totalDuration)}',
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                     SizedBox(height: 150),
//                     // CupertinoDatePicker
//                     Container(
//                       height: 100, // Fixed height for the CupertinoDatePicker
//                       child: CupertinoTheme(
//                         data: CupertinoThemeData(
//                           brightness: Brightness
//                               .dark, // Used for picker items' text color
//                           textTheme: CupertinoTextThemeData(
//                             dateTimePickerTextStyle: TextStyle(
//                               color: Colors
//                                   .white, // Text color for the items in the picker
//                             ),
//                           ),
//                         ),
//                         child: CupertinoDatePicker(
//                           mode: CupertinoDatePickerMode.time,
//                           initialDateTime: selectedDateTime,
//                           onDateTimeChanged: (DateTime newDateTime) {
//                             setState(() {
//                               selectedDateTime = newDateTime;
//                             });
//                           },
//                           backgroundColor: Colors.transparent,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 24),
//                     // Confirm Button
//                     Center(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           final TimeOfDay selectedTime =
//                               TimeOfDay.fromDateTime(selectedDateTime);
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: Text('Time Selected'),
//                                 content: Text(
//                                     'You have selected ${selectedTime.format(context)}.'),
//                                 actions: <Widget>[
//                                   TextButton(
//                                     child: Text('OK'),
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                     },
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         },
//                         child: Text('Confirm Time'),
//                         style: ElevatedButton.styleFrom(
//                           primary: Colors.blueAccent,
//                           onPrimary: Colors.white,
//                           textStyle: TextStyle(fontSize: 18),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
