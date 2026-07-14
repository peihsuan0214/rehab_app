import 'package:flutter/material.dart';
import '../screens/feedback_page.dart';
import '../screens/ai_camera_page.dart'; 

class DailyTaskCard extends StatelessWidget {
  final int taskIndex; 
  final String taskName;
  final String setsAndReps;
  final String estimatedTime;
  final bool isCompleted; 

  const DailyTaskCard({
    super.key,
    required this.taskIndex,
    required this.taskName,
    required this.setsAndReps,
    required this.estimatedTime,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isCompleted ? 1.0 : 4.0, 
      color: isCompleted ? Colors.grey.shade100 : Colors.white, 
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$taskName ${isCompleted ? "(✅ 已完成)" : "(🔥 準備開始)"}',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.grey : Colors.black, 
              ),
            ),
            const SizedBox(height: 12),
            Text('建議組數：$setsAndReps', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('預估時間：$estimatedTime', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, 
              height: 60, 
              child: ElevatedButton.icon(
                // 🟢 正常流程：點擊跳轉至相機畫面
                onPressed: isCompleted ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AiCameraPage(taskName: taskName),
                    ),
                  );
                },
                // 🔴 開發者捷徑：長按直接跳轉至回報頁面
                onLongPress: isCompleted ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedbackPage(taskIndex: taskIndex, taskName: taskName),
                    ),
                  );
                },
                icon: Icon(isCompleted ? Icons.check : Icons.play_arrow, size: 28),
                label: Text(
                  isCompleted ? '任務已達成' : '開始復健',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}