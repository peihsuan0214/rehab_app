import 'package:flutter/material.dart';

class TaskProvider extends ChangeNotifier {
  // 目前登入的病患 ID (預設為 pt1)
  String _currentPatientId = 'pt1';

  // 病患 ID 與名字的對照表
  final Map<String, String> _patientNames = {
    'pt0032': '羅煒翔',    // 👈 替換成你的名字
    'pt0006': '廖奕筑', // 👈 替換成組員的名字
    'pt0011': '李姍芸',    // 👈 替換成組員的名字
    'pt0010': '吳宇梋', // 👈 替換成組員的名字
    'pt0001': '蔡佩諼',    // 👈 替換成組員的名字
  };

  // 🔎 ✨ 新增：健保卡卡號與病患 ID 的對照表 (MVP 測試用)
  final Map<String, String> _nhiCardMap = {
    '001411335032': 'pt0032',
    '001411335006': 'pt0006',
    '001411335011': 'pt0011',
    '001411335010': 'pt0010',
    '001411335001': 'pt0001',
  };

  // 各個病患獨立的復健處方清單字典
  final Map<String, List<Map<String, dynamic>>> _patientTasks = {
    'pt0032': [
      {
        'name': '肩部伸展',
        'setsAndReps': '3組 10下',
        'estimatedTime': '5 分鐘',
        'isCompleted': false,
      },
    ],
    'pt0006': [
      {
        'name': '坐姿抬腿',
        'setsAndReps': '3組 15下',
        'estimatedTime': '8 分鐘',
        'isCompleted': false,
      },
    ],
    'pt0011': [],
    'pt0010': [],
    'pt0001': [],
  };

  // 提供外部讀取的 Getter
  Map<String, String> get patientNames => _patientNames;
  String get currentPatientId => _currentPatientId;

  // 取得目前登入病患的名字
  String get currentPatientName => _patientNames[_currentPatientId] ?? '未知病患';

  // 取得目前登入病患目前的復健清單
  List<Map<String, dynamic>> get tasks => _patientTasks[_currentPatientId] ?? [];

  // 提供給醫師端：取得特定病患的任務清單
  List<Map<String, dynamic>> getTasksFor(String ptId) {
    return _patientTasks[ptId] ?? [];
  }

  // 計算目前病患的完成率
  double get completionRate {
    final currentTasks = tasks;
    if (currentTasks.isEmpty) return 0.0;
    int completedCount = currentTasks.where((task) => task['isCompleted'] == true).length;
    return completedCount / currentTasks.length;
  }

  // 設定目前登入的使用者 ID
  void setCurrentPatient(String ptId) {
    _currentPatientId = ptId;
    notifyListeners();
  }

  // 🔎 ✨ 新增：透過健保卡號登入的判斷邏輯
  bool loginWithNhiCard(String cardNum) {
    if (_nhiCardMap.containsKey(cardNum)) {
      _currentPatientId = _nhiCardMap[cardNum]!;
      notifyListeners();
      return true; // 找到了，登入成功
    }
    return false; // 找不到這個卡號
  }

  // 標記任務完成
  void completeTask(int index) {
    final currentTasks = tasks;
    if (index >= 0 && index < currentTasks.length) {
      currentTasks[index]['isCompleted'] = true;
      notifyListeners();
    }
  }

  // 醫師開立處方功能 (修正參數：病患ID, 動作名稱, 組數, 時間)
  void addTask(String ptId, String name, String sets, String time) {
    if (!_patientTasks.containsKey(ptId)) {
      _patientTasks[ptId] = [];
    }
    _patientTasks[ptId]!.add({
      'name': name,
      'setsAndReps': sets,
      'estimatedTime': time,
      'isCompleted': false,
    });
    notifyListeners();
  }
}