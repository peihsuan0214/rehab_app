import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class FeedbackPage extends StatefulWidget {
  final int taskIndex;
  final String taskName;
  const FeedbackPage({super.key, required this.taskIndex, required this.taskName});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _painLevel = 0;
  String _fatigueLevel = '還好';
  
  final List<String> _fatigueOptions = ['輕鬆', '還好', '有點累', '非常累'];

  String _getPainEmoji(double value) {
    if (value == 0) return '😊';
    if (value <= 3) return '🙂';
    if (value <= 6) return '🤨';
    if (value <= 8) return '😣';
    return '😭';
  }

  String _getPainText(double value) {
    if (value == 0) return '完全無感，很棒！';
    if (value <= 3) return '一點點痠痛，是正常的喔。';
    if (value <= 6) return '有點痛，請多注意休息。';
    if (value <= 8) return '滿痛的！系統明日將為您降低強度。';
    return '痛爆了！請立即停止動作並尋求協助。';
  }

  @override
  Widget build(BuildContext context) {
    Color currentColor = Color.lerp(Colors.green, Colors.red, _painLevel / 10)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 復健完成回報', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade50,
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200, width: 2),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      const Text('🎉 太棒了！', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 8),
                      Text('您已完成「${widget.taskName}」', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Q1: 剛才復健時，感覺會痛嗎？', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_getPainEmoji(_painLevel), style: const TextStyle(fontSize: 48)),
                          const SizedBox(width: 16),
                          Text(
                            '${_painLevel.toInt()} 分', 
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: currentColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_getPainText(_painLevel), style: TextStyle(fontSize: 16, color: currentColor, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 12.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16.0),
                        ),
                        child: Slider(
                          value: _painLevel,
                          min: 0,
                          max: 10,
                          divisions: 10,
                          activeColor: currentColor,
                          inactiveColor: Colors.grey.shade300,
                          onChanged: (double value) {
                            setState(() { _painLevel = value; });
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0分 (無感)', style: TextStyle(color: Colors.grey)),
                            Text('10分 (痛爆)', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Q2: 整體覺得累嗎？', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(), 
                  crossAxisCount: 2, 
                  childAspectRatio: 2.5, 
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: _fatigueOptions.map((option) {
                    bool isSelected = _fatigueLevel == option;
                    return GestureDetector(
                      onTap: () {
                        setState(() { _fatigueLevel = option; });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueAccent : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? Colors.blueAccent : Colors.grey.shade300, width: 2),
                          boxShadow: isSelected ? [BoxShadow(color: Colors.blue.shade200, blurRadius: 8)] : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 36, // 🔥 這裡已經幫你放大到 36 囉！
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32), 

                SizedBox(
                  height: 70, 
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<TaskProvider>().completeTask(widget.taskIndex);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('✅ 紀錄已送出！系統將結合您的痛覺評分自動調整明日菜單。', style: TextStyle(fontSize: 16)),
                          backgroundColor: Colors.green.shade700,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.send, size: 28),
                    label: const Text('送出紀錄', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}