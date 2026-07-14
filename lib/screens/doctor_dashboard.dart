import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'login_page.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  String? _selectedPatientId;

  // 🎯 定義基礎復健動作資料庫
  // 🎯 升級：擴充至 30 個全方位臨床復健動作連動資料庫
  final List<Map<String, dynamic>> _presetExercises = [
    {"id": "ex_001", "title": "肩部伸展", "default_sets": "3組 (重複5次，每組維持30秒)", "default_minutes": "5 分鐘"},
    {"id": "ex_002", "title": "坐姿抬腿", "default_sets": "3組 12下 (抬起撐5秒)", "default_minutes": "5 分鐘"},
    {"id": "ex_003", "title": "靠牆深蹲", "default_sets": "3組 (每組維持30秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_004", "title": "直腿抬高", "default_sets": "3組 10下 (抬起撐6秒)", "default_minutes": "5 分鐘"},
    {"id": "ex_005", "title": "臀橋訓練", "default_sets": "3組 12下 (抬高撐5秒)", "default_minutes": "6 分鐘"},
    {"id": "ex_006", "title": "門框擴胸伸展", "default_sets": "3組 (重複5次，每組維持20秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_007", "title": "雙腳提踵", "default_sets": "3組 15下 (踮起撐2秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_008", "title": "毛巾抓握訓練", "default_sets": "3組 (重複抓握15次)", "default_minutes": "5 分鐘"},
    {"id": "ex_009", "title": "坐姿軀幹轉體", "default_sets": "3組 (左右各10次，轉到底撐5秒)", "default_minutes": "5 分鐘"},
    {"id": "ex_010", "title": "貓狗式伸展", "default_sets": "3組 (重複10個循環)", "default_minutes": "5 分鐘"},
    {"id": "ex_011", "title": "頸部側向伸展", "default_sets": "3組 (左右各維持30秒，重複3次)", "default_minutes": "4 分鐘"},
    {"id": "ex_012", "title": "坐姿雙手收雙下巴", "default_sets": "3組 10下 (每次縮緊維持5秒)", "default_minutes": "3 分鐘"},
    {"id": "ex_013", "title": "手腕伸展 (拉前臂)", "default_sets": "3組 (兩手各維持30秒，重複3次)", "default_minutes": "4 分鐘"},
    {"id": "ex_014", "title": "握拳與張手訓練", "default_sets": "3組 (反覆出力握放20次)", "default_minutes": "3 分鐘"},
    {"id": "ex_015", "title": "肩胛骨後收 (夾背)", "default_sets": "3組 15下 (每次夾緊背部3秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_016", "title": "爬牆運動 (五十肩)", "default_sets": "3組 (緩慢反覆爬牆5次)", "default_minutes": "5 分鐘"},
    {"id": "ex_017", "title": "毛巾開口笑 (肩外旋)", "default_sets": "3組 12下 (手肘貼身外張撐3秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_018", "title": "仰臥胸椎轉體", "default_sets": "3組 (左右各8次，轉到底雙肩貼地)", "default_minutes": "5 分鐘"},
    {"id": "ex_019", "title": "鳥狗式核心訓練", "default_sets": "3組 (對側手腳伸直，左右交替共20下)", "default_minutes": "6 分鐘"},
    {"id": "ex_020", "title": "死蟲式核心訓練", "default_sets": "3組 (下背貼地，對側手腳下放共20下)", "default_minutes": "6 分鐘"},
    {"id": "ex_021", "title": "側躺貝殼側展 (臀中肌)", "default_sets": "3組 (每邊各15下，雙腳跟併攏張開)", "default_minutes": "5 分鐘"},
    {"id": "ex_022", "title": "側躺外展抬腿", "default_sets": "3組 (每邊各12下，大腿伸直側抬高)", "default_minutes": "4 分鐘"},
    {"id": "ex_023", "title": "單腳站立平衡 (防跌)", "default_sets": "3組 (每邊單腳維持不扶平衡30秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_024", "title": "坐姿膝關節伸直壓膝", "default_sets": "3組 (每邊各維持輕壓伸直20秒，3次)", "default_minutes": "4 分鐘"},
    {"id": "ex_025", "title": "腳踝幫浦運動 (消腫)", "default_sets": "3組 (雙腳尖反覆用力勾起、踩平30次)", "default_minutes": "3 分鐘"},
    {"id": "ex_026", "title": "坐姿起立訓練", "default_sets": "3組 (椅子前半部控制起立坐下10次)", "default_minutes": "5 分鐘"},
    {"id": "ex_027", "title": "毛巾拉大腿後側肌", "default_sets": "3組 (每邊用毛巾套腳底直腿拉抬30秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_028", "title": "髖關節抱膝伸展", "default_sets": "3組 (每邊雙手抱小腿往胸口拉近30秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_029", "title": "髂脛束與大腿外側伸展", "default_sets": "3組 (每邊坐姿跨腿用對側肘頂膝轉體30秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_030", "title": "跪姿髖屈肌伸展 (弓步)", "default_sets": "3組 (每邊單膝跪姿骨盆前推維持20秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_031", "title": "橡皮帶肩內旋訓練", "default_sets": "3組 12下 (前臂抗阻拉向身體中線)", "default_minutes": "5 分鐘"},
    {"id": "ex_032", "title": "橡皮帶肩外旋訓練", "default_sets": "3組 12下 (前臂抗阻外張拉離身體)", "default_minutes": "5 分鐘"},
    {"id": "ex_033", "title": "啞鈴側躺肩內旋", "default_sets": "3組 10下 (側躺患側在下，寶特瓶上舉)", "default_minutes": "4 分鐘"},
    {"id": "ex_034", "title": "啞鈴側躺肩外旋", "default_sets": "3組 10下 (側躺患側在上，寶特瓶上舉)", "default_minutes": "4 分鐘"},
    {"id": "ex_035", "title": "仰臥對側手大腿互推", "default_sets": "3組 10次 (每次雙向對抗推壓10秒)", "default_minutes": "5 分鐘"},
    {"id": "ex_036", "title": "仰臥單腳抬高下背貼床", "default_sets": "3組 每邊10下 (保持背貼床抬高10秒)", "default_minutes": "5 分鐘"},
    {"id": "ex_037", "title": "仰臥雙腳抬高腰椎穩定", "default_sets": "3組 10下 (雙腳屈膝抬高維持10秒)", "default_minutes": "6 分鐘"},
    {"id": "ex_038", "title": "肩關節等長內旋對抗", "default_sets": "3組 (重複5次，兩手原地對抗出力5秒)", "default_minutes": "3 分鐘"},
    {"id": "ex_039", "title": "肩關節等長外旋對抗", "default_sets": "3組 (重複5次，患側手外推牆壁5秒)", "default_minutes": "3 分鐘"},
    {"id": "ex_040", "title": "彈力帶前鋸肌推拉 (沖拳)", "default_sets": "3組 15下 (前推至最頂端定格2秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_041", "title": "桌邊手腕上翹訓練 (伸肌)", "default_sets": "3組 15下 (掌心朝下，手背反覆上翹2秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_042", "title": "桌邊手腕上捲訓練 (屈肌)", "default_sets": "3組 15下 (掌心朝上，手掌反覆上捲2秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_043", "title": "前臂旋前與旋後平衡", "default_sets": "3組 (手握長棒慢速內翻與外翻各15次)", "default_minutes": "4 分鐘"},
    {"id": "ex_044", "title": "仰臥雙側夾膝 (內轉肌)", "default_sets": "3組 12下 (雙膝夾緊毛巾或球持續6秒)", "default_minutes": "5 分鐘"},
    {"id": "ex_045", "title": "單腳踮腳尖 (進階平衡)", "default_sets": "3組 每邊10下 (單腳控制踮起撐2秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_046", "title": "抗阻力腳踝內翻運動", "default_sets": "3組 15下 (腳底朝內抗阻拉緊停留2秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_047", "title": "抗阻力腳踝外翻運動", "default_sets": "3組 15下 (腳底朝外抗阻拉緊停留2秒)", "default_minutes": "4 分鐘"},
    {"id": "ex_048", "title": "怪獸側向行走 (彈力帶)", "default_sets": "3組 (維持半蹲姿勢，左右橫向各走10步)", "default_minutes": "5 分鐘"},
    {"id": "ex_049", "title": "直立後伸展大腿 (後踢)", "default_sets": "3組 每邊15下 (身體直立，單腿直腿後抬)", "default_minutes": "4 分鐘"},
    {"id": "ex_050", "title": "椅背扶持微蹲 (護膝)", "default_sets": "3組 12下 (扶椅後半蹲30度定格3秒)", "default_minutes": "5 分鐘"}
  ];

  String? _selectedExerciseId;

  @override
  void initState() {
    super.initState();
    // 預設選中第一個動作並帶入初始值
    _selectedExerciseId = _presetExercises.first['id'];
    _nameController.text = _presetExercises.first['title'];
    _setsController.text = _presetExercises.first['default_sets'];
    _timeController.text = _presetExercises.first['default_minutes'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _submitTask() {
    if (_nameController.text.isEmpty || _selectedPatientId == null) return;

    final taskProvider = context.read<TaskProvider>();

    taskProvider.addTask(
      _selectedPatientId!,
      _nameController.text,
      _setsController.text,
      _timeController.text,
    );

    final ptName = taskProvider.patientNames[_selectedPatientId];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ 成功開立處方給 $ptName！'), backgroundColor: Colors.teal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final patientMap = taskProvider.patientNames;

    if (_selectedPatientId == null && patientMap.isNotEmpty) {
      _selectedPatientId = patientMap.keys.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('👨‍⚕️ 醫師管理後台', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => const LoginPage())
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('➕ 開立專屬復健處方', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 20),
            
            // 1. 病患選擇 (下拉式選單)
            const Text('選擇復健對象', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPatientId, // ✨ 修正：統一改用更標準的 value
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
              items: patientMap.entries.map((entry) {
                return DropdownMenuItem<String>(value: entry.key, child: Text(entry.value));
              }).toList(),
              onChanged: (val) { if (val != null) setState(() { _selectedPatientId = val; }); },
            ),
            const SizedBox(height: 16),
            
            // 2. 復健項目名稱 (具備關鍵字搜尋過濾功能)
            const Text('復健項目名稱 (可輸入關鍵字搜尋，如：啞)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 8),
            Autocomplete<Map<String, dynamic>>(
              displayStringForOption: (Map<String, dynamic> option) => option['title'] as String,
              optionsBuilder: (TextEditingValue textEditingValue) {
                // 如果沒輸入任何字，預設顯示全部 50 個動作
                if (textEditingValue.text.isEmpty) {
                  return _presetExercises;
                }
                // 根據輸入的關鍵字進行不分大小寫的過濾
                return _presetExercises.where((Map<String, dynamic> exercise) {
                  return exercise['title']
                      .toString()
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                // 如果目前有選中的動作，且輸入框是空的，自動幫忙填入（初始化用）
                if (_selectedExerciseId != null && textEditingController.text.isEmpty) {
                  final selected = _presetExercises.firstWhere((ex) => ex['id'] == _selectedExerciseId, orElse: () => {});
                  if (selected.isNotEmpty) {
                    textEditingController.text = selected['title'];
                  }
                }
                
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    hintText: '請輸入復健動作名稱...',
                    suffixIcon: Icon(Icons.search, color: Colors.teal),
                  ),
                );
              },
              onSelected: (Map<String, dynamic> selection) {
                // 當醫生點選了搜尋出來的項目後，自動連動帶入組數與時間
                setState(() {
                  _selectedExerciseId = selection['id'];
                  _nameController.text = selection['title'];
                  _setsController.text = selection['default_sets'];
                  _timeController.text = selection['default_minutes'];
                });
              },
            ),
            const SizedBox(height: 16),
            
            // 3. 建議組數與預估時間 (併排呈現)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('建議組數次數', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _setsController, 
                        decoration: const InputDecoration(border: OutlineInputBorder())
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('預估時間', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _timeController, 
                        decoration: const InputDecoration(border: OutlineInputBorder())
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 送出按鈕
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('送出個別化處方', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const Divider(height: 40, thickness: 2),
            const Text('📋 各病患目前的復健排程狀態', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // 4. 下方排程清單
            Expanded(
              child: ListView(
                children: patientMap.keys.map((ptId) {
                  final ptName = patientMap[ptId];
                  final ptTasks = taskProvider.getTasksFor(ptId);
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      leading: const Icon(Icons.person, color: Colors.teal),
                      title: Text('$ptName (${ptTasks.length} 個項目)', style: const TextStyle(fontWeight: FontWeight.bold)),
                      children: ptTasks.isEmpty 
                        ? [const Padding(padding: EdgeInsets.all(16), child: Text('目前無處方', style: TextStyle(color: Colors.grey)))]
                        : ptTasks.map((t) => ListTile(
                            title: Text(t['name']),
                            subtitle: Text('${t['setsAndReps']} · ${t['estimatedTime']}'),
                            trailing: t['isCompleted'] ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.pending, color: Colors.orange),
                          )).toList(),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}