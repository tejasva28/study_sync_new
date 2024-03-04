import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:study_sync/Pages/time_scheduling_page.dart';
import 'dart:convert';
import '../Models/time_scheduling_model.dart'; // Ensure this path is correct

Future<Map<String, dynamic>> fetchPlaylistDetails(String playlistUrl) async {
  print('Fetching details for URL: $playlistUrl');
  final playlistId = extractPlaylistId(playlistUrl);
  print('Extracted playlist ID: $playlistId');

  final response = await http.get(
    Uri.parse('http://10.0.2.2:4000/api/playlist/$playlistId/details'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load playlist details');
  }
}

String extractPlaylistId(String playlistUrl) {
  final uri = Uri.tryParse(playlistUrl);
  return uri?.queryParameters['list'] ??
      ''; // Ensures a default empty string is returned if null
}

class VideoAdd extends StatelessWidget {
  final TextEditingController textController = TextEditingController();
  final FocusNode textFieldFocusNode = FocusNode();

  VideoAdd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Playlist'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Icon(Icons.link, size: 100, color: Colors.black)),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "Please paste the link below and Press Add Playlist button",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: textController,
                focusNode: textFieldFocusNode,
                decoration: InputDecoration(
                  labelText: 'Paste the link here',
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      EdgeInsetsDirectional.fromSTEB(20, 32, 20, 12),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final playlistDetails =
                          await fetchPlaylistDetails(textController.text);
                      // Assuming default values for videoCount and totalDuration if they are not provided
                      final videoCount =
                          playlistDetails['videoCount'] as int? ??
                              0; // Default to 0 if null
                      final totalDurationSeconds =
                          playlistDetails['totalDurationSeconds'] as int? ??
                              0; // Default to 0 if null
                      final totalDuration =
                          Duration(seconds: totalDurationSeconds);

                      final playlistSchedule = PlaylistSchedule(
                        playlistLink: textController
                            .text, // Assuming this is always non-null
                        playlistTitle: playlistDetails['title'] ??
                            'Default Title', // Providing a default value
                        thumbnailUrl: playlistDetails['thumbnails']['default']
                                ['url'] ??
                            'default_thumbnail_url', // Handling potential nulls
                        selectedDateTime: DateTime
                            .now(), // Assuming you want the current time as the default
                        videoCount: videoCount,
                        totalDuration: totalDuration, videos: [],
                      );
                      // Navigate to TimeSchedulingPage with the PlaylistSchedule object
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimeSchedulingPage(
                              playlistSchedule: playlistSchedule),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: Text('Add Playlist'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue, onPrimary: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
