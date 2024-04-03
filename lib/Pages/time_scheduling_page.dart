import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:study_sync/token_service.dart';
import '../Models/time_scheduling_model.dart';
import 'package:intl/intl.dart';

class TimeSchedulingPage extends StatefulWidget {
  final PlaylistSchedule playlistSchedule;

  const TimeSchedulingPage({Key? key, required this.playlistSchedule})
      : super(key: key);

  @override
  _TimeSchedulingPageState createState() => _TimeSchedulingPageState();
}

class _TimeSchedulingPageState extends State<TimeSchedulingPage> {
  DateTime selectedDateTime = DateTime.now();
  late TokenService tokenService;

  @override
  void initState() {
    super.initState();
    tokenService =
        TokenService('http://10.0.2.2:4000/api'); // Adjust API URL as needed
  }

  Future<void> saveScheduledVideos(String token) async {  // Removed parameter 'String token' because it's retrieved inside the function
  String apiUrl = '${tokenService.authApiUrl}/playlistSchedule/create';
  String? token = await tokenService.getToken();

  print('API URL: $apiUrl');
  print('Token retrieved: ${token?.substring(0, 10)}');  // Logs first 10 characters of the token for verification

  if (token == null) {
    print('No token found');
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Authentication token not found'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
    return;
  }

  print('Authorization Header: Bearer ${token.substring(0, 10)}');

  var requestBody = jsonEncode({
    'playlistLink': widget.playlistSchedule.playlistLink,
    'scheduleTime': selectedDateTime.toIso8601String(),
  });
  print('Request body: $requestBody');

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: requestBody,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      final dateTimeFormatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime);
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Time Selected'),
          content: Text('You have selected $dateTimeFormatted.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      throw Exception('Failed to schedule playlist: ${response.body}');
    }
  } catch (e) {
    print('An error occurred during the request: $e');
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: Text('An error occurred: $e'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Playlist',
            style: TextStyle(color: Colors.white)),
        backgroundColor:
            Colors.black.withOpacity(0.5), // Ensures the AppBar text is visible
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
                return const Center(child: Text('Could not load image'));
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
              SizedBox(
                  height: MediaQuery.of(context).padding.top + kToolbarHeight),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  widget.playlistSchedule.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Could not load image'));
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(widget.playlistSchedule.playlistTitle,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 20),
                      Text('${widget.playlistSchedule.videoCount} Videos',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(
                          'Total Duration: ${formatDuration(widget.playlistSchedule.totalDuration)}',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 24),
                      SizedBox(
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
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            final TimeOfDay selectedTime =
                                TimeOfDay.fromDateTime(selectedDateTime);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Time Selected'),
                                content: Text(
                                    'You have selected ${selectedTime.format(context)}.'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent,
                              textStyle: const TextStyle(fontSize: 18)),
                          child: const Text('Confirm Time'),
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
            const Center(child: Text('Could not load image')),
      ),
    );
  }

  Widget buildContent() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Column(
          children: [
            Spacer(flex: 3),
            buildThumbnailImage(),
            buildDetails(),
            Spacer(),
            buildDatePicker(),
            buildConfirmButton(),
            Spacer(flex: 2),
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
            const Center(child: Text('Could not load image')),
      ),
    );
  }

  Widget buildDetails() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black.withOpacity(0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.playlistSchedule.playlistTitle,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.playlistSchedule.videoCount} Videos',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            'Total Duration: ${formatDuration(widget.playlistSchedule.totalDuration)}',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildListView() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.playlistSchedule.playlistTitle,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 20),
          Text('${widget.playlistSchedule.videoCount} Videos',
              style: const TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
              'Total Duration: ${formatDuration(widget.playlistSchedule.totalDuration)}',
              style: const TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 24),
          buildDatePicker(),
          const SizedBox(height: 24),
          buildConfirmButton(),
        ],
      ),
    );
  }

  Widget buildDatePicker() {
    return Container(
      height: 500,
      color: Colors.white.withOpacity(0.7),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: selectedDateTime,
        onDateTimeChanged: (newDateTime) =>
            setState(() => selectedDateTime = newDateTime),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Widget buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _onConfirmTimePressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blueAccent,
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: const Text('Confirm Time'),
      ),
    );
  }

  Future<void> _onConfirmTimePressed() async {
    final TimeOfDay selectedTime =
        TimeOfDay.fromDateTime(selectedDateTime); // Rename to selectedTime
    final String? token = await tokenService.getToken();
    print('Selected Time: ${selectedTime.format(context)}');

    if (token == null) {
      // Handle case when token is not available
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Authentication token not found'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    // Call save function after confirming the time
    saveScheduledVideos(token).then((_) {
      // The dialog now will be shown after successful saving inside saveScheduledVideos
    }).catchError((error) {
      // If saving fails, show an error dialog or handle the error appropriately
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to schedule: $error'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    });
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
// String getCurrentUserId() {
//   // Placeholder for actual user ID logic
//   return "userId";
// }

// Placeholder for fetchPlaylistSchedules
// Future<List<PlaylistSchedule>> fetchPlaylistSchedules() async {
//   // Placeholder: Implement the logic to fetch or generate your playlist schedules
//   // This could be an API call to your backend or a query to a local database

//   // For demonstration, returning an empty list
//   return [];
// }

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
