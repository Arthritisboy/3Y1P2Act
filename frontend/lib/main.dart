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
                                      fnameController.text = student.first_name;
                                      lnameController.text = student.last_name;
                                      selectedylevel = student.year_level;
                                      isEnrolled = student.enrolled;
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Edit Student'),
                                              content: StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      TextFormField(
                                                        controller:
                                                            fnameController,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Student First Name'),
                                                      ),
                                                      TextFormField(
                                                        controller:
                                                            lnameController,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Student Last Name'),
                                                      ),
                                                      DropdownButton<String>(
                                                        hint: Text(
                                                            'Select Year Level'),
                                                        value: selectedylevel,
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState(() {
                                                            selectedylevel =
                                                                newValue;
                                                          });
                                                        },
                                                        items: ylevels
                                                            .map((String year) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: year,
                                                            child: Text(year),
                                                          );
                                                        }).toList(),
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
                                                    if (selectedylevel !=
                                                        null) {
                                                      updateStudent(
                                                        student.id,
                                                        fnameController.text,
                                                        lnameController.text,
                                                        selectedylevel!,
                                                        isEnrolled,
                                                      ).then((_) {
                                                        setState(() {
                                                          fnameController
                                                              .clear();
                                                          lnameController
                                                              .clear();
                                                          selectedylevel = null;
                                                        });
                                                        Navigator.pop(context);
                                                      }).catchError((error) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                'Failed to edit student: $error'),
                                                          ),
                                                        );
                                                      });
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Please select a year level.'),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Text('Edit'),
                                                ),
                                              ],
                                            );
                                          });
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
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Add Student'),
                  content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: fnameController,
                            decoration: const InputDecoration(
                                labelText: 'Student First Name'),
                          ),
                          TextFormField(
                            controller: lnameController,
                            decoration: const InputDecoration(
                                labelText: 'Student Last Name'),
                          ),
                          DropdownButton<String>(
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
                        if (selectedylevel != null) {
                          addStudent(
                            fnameController.text,
                            lnameController.text,
                            selectedylevel!,
                            isEnrolled,
                          ).then((_) {
                            setState(() {
                              fnameController.clear();
                              lnameController.clear();
                              selectedylevel = null;
                            });
                            Navigator.pop(context);
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to add student: $error'),
                              ),
                            );
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select a year level.'),
                            ),
                          );
                        }
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              });
        },
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }
}
