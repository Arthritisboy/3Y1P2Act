import 'package:flutter/material.dart';
import 'package:frontend/edit_student.dart';
import 'package:frontend/student.dart'; // Adjust this import as necessary
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import the edit screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String serverUrl = 'http://192.168.0.104:3000'; // Adjust to your server

  Future<List<Student>> fetchItems() async {
    final response = await http.get(Uri.parse('$serverUrl/api/v1/students'));
    if (response.statusCode == 200) {
      final List<dynamic> studentList = jsonDecode(response.body);
      return studentList.map((student) => Student.fromJson(student)).toList();
    } else {
      throw Exception("Failed to fetch students");
    }
  }

  void _showAddStudentDialog() {
    final TextEditingController fnameController = TextEditingController();
    final TextEditingController lnameController = TextEditingController();
    String? selectedylevel;
    String? selectedCourse;
    bool isEnrolled = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Student'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: fnameController,
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
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
                      items: [
                        'First Year',
                        'Second Year',
                        'Third Year',
                        'Fourth Year'
                      ].map((String year) {
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
                      items: ['BSIT', 'BSCE', 'BSA', 'BSEE', 'BSN', 'BSBA']
                          .map((String course) {
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
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                addStudent(fnameController.text, lnameController.text,
                        selectedylevel!, selectedCourse!, isEnrolled)
                    .then((_) {
                  setState(() {});
                  Navigator.pop(context);
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add student: $error')),
                  );
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addStudent(String first_name, String last_name,
      String year_level, String course, bool enrolled) async {
    final response = await http.post(
      Uri.parse('$serverUrl/api/v1/students'),
      headers: {
        'Content-type': 'application/json',
      },
      body: jsonEncode({
        'first_name': first_name,
        'last_name': last_name,
        'year_level': year_level,
        'course': course,
        'enrolled': enrolled,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add Student');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management List'),
        backgroundColor: Colors.greenAccent,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Student>>(
          future: fetchItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final students = snapshot.data!;
              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text('${student.first_name} ${student.last_name}'),
                      subtitle: Text(
                          'Course: ${student.course}\nYear Level: ${student.year_level}\nEnrolled: ${student.enrolled}'),
                      onTap: () {
                        // Navigate to the edit screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditStudentScreen(student: student),
                          ),
                        ).then((_) {
                          // Refresh the list when returning
                          setState(() {});
                        });
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }
}
