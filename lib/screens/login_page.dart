import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'home_page.dart';
import 'doctor_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final input = _accountController.text.trim();
    final password = _passwordController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 請輸入帳號或健保卡號'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() { _isLoading = true; });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() { _isLoading = false; });

      final taskProvider = context.read<TaskProvider>();

      // 1. 檢查是不是醫師帳密登入
      if (input == 'dr' && password == '123') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 醫師登入成功！'), backgroundColor: Colors.teal),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DoctorDashboard()));
        return;
      }

      // 2. 健保卡號感應登入法
      bool isNhiSuccess = taskProvider.loginWithNhiCard(input);
      if (isNhiSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('💳 健保卡感應成功！歡迎回來，${taskProvider.currentPatientName}！'), 
            backgroundColor: Colors.blueAccent
          ),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
        return;
      }

      // 3. 傳統病患帳密登入 (防呆備用)
      if (taskProvider.patientNames.containsKey(input) && password == '123') {
        taskProvider.setCurrentPatient(input);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ 歡迎回來，${taskProvider.currentPatientName}！'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
        return;
      }

      // 4. 以上皆非則報錯
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 查無此帳號或健保卡號，請重新輸入'), backgroundColor: Colors.redAccent),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Center(
          // 使用 ConstrainedBox 限制最大寬度，避免在電腦螢幕上拉得太寬
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.health_and_safety, size: 100, color: Colors.blueAccent),
                  const SizedBox(height: 24),
                  const Text('夢醒淑芬\nAI 雙端復健系統', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 48),
                  
                  TextField(
                    controller: _accountController,
                    decoration: InputDecoration(
                      labelText: '帳號 或 健保卡號',
                      prefixIcon: const Icon(Icons.credit_card),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '密碼 (使用健保卡登入免填)',
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('登 入', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // ✨ 專為你們團隊客製化的排版與名單
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white70, 
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: Colors.grey.shade300)
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // 讓文字靠左對齊
                      children: [
                        Center(child: Text('🛠️ 團隊專屬測試指南', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87))),
                        Divider(height: 24, thickness: 1),
                        Text('👨‍⚕️ 醫師管理端 ➡️ 帳號: dr / 密碼: 123', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                        SizedBox(height: 12),
                        Text('💳 健保卡免密碼登入 (直接輸入以下 12 碼):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                        SizedBox(height: 8),
                        Text('• 羅煒翔: 001411335032'),
                        Text('• 廖奕筑: 001411335006'),
                        Text('• 李姍芸: 001411335011'),
                        Text('• 吳宇梋: 001411335010'),
                        Text('• 蔡佩諼: 001411335001'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}