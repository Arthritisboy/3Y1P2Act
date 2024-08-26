const express = require("express");

//App config
const app = express();

const port = 3000;

//Middleware config
app.use(express.json());

//Define Item list
let studentList = [
  {
    id: 1,
    first_name: "first name",
    last_name: "last name",
    year_level: "Year level",
    enrolled: true,
  },
];

//Routes
app.get("/api/v1/students", (req, res) => {
  return res.json(studentList);
});
app.post("/api/v1/students", (req, res) => {
  let newStudent = {
    id: studentList.length + 1,
    first_name: req.body.first_name,
    last_name: req.body.last_name,
    year_level: req.body.year_level,
    enrolled: req.body.enrolled,
  };
  studentList.push(newStudent);
  res.status(201).json(newStudent);
});
app.put("/api/v1/students/:id", (req, res) => {
  let studentId = +req.params.id;
  let updatedStudent = {
    id: studentId,
    first_name: req.body.first_name,
    last_name: req.body.last_name,
    year_level: req.body.year_level,
    enrolled: req.body.enrolled,
  };
  let index = studentList.findIndex((student) => student.id === studentId);

  if (index !== -1) {
    studentList[index] = updatedStudent;
    res.json(updatedStudent);
  } else {
    res.status(404).json({ message: "Student not found" });
  }
});
app.delete("/api/v1/students/:id", (req, res) => {
  let studentId = +req.params.id;
  let index = studentList.findIndex((student) => student.id === studentId);

  if (index !== -1) {
    let deletedStudent = studentList.splice(index, 1);
    res.json(deletedStudent[0]);
  } else {
    res.status(404);
  }
});

//Listeners
app.listen(port, () => {
  console.log(`listening on port ${port}`);
});
