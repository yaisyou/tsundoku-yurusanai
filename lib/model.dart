class Task {
  String title;
  int status; // 0:未読 1:読書中 2:読了　4:咀嚼完了

  Task(this.title, [this.status = 0]);
}
