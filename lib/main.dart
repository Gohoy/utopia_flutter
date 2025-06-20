import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 初始化服务
  await _initializeServices();

  runApp(const UtopiaApp());
}

Future<void> _initializeServices() async {
  try {
    // 初始化存储服务
    await StorageService().initialize();
    
    // 初始化API服务
    ApiService().initialize();
    
    print('所有服务初始化完成');
  } catch (e) {
    print('服务初始化失败: $e');
  }
}
