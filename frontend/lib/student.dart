class Student {
  final int id;
  final String first_name;
  final String last_name;
  final String year_level;
  final bool enrolled;
  final String course;

  Student({
    required this.first_name,
    required this.last_name,
    required this.id,
    required this.year_level,
    required this.enrolled,
    required this.course,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
        id: json['id'],
        first_name: json['first_name'],
        last_name: json['last_name'],
        year_level: json['year_level'],
        course: json['course'],
        enrolled: json['enrolled']);
  }
}
