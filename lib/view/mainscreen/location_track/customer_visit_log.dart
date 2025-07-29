// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Customer Visit Logger',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: CustomerVisitLogger(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class Visit {
//   final String id;
//   final String customerName;
//   final String description;
//   final DateTime timestamp;

//   Visit({
//     required this.id,
//     required this.customerName,
//     required this.description,
//     required this.timestamp,
//   });
// }

// class CustomerVisitLogger extends StatefulWidget {
//   @override
//   _CustomerVisitLoggerState createState() => _CustomerVisitLoggerState();
// }

// class _CustomerVisitLoggerState extends State<CustomerVisitLogger> {
//   final TextEditingController _customerNameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final List<Visit> _visits = [];
//   bool _showSuccess = false;

//   @override
//   void dispose() {
//     _customerNameController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   void _logVisit() {
//     if (_customerNameController.text.trim().isEmpty ||
//         _descriptionController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please fill in both customer name and description'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     final newVisit = Visit(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       customerName: _customerNameController.text.trim(),
//       description: _descriptionController.text.trim(),
//       timestamp: DateTime.now(),
//     );

//     setState(() {
//       _visits.insert(0, newVisit);
//       _customerNameController.clear();
//       _descriptionController.clear();
//       _showSuccess = true;
//     });

//     // Hide success message after 3 seconds
//     Future.delayed(Duration(seconds: 3), () {
//       if (mounted) {
//         setState(() {
//           _showSuccess = false;
//         });
//       }
//     });
//   }

//   void _clearForm() {
//     setState(() {
//       _customerNameController.clear();
//       _descriptionController.clear();
//     });
//   }

//   String _formatDateTime(DateTime dateTime) {
//     return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
//   }

//   void _showClearAllDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Clear All Visits'),
//           content: Text('Are you sure you want to clear all logged visits? This action cannot be undone.'),
//           actions: [
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Clear All', style: TextStyle(color: Colors.red)),
//               onPressed: () {
//                 setState(() {
//                   _visits.clear();
//                 });
//                 Navigator.of(context).pop();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('All visits cleared'),
//                     backgroundColor: Colors.orange,
//                   ),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showExportDialog() {
//     if (_visits.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('No visits to export'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Export Data'),
//           content: Text('Export functionality would save ${_visits.length} visits to a file. This feature can be implemented with file_picker and path_provider packages.'),
//           actions: [
//             TextButton(
//               child: Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Icon(
//               Icons.location_on,
//               color: Colors.white,
//               size: 24,
//             ),
//             SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Field Visit Logger',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   'Log customer visits',
//                   style: TextStyle(
//                     color: Colors.blue[100],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         backgroundColor: Colors.blue[600],
//         elevation: 4,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.info_outline, color: Colors.white),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: Text('About'),
//                     content: Text('Field Visit Logger v1.0\n\nTrack and log customer visits with timestamps and descriptions.'),
//                     actions: [
//                       TextButton(
//                         child: Text('OK'),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//           ),
//           PopupMenuButton<String>(
//             icon: Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (String value) {
//               switch (value) {
//                 case 'clear_all':
//                   _showClearAllDialog();
//                   break;
//                 case 'export':
//                   _showExportDialog();
//                   break;
//               }
//             },
//             itemBuilder: (BuildContext context) => [
//               PopupMenuItem<String>(
//                 value: 'clear_all',
//                 child: Row(
//                   children: [
//                     Icon(Icons.clear_all, size: 18),
//                     SizedBox(width: 8),
//                     Text('Clear All Visits'),
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'export',
//                 child: Row(
//                   children: [
//                     Icon(Icons.download, size: 18),
//                     SizedBox(width: 8),
//                     Text('Export Data'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [

//               // Success Message
//               if (_showSuccess)
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(12),
//                   color: Colors.green,
//                   child: Row(
//                     children: [
//                       Icon(Icons.check, color: Colors.white, size: 20),
//                       SizedBox(width: 8),
//                       Text(
//                         'Visit logged successfully!',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),

//               // Form
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Customer Name Field
//                     Text(
//                       'Customer Name *',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     TextField(
//                       controller: _customerNameController,
//                       decoration: InputDecoration(
//                         hintText: 'Enter customer name',
//                         prefixIcon: Icon(Icons.person, color: Colors.grey[400]),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.blue, width: 2),
//                         ),
//                         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       ),
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     SizedBox(height: 16),

//                     // Description Field
//                     Text(
//                       'Visit Description *',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     TextField(
//                       controller: _descriptionController,
//                       maxLines: 4,
//                       decoration: InputDecoration(
//                         hintText: 'Describe the purpose of visit, work done, or notes...',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.blue, width: 2),
//                         ),
//                         contentPadding: EdgeInsets.all(16),
//                       ),
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     SizedBox(height: 24),

//                     // Buttons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: _logVisit,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue[600],
//                               foregroundColor: Colors.white,
//                               padding: EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.check, size: 20),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   'Log Visit',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         OutlinedButton(
//                           onPressed: _clearForm,
//                           style: OutlinedButton.styleFrom(
//                             padding: EdgeInsets.all(16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: Icon(Icons.clear, size: 20),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Visit History
//               if (_visits.isNotEmpty) ...[
//                 SizedBox(height: 16),
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(12),
//                         bottomRight: Radius.circular(12),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 8,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         // Header
//                         Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             border: Border(
//                               bottom: BorderSide(color: Colors.grey[200]!),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
//                               SizedBox(width: 8),
//                               Text(
//                                 'Recent Visits (${_visits.length})',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.grey[800],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         // Visit List
//                         Expanded(
//                           child: ListView.builder(
//                             itemCount: _visits.length,
//                             itemBuilder: (context, index) {
//                               final visit = _visits[index];
//                               return Container(
//                                 padding: EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   border: Border(
//                                     bottom: BorderSide(color: Colors.grey[100]!),
//                                   ),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             visit.customerName,
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.w500,
//                                               color: Colors.grey[900],
//                                             ),
//                                           ),
//                                         ),
//                                         Text(
//                                           _formatDateTime(visit.timestamp),
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey[500],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 8),
//                                     Text(
//                                       visit.description,
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey[600],
//                                         height: 1.4,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],

//               // Footer
//               SizedBox(height: 24),
//               Text(
//                 '${DateFormat('MMM dd, yyyy').format(DateTime.now())} • Field Worker App',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[500],
//                 ),
//               ),
//     );
//   }
// }
// }
