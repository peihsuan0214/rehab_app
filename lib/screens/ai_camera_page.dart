import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'feedback_page.dart';

class AiCameraPage extends StatefulWidget {
  final String taskName;
  const AiCameraPage({super.key, required this.taskName});

  @override
  State<AiCameraPage> createState() => _AiCameraPageState();
}

class _AiCameraPageState extends State<AiCameraPage> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _cameraError; 

  int _countdown = 3; 
  bool _isCountingDown = true;
  Timer? _timer;
  
  // ✨ 新增：設定目標次數為 10
  final int _targetReps = 10;
  int _completedReps = 0; 
  bool _isAutoFinishing = false; // 防止重複觸發跳轉的鎖

  late AnimationController _animationController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), 
    )..repeat(reverse: true); 

    _breathAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() { _cameraError = '找不到任何相機設備，請確認筆電鏡頭已開啟！'; });
        return;
      }
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
      await _cameraController!.initialize();
      if (mounted) {
        setState(() { _isCameraInitialized = true; });
        _startCountdown(); 
      }
    } catch (e) {
      if (mounted) {
        setState(() { _cameraError = '相機啟動失敗！請確認瀏覽器已允許相機權限。\n錯誤代碼: $e'; });
      }
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 1) {
        setState(() { _isCountingDown = false; });
        timer.cancel();
      } else {
        setState(() { _countdown--; });
      }
    });
  }

  // ✨ 核心升級：將「結束訓練」的邏輯獨立成一個函數
  void _finishTraining() {
    if (_completedReps == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ 未偵測到復健動作，已取消本次紀錄。'), backgroundColor: Colors.orange, duration: Duration(seconds: 2)));
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FeedbackPage(taskIndex: 0, taskName: widget.taskName)));
    }
  }

  // ✨ 核心升級：統一處理次數增加與自動跳轉的邏輯
  void _incrementReps() {
    if (_isAutoFinishing) return; // 如果正在自動跳轉中，就不再重複計算

    setState(() {
      _completedReps++;
    });

    // 判斷是否達到目標次數
    if (_completedReps >= _targetReps) {
      setState(() {
        _isAutoFinishing = true; // 上鎖，防止使用者連點
      });
      
      // 停頓 0.5 秒，讓阿嬤有時間看到畫面顯示「已完成：10」
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _finishTraining();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraError != null) {
      return Scaffold(backgroundColor: Colors.black, body: Center(child: Padding(padding: const EdgeInsets.all(24.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, color: Colors.redAccent, size: 64), const SizedBox(height: 16), Text(_cameraError!, style: const TextStyle(color: Colors.redAccent, fontSize: 18), textAlign: TextAlign.center), const SizedBox(height: 32), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('返回首頁', style: TextStyle(fontSize: 18)))]))));
    }

    if (!_isCameraInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _breathAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: PosePainter(taskName: widget.taskName, breathOffset: _breathAnimation.value), 
                );
              },
            ),
          ),
          
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 50, bottom: 16, left: 16, right: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black87, Colors.transparent]),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 32), onPressed: () => Navigator.pop(context)),
                  Text(widget.taskName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          if (_isCountingDown)
            Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: Text('$_countdown', style: const TextStyle(fontSize: 100, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

          if (!_isCountingDown)
            Positioned(
              bottom: 40, left: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24, width: 1)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('目標次數：$_targetReps 下', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          // ✨ 修改：點擊時呼叫我們剛寫好的智能增加邏輯
                          onTap: _incrementReps, 
                          child: Text('已完成： $_completedReps', style: const TextStyle(color: Colors.greenAccent, fontSize: 32, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    // ✨ 保留手動結束按鈕，以防阿嬤只做了 5 下就做不下去想提早結束
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _finishTraining, // 直接綁定剛寫好的邏輯
                      child: const Text('結束訓練', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// (PosePainter 畫布程式碼維持不變，節省篇幅直接延續)
class PosePainter extends CustomPainter {
  final String taskName; 
  final double breathOffset; 

  PosePainter({required this.taskName, required this.breathOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBone = Paint()..color = Colors.greenAccent.withValues(alpha: 0.8)..strokeWidth = 4.0..strokeCap = StrokeCap.round;
    final paintJoint = Paint()..color = Colors.redAccent..style = PaintingStyle.fill;

    final head = Offset(size.width * 0.5, size.height * 0.25 + breathOffset);
    final neck = Offset(size.width * 0.5, size.height * 0.35 + breathOffset);
    final leftShoulder = Offset(size.width * 0.35, size.height * 0.35 + breathOffset);
    final rightShoulder = Offset(size.width * 0.65, size.height * 0.35 + breathOffset);
    final spineBottom = Offset(size.width * 0.5, size.height * 0.6);
    final leftHip = Offset(size.width * 0.4, size.height * 0.6);
    final rightHip = Offset(size.width * 0.6, size.height * 0.6);

    late Offset leftElbow, rightElbow, leftWrist, rightWrist, leftKnee, rightKnee, leftAnkle, rightAnkle;

    if (taskName.contains('坐姿抬腿')) {
      leftElbow = Offset(size.width * 0.3, size.height * 0.5 + breathOffset * 0.5);
      rightElbow = Offset(size.width * 0.7, size.height * 0.5 + breathOffset * 0.5);
      leftWrist = Offset(size.width * 0.3, size.height * 0.65 + breathOffset * 0.5); 
      rightWrist = Offset(size.width * 0.7, size.height * 0.65 + breathOffset * 0.5); 
      leftKnee = Offset(size.width * 0.4, size.height * 0.75); 
      leftAnkle = Offset(size.width * 0.4, size.height * 0.9);
      rightKnee = Offset(size.width * 0.8, size.height * 0.6); 
      rightAnkle = Offset(size.width * 1.0, size.height * 0.6);
    } else { 
      leftElbow = Offset(size.width * 0.2, size.height * 0.45 + breathOffset);
      rightElbow = Offset(size.width * 0.8, size.height * 0.45 + breathOffset);
      leftWrist = Offset(size.width * 0.2, size.height * 0.3 + breathOffset); 
      rightWrist = Offset(size.width * 0.8, size.height * 0.3 + breathOffset); 
      leftKnee = Offset(size.width * 0.4, size.height * 0.75); 
      leftAnkle = Offset(size.width * 0.4, size.height * 0.9);
      rightKnee = Offset(size.width * 0.6, size.height * 0.75); 
      rightAnkle = Offset(size.width * 0.6, size.height * 0.9);
    }

    canvas.drawLine(head, neck, paintBone); 
    canvas.drawLine(leftShoulder, rightShoulder, paintBone); 
    canvas.drawLine(neck, spineBottom, paintBone); 
    canvas.drawLine(leftHip, rightHip, paintBone); 
    canvas.drawLine(leftShoulder, leftElbow, paintBone); 
    canvas.drawLine(leftElbow, leftWrist, paintBone);    
    canvas.drawLine(rightShoulder, rightElbow, paintBone); 
    canvas.drawLine(rightElbow, rightWrist, paintBone);    
    canvas.drawLine(leftHip, leftKnee, paintBone);
    canvas.drawLine(leftKnee, leftAnkle, paintBone);
    canvas.drawLine(rightHip, rightKnee, paintBone);
    canvas.drawLine(rightKnee, rightAnkle, paintBone);

    final joints = [head, neck, spineBottom, leftShoulder, rightShoulder, leftHip, rightHip, leftElbow, rightElbow, leftWrist, rightWrist, leftKnee, rightKnee, leftAnkle, rightAnkle];
    final pulseRadius = 8.0 + (breathOffset / 2.5); 
    
    for (var joint in joints) { canvas.drawCircle(joint, pulseRadius, paintJoint); }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) { return true; }
}