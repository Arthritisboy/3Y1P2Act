import 'package:flutter/material.dart';
import 'package:frontend/student.dart'; // Adjust as necessary
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditStudentScreen extends StatefulWidget {
  final Student student;

  const EditStudentScreen({required this.student, Key? key}) : super(key: key);

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final String serverUrl = 'http://192.168.0.104:3000'; // Adjust as necessary

  late TextEditingController fnameController;
  late TextEditingController lnameController;
  String? selectedylevel;
  String? selectedCourse;
  bool isEnrolled = false;

  final List<String> ylevels = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year',
  ];

  final List<String> courses = ['BSIT', 'BSCE', 'BSA', 'BSEE', 'BSN', 'BSBA'];

  @override
  void initState() {
    super.initState();
    fnameController = TextEditingController(text: widget.student.first_name);
    lnameController = TextEditingController(text: widget.student.last_name);
    selectedylevel = widget.student.year_level;
    selectedCourse = widget.student.course;
    isEnrolled = widget.student.enrolled;
  }

  Future<void> updateStudent() async {
    final response = await http.put(
      Uri.parse('$serverUrl/api/v1/students/${widget.student.id}'),
      headers: {
        'Content-type': 'application/json',
      },
      body: jsonEncode({
        'first_name': fnameController.text,
        'last_name': lnameController.text,
        'year_level': selectedylevel,
        'course': selectedCourse,
        'enrolled': isEnrolled,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update Student');
    }
  }

  Future<void> deleteStudent() async {
    final response = await http
        .delete(Uri.parse('$serverUrl/api/v1/students/${widget.student.id}'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete Student');
    }
  }

  @override
  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: fnameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: lnameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              DropdownButtonFormField<String>(
                hint: const Text('Select Year Level'),
                value: selectedylevel,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedylevel = newValue;
                  });
                },
                items: ylevels.map((String year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<String>(
                hint: const Text('Select Course'),
                value: selectedCourse,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCourse = newValue;
                  });
                },
                items: courses.map((String course) {
                  return DropdownMenuItem<String>(
                    value: course,
                    child: Text(course),
                  );
                }).toList(),
              ),
              SwitchListTile(
                title: const Text('Enrolled'),
                value: isEnrolled,
                onChanged: (value) {
                  setState(() {
                    isEnrolled = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      updateStudent().then((_) {
                        Navigator.pop(
                            context, true); // Return true to indicate success
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Failed to update student: $error')),
                        );
                      });
                    },
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      deleteStudent().then((_) {
                        Navigator.pop(context,
                            false); // Return false to indicate deletion
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Failed to delete student: $error')),
                        );
                      });
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
