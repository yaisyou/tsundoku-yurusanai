import 'package:flutter/material.dart';
import 'model.dart';
import 'view_model.dart';

final names = ['未読', '読書中', '読了', '咀嚼完了'];

final labels = ['未読', '読書中', '読了', '咀嚼完了'];

final colors = [
  Colors.red.shade50,
  Colors.yellow.shade50,
  Colors.green.shade50,
  Colors.blue.shade50,
];

class KanbanView extends StatefulWidget {
  final KanbanViewModel vm;

  KanbanView(this.vm, {super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  final input = TextEditingController();

  // タスクを追加する
  void add() {
    widget.vm.add(input.text);
    input.clear();
  }

  // タスクを編集する
  Future<void> edit(Task t) async {
    var text = t.title;

    final result = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('タスクを編集'),
        content: TextFormField(
          initialValue: text,
          autofocus: true,
          onChanged: (v) => text = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text('キャンセル')),
          FilledButton(
            onPressed: () => Navigator.pop(c, text),
            child: Text('保存'),
          ),
        ],
      ),
    );

    if (result != null) {
      widget.vm.rename(t, result);
    }
  }

  // タスクのカードを作成する
  Widget taskCard(Task t) {
    final s = t.status;

    final buttons = Wrap(
      spacing: 4,
      children: [
        // 左へ移動
        if (s > 0)
          TextButton(
            onPressed: () => widget.vm.move(t, s - 1),
            child: Text('← ${labels[s - 1]}へ'),
          ),

        // 右へ移動
        if (s < 3)
          FilledButton(
            onPressed: () => widget.vm.move(t, s + 1),
            child: Text('${labels[s + 1]}へ →'),
          ),
      ],
    );

    return Card(
      child: ListTile(
        title: Text(t.title),
        subtitle: buttons,

        // 編集・削除ボタン
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.edit), onPressed: () => edit(t)),
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () => widget.vm.remove(t),
            ),
          ],
        ),
      ),
    );
  }

  // 各列を作成する
  Widget lane(int s) {
    final cards = [
      for (final t in widget.vm.tasks)
        if (t.status == s) taskCard(t),
    ];

    return SizedBox(
      width: 300,
      child: Card(
        color: colors[s],
        child: Column(
          children: [
            ListTile(title: Text(names[s]), trailing: Text('${cards.length}件')),
            Expanded(child: ListView(children: cards)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  // 画面全体を作成する
  @override
  Widget build(BuildContext context) {
    // 入力欄
    final field = TextField(
      controller: input,
      decoration: InputDecoration(
        labelText: '新しいタスク',
        hintText: '例：レポートを書く',
        border: OutlineInputBorder(),
      ),
    );

    // 追加ボタン
    final button = ValueListenableBuilder(
      valueListenable: input,
      builder: (context, value, child) => FilledButton.icon(
        onPressed: value.text.isEmpty ? null : add,
        icon: Icon(Icons.add),
        label: Text('未着手に追加'),
      ),
    );

    // 入力部分
    final entry = Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            field,
            Align(alignment: Alignment.centerRight, child: button),
          ],
        ),
      ),
    );

    // Kanbanボード
    final board = ListenableBuilder(
      listenable: widget.vm,
      builder: (context, child) => ListView(
        scrollDirection: Axis.horizontal,
        children: [for (int s = 0; s < 4; s++) lane(s)],
      ),
    );

    // 画面全体
    return Scaffold(
      appBar: AppBar(title: Text('📚❌積読絶対させないサイト❌📚')),
      body: Column(
        children: [
          entry,
          Expanded(child: board),
        ],
      ),
    );
  }
}
