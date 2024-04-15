import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:study_sync/service.dart';
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
  TimeOfDay selectedTimeOfDay = TimeOfDay.now();
  late ApiService apiService;
  late TokenService tokenService; // Declare TokenService here

  @override
  void initState() {
    super.initState();
    tokenService = TokenService(
        'http://10.0.2.2:4000/api'); // Initialize the class-level tokenService
    apiService = ApiService(tokenService.authApiUrl, tokenService);
  }

  Future<void> saveScheduledVideos() async {
    // Format the TimeOfDay to 'HH:mm' format or as required
    final String formattedTime = selectedTimeOfDay.format(context);

    try {
      bool result = await apiService.createSchedule(
        widget.playlistSchedule.playlistLink,
        formattedTime,
      );

      if (result) {
        final dateTimeFormatted =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Success'),
            content:
                Text('Playlist scheduled successfully for $dateTimeFormatted.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to schedule the playlist.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Error scheduling video: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to schedule the playlist: $error'),
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

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTimeOfDay,
    );
    if (picked != null && picked != selectedTimeOfDay) {
      setState(() {
        selectedTimeOfDay = picked;
        selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
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
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Text('Could not load image')),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.3)),
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
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Text('Could not load image')),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(
                        16), // Added padding for better spacing
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        widget.playlistSchedule.playlistTitle, // Playlist title widget
                        style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold,),
                      ),
                      SizedBox(height: 20),
                        Row(
                          children: [
                            Row(
                              children: <Widget>[
                                Icon(Icons.video_library, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  '${widget.playlistSchedule.videoCount} Videos',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(width: 24),
                            Row(
                              children: <Widget>[
                                Icon(Icons.timer, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Total Duration: ${formatDuration(widget.playlistSchedule.totalDuration)}',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        SizedBox(
                          height: 250,
                          child: CupertinoTheme(
                            data: CupertinoThemeData(
                              brightness: Brightness
                                  .dark, // Use dark theme brightness which has white text color by default
                              // Optionally, if you want to specify a specific text color:
                              textTheme: CupertinoTextThemeData(
                                dateTimePickerTextStyle: TextStyle(
                                  color: Colors
                                      .white, // Set your desired color for date picker text here
                                ),
                              ),
                            ),
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              initialDateTime: selectedDateTime,
                              onDateTimeChanged: (DateTime newDateTime) {
                                // Update your state to the new date time
                              },
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              String formattedTime =
                                  DateFormat('H:m').format(selectedDateTime);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Time Selected'),
                                  content:
                                      Text('You have selected $formattedTime.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ],
                                ),
                              );
                              _onConfirmTimePressed();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent,
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            child: const Text('Confirm Time'),
                          ),
                        ),
                      ],
                    ),
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
            const Spacer(flex: 3),
            buildThumbnailImage(),
            buildDetails(),
            const Spacer(),
            buildDatePicker(),
            buildConfirmButton(),
            const Spacer(flex: 2),
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
        onPressed: () {
          print("object");
          _onConfirmTimePressed();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blueAccent,
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: const Text('Confirm Jhantu'),
      ),
    );
  }

  Future<void> _onConfirmTimePressed() async {
    String selectedTime = DateFormat('H:m').format(selectedDateTime);
    final String? token = await tokenService.getToken();
    print('Token: $token'); // Debug log

    if (token == null) {
      print('Token not available');
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

    try {
      print('Sending data to backend...');
      // Make the API call to save scheduled videos
      final bool result = await apiService.createSchedule(
          widget.playlistSchedule.playlistLink, selectedTime);

      print('API call result: $result');

      if (result) {
        final dateTimeFormatted =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Success'),
            content:
                Text('Playlist scheduled successfully for $dateTimeFormatted.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to schedule the playlist.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Error creating schedule: $error');
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
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    return "$hours:$minutes";
  }
}
