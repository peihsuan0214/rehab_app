import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// 1. ✨ 必須引入這兩個套件才能解析 JSON 
import 'dart:convert';
import 'package:flutter/services.dart';

import 'providers/task_provider.dart';
import 'screens/login_page.dart';

void main() async {
  // 2. ✨ 用記事本時，若要在 main 執行非同步動作（如讀檔），必須加這行
  WidgetsFlutterBinding.ensureInitialized();

  // 3. ✨ 測試讀取你的 ai_models.json
  try {
    final String response = await rootBundle.loadString('assets/ai_models.json');
    final data = json.decode(response);
    print("【測試成功】順利讀取到 AI 模型資料！數量為: ${data.length} 筆");
  } catch (e) {
    print("【測試失敗】讀取 JSON 發生錯誤: $e");
    print("請檢查 pubspec.yaml 的縮排與 assets 檔案路徑。");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const RehabApp(),
    ),
  );
}

class RehabApp extends StatelessWidget {
  const RehabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '夢醒淑芬',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.notoSansTcTextTheme(Theme.of(context).textTheme),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}