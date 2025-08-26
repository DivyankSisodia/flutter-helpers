import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helper_1/custom/ui.dart';
import 'package:helper_1/riverpod/screen/ui.dart';


void main() {
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirstCustomWidget(),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:helper_1/custom/ui.dart';

// import 'google_meet/google_service.dart';
// import 'google_meet/meeting_screen.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Google Meet Integration',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: CircularStorageWidget(
//           totalStorage: 432,
//           segments: [
//             StorageSegment(
//               value: 219,
//               color: Color(0xFFF5A5C4),
//               label: "219GB",
//               icon: Icons.image_outlined,
//               startAngle: -135, // degrees
//               sweep: 225,
//             ),
//             StorageSegment(
//               value: 165,
//               color: Color(0xFFF7F0B7),
//               label: "165GB",
//               icon: Icons.attachment_outlined,
//               startAngle: -135 + 40,
//               sweep: 160,
//             ),
//             StorageSegment(
//               value: 48,
//               color: Color(0xFFB2F4F0),
//               label: "48GB",
//               icon: Icons.camera_alt_outlined,
//               startAngle: -135 + 90,
//               sweep: 100,
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
// }

// class StorageSegment {
//   final double value;
//   final Color color;
//   final String label;
//   final IconData icon;
//   final double startAngle; // in degrees
//   final double sweep; // in degrees
//   StorageSegment({
//     required this.value,
//     required this.color,
//     required this.label,
//     required this.icon,
//     required this.startAngle,
//     required this.sweep,
//   });
// }

// class CircularStorageWidget extends StatelessWidget {
//   final double totalStorage;
//   final List<StorageSegment> segments;

//   const CircularStorageWidget({
//     Key? key,
//     required this.totalStorage,
//     required this.segments,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 300,
//       height: 300,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           CustomPaint(
//             size: Size(300, 300),
//             painter: CircularSegmentsPainter(segments),
//           ),
//           // Values at end of each arc
//           Positioned(
//             left: 220,
//             top: 62,
//             child: Text(
//               segments[0].label,
//               style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500),
//             ),
//           ),
//           Positioned(
//             left: 138,
//             top: 36,
//             child: Text(
//               segments[1].label,
//               style: TextStyle(
//                   color: Colors.white.withOpacity(0.7),
//                   fontSize: 15,
//                   fontWeight: FontWeight.w400),
//             ),
//           ),
//           Positioned(
//             left: 60,
//             top: 90,
//             child: Text(
//               segments[2].label,
//               style: TextStyle(
//                   color: Colors.white.withOpacity(0.6),
//                   fontSize: 14,
//                   fontWeight: FontWeight.w400),
//             ),
//           ),
//           // Center Main Value
//           Positioned(
//             bottom: 90,
//             child: Column(
//               children: [
//                 Text(
//                   totalStorage.toInt().toString(),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 64,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   "GB",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 32,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Side icons
//           Positioned(
//             left: 120,
//             bottom: 70,
//             child: Icon(
//               segments[0].icon,
//               color: segments[0].color,
//               size: 22,
//             ),
//           ),
//           Positioned(
//             left: 145,
//             bottom: 70,
//             child: Icon(
//               segments[1].icon,
//               color: segments[1].color,
//               size: 22,
//             ),
//           ),
//           Positioned(
//             left: 168,
//             bottom: 70,
//             child: Icon(
//               segments[2].icon,
//               color: segments[2].color,
//               size: 22,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CircularSegmentsPainter extends CustomPainter {
//   final List<StorageSegment> segments;

//   CircularSegmentsPainter(this.segments);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final radii = [130.0, 105.0, 80.0];
//     final strokeWidth = 13.0;
//     for (int i = 0; i < segments.length; i++) {
//       final segment = segments[i];
//       final radius = radii[i];
//       final paint = Paint()
//         ..color = segment.color
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = strokeWidth
//         ..strokeCap = StrokeCap.round;
//       final center = Offset(size.width / 2, size.height / 2);

//       double startRadian = segment.startAngle * 3.14 / 180.0;
//       double sweepRadian = segment.sweep * 3.14 / 180.0;

//       canvas.drawArc(
//         Rect.fromCircle(center: center, radius: radius),
//         startRadian,
//         sweepRadian,
//         false,
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(CircularSegmentsPainter oldDelegate) => true;
// }


// class HomePage extends StatefulWidget {
//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<UserModel> _users = [];
//   List<UserModel> _selectedUsers = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUsers();
//   }

//   // Simulate loading users from your API
//   Future<void> _loadUsers() async {
//     setState(() {
//       _isLoading = true;
//     });

//     // Replace this with your actual API call
//     await Future.delayed(Duration(seconds: 1));
    
//     final users = [
//       UserModel(id: '1', name: 'John Doe', email: 'john@example.com'),
//       UserModel(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
//       UserModel(id: '3', name: 'Bob Johnson', email: 'bob@example.com'),
//       UserModel(id: '4', name: 'Alice Brown', email: 'alice@example.com'),
//       UserModel(id: '5', name: 'Charlie Wilson', email: 'charlie@example.com'),
//     ];

//     setState(() {
//       _users = users;
//       _isLoading = false;
//     });
//   }

//   void _handleSelectedUsersChanged(List<UserModel> selectedUsers) {
//     setState(() {
//       _selectedUsers = selectedUsers;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Meet Integration'),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(16),
//                   color: Colors.blue.shade50,
//                   child: Row(
//                     children: [
//                       Icon(Icons.info, color: Colors.blue),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'Create Google Meet meetings and invite participants from your user list.',
//                           style: TextStyle(color: Colors.blue.shade800),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: MeetingCreatorWidget(
//                     availableUsers: _users,
//                     onUsersChanged: _handleSelectedUsersChanged,
//                   ),
//                 ),
//               ],
//             ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           _showSelectedUsers();
//         },
//         icon: Icon(Icons.people),
//         label: Text('Selected (${_selectedUsers.length})'),
//       ),
//     );
//   }

//   void _showSelectedUsers() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Selected Participants'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: _selectedUsers.map((user) => 
//             ListTile(
//               leading: CircleAvatar(
//                 child: Text(user.name[0].toUpperCase()),
//               ),
//               title: Text(user.name),
//               subtitle: Text(user.email),
//             )
//           ).toList(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Service class to fetch users from your API
// class UserApiService {
//   static Future<List<UserModel>> fetchUsers() async {
//     // Replace with your actual API endpoint
//     try {
//       // final response = await http.get(Uri.parse('your-api-endpoint/users'));
//       // if (response.statusCode == 200) {
//       //   final List<dynamic> jsonData = json.decode(response.body);
//       //   return jsonData.map((json) => UserModel.fromJson(json)).toList();
//       // }
      
//       // Mock data for example
//       return [
//         UserModel(id: '1', name: 'John Doe', email: 'john@example.com'),
//         UserModel(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
//         // Add more users from your API
//       ];
//     } catch (e) {
//       print('Error fetching users: $e');
//       return [];
//     }
//   }
// }