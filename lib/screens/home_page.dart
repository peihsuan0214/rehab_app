import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/daily_task_card.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _textScale = 1.0; 

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return '早安';
    if (hour < 18) return '午安';
    return '晚安';
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('夢醒淑芬 - 病患端', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '登出系統',
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✨ 動態讀取當前登入使用者的名字
                      Text(
                        '${getGreeting()}，${taskProvider.currentPatientName}！', 
                        style: TextStyle(fontSize: 24 * _textScale, fontWeight: FontWeight.bold)
                      ),
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.accessibility_new, size: 36, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.text_fields, color: Colors.grey),
                      Expanded(
                        child: Slider(
                          value: _textScale,
                          min: 0.8,
                          max: 1.5,
                          activeColor: Colors.blueAccent,
                          onChanged: (val) { setState(() { _textScale = val; }); },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('今日復健進度', style: TextStyle(fontSize: 18 * _textScale, fontWeight: FontWeight.bold)),
                      Text('${(taskProvider.completionRate * 100).toInt()}%', style: TextStyle(fontSize: 18 * _textScale, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: taskProvider.completionRate,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.green,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('目前沒有復健任務喔！\n請聯絡醫師開立處方。', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_textScale)),
                          child: DailyTaskCard(
                            taskIndex: index,
                            taskName: task['name'],
                            setsAndReps: task['setsAndReps'],
                            estimatedTime: task['estimatedTime'],
                            isCompleted: task['isCompleted'],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}