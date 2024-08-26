import 'package:flutter/material.dart';
import 'package:frontend/student.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  final String serverUrl = 'http://192.168.0.108:3000';

  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedylevel;

  final List<String> ylevels = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year'
  ];

  bool isEnrolled = false;

  Future<Student> addStudent(String first_name, String last_name,
      String year_level, bool enrolled) async {
    final response = await http.post(
      Uri.parse('$serverUrl/api/v1/students'),
      headers: {
        'Content-type': 'application/json',
      },
      body: jsonEncode({
        'first_name': first_name,
        'last_name': last_name,
        'year_level': year_level,
        'enrolled': enrolled
      }),
    );
    if (response.statusCode == 201) {
      final dynamic json = jsonDecode(response.body);
      final Student student = Student.fromJson(json);
      return student;
    } else {
      throw Exception('Failed to add a Student');
    }
  }

  Future<void> updateStudent(int id, String first_name, String last_name,
      String year_level, bool enrolled) async {
    final response = await http.put(Uri.parse('$serverUrl/api/v1/students/$id'),
        headers: {
          'Content-type': 'application/json',
        },
        body: jsonEncode({
          'first_name': first_name,
          'last_name': last_name,
          'year_level': year_level,
          'enrolled': enrolled
        }));
    if (response.statusCode != 200) {
      throw Exception('Failed to update Student');
    }
  }

  Future<void> deleteStudent(int id) async {
    final response =
        await http.delete(Uri.parse('$serverUrl/api/v1/students/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete Student');
    }
  }

  Future<List<Student>> fetchItems() async {
    final response = await http.get(Uri.parse('$serverUrl/api/v1/students'));

    if (response.statusCode == 200) {
      final List<dynamic> studentList = jsonDecode(response.body);
      final List<Student> students = studentList.map((student) {
        return Student.fromJson(student);
      }).toList();
      return students;
    } else {
      throw Exception("failed to fetch students");
    }
  }

  void _showStudentDialog({Student? student}) {
    if (student != null) {
      fnameController.text = student.first_name;
      lnameController.text = student.last_name;
      selectedylevel = student.year_level;
      isEnrolled = student.enrolled;
    } else {
      fnameController.clear();
      lnameController.clear();
      selectedylevel = null;
      isEnrolled = false;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(student != null ? 'Edit Student' : 'Add Student'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: fnameController,
                      decoration: const InputDecoration(
                          labelText: 'Student First Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a first name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: lnameController,
                      decoration:
                          const InputDecoration(labelText: 'Student Last Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a last name';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      hint: Text('Select Year Level'),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a year level';
                        }
                        return null;
                      },
                    ),
                    SwitchListTile(
                      title: Text('Enrolled'),
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
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  if (student != null) {
                    updateStudent(
                      student.id,
                      fnameController.text,
                      lnameController.text,
                      selectedylevel!,
                      isEnrolled,
                    ).then((_) {
                      setState(() {});
                      Navigator.pop(context);
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to edit student: $error')),
                      );
                    });
                  } else {
                    addStudent(
                      fnameController.text,
                      lnameController.text,
                      selectedylevel!,
                      isEnrolled,
                    ).then((_) {
                      setState(() {});
                      Navigator.pop(context);
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to add student: $error')),
                      );
                    });
                  }
                }
              },
              child: Text(student != null ? 'Edit' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder(
                future: fetchItems(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final student = snapshot.data![index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                  'Name: ${student.first_name} ${student.last_name}'),
                              subtitle: Text(
                                  'Year level: ${student.year_level} Enrolled: ${student.enrolled}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        await deleteStudent(student.id);
                                        setState(() {});
                                      },
                                      icon: Icon(Icons.delete)),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showStudentDialog(student: student);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showStudentDialog();
        },
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }
}
