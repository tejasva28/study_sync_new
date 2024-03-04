// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:study_sync/Models/video_model.dart';
// import 'package:study_sync/models/home_page_model.dart';
// import '../Models/time_scheduling_model.dart';


// class MonthDateRow extends StatelessWidget {
//   const MonthDateRow({Key? key, required this.selectedDateTime}) : super(key: key);
  
//   final DateTime selectedDateTime;

//   Widget _buildScheduledVideo(BuildContext context, VideoModel video) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Icon(Icons.video_library),
//         title: Text(video.title),
//         subtitle: Text(video.videoUrl), // Or another property as needed
//         trailing: Text(DateFormat.jm().format(video.scheduledDate!)), // Assuming scheduledDate is not null
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your Schedule'),
//         backgroundColor: Colors.blue,
//       ),
//       body: ListView.builder(
//         // itemCount: PlaylistSchedule.length,
//         itemBuilder: (context, index) {
//           // final schedule = PlaylistSchedule[index];
//          // return ExpansionTile(
//           //   title: Text(schedule.playlistTitle),
//           //   subtitle: Text(DateFormat('yyyy-MM-dd').format(schedule.selectedDateTime)),
//           //   children: schedule.videos.map((video) => _buildScheduledVideo(context, video)).toList(),
//            );
//         },
//       ),
//     );
//   }
// }
// //     List<PlaylistSchedule> PlaylistSchedule = [
// //     PlaylistSchedule(
// //       date: DateTime.now().add(Duration(days: 1)),
// //     time: '10 AM',
// //      title: 'Video Title 1',
// //          description: 'Description of the video or other details',   ),
// //  ];

//   Widget _buildMonthDateContainer(BuildContext context) {
//     // Define your _buildMonthDateContainer method here
//     return Container(); // Replace with actual implementation
//   }

//   Widget _buildImageWithText(BuildContext context) {
//     // Define your _buildImageWithText method here
//     return Container(); // Replace with actual implementation
//   }

//   Widget _buildScheduleList(BuildContext context) {
//     return ListView.builder(
//       itemCount: 15, // Number of days to display
//       itemBuilder: (context, index) {
//         // The date can be dynamically generated or fetched from a list
//         DateTime date = DateTime.now().add(Duration(days: index));
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               DateFormat('EEEE, MMM d').format(date), // Shows day of the week, Month day
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             _buildScheduledVideo(context, '10 AM', 'Video Title 1', 'Description of the video or other details'),
//             _buildScheduledVideo(context, '3 PM', 'Video Title 2', 'Description of the video or other details'),
//             _buildScheduledVideo(context, '8 PM', 'Video Title 3', 'Description of the video or other details'),
//             SizedBox(height: 20),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildScheduledVideo(BuildContext context, String time, String title, String description) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Icon(Icons.video_library), // Can be replaced with an appropriate image or icon
//         title: Text(title),
//         subtitle: Text(description),
//         trailing: Text(time),
//       ),
//     );
//   }

// void main() {
//   runApp(MaterialApp(
//     home: MonthDateRow(playlistSchedules: [],),
//   ));
// }
