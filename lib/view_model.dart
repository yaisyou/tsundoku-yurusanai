import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';

class KanbanViewModel extends ChangeNotifier {
  final prefs = SharedPreferencesAsync();
  final tasks = <Task>[];

  // 保存したタスクを読み込む
  Future<void> load() async {
    final data = await prefs.getString('kanban');
    if (data == null) return;

    tasks.clear();

    for (final t in jsonDecode(data)) {
      tasks.add(Task(t['title'], t['status']));
    }
  }

  // タスクを保存する
  Future<void> save() async {
    notifyListeners();

    final data = [
      for (final t in tasks) {'title': t.title, 'status': t.status},
    ];

    await prefs.setString('kanban', jsonEncode(data));
  }

  // タスクを追加する
  void add(String text) {
    tasks.add(Task(text));
    save();
  }

  // タスクを移動する
  void move(Task t, int status) {
    t.status = status;
    save();
  }

  // タスク名を変更する
  void rename(Task t, String text) {
    t.title = text;
    save();
  }

  // タスクを削除する
  void remove(Task t) {
    tasks.remove(t);
    save();
  }
}
