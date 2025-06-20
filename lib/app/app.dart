import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/entry_provider.dart';
import '../presentation/providers/tag_provider.dart';
import 'routes.dart';

class UtopiaApp extends StatelessWidget {
  const UtopiaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) {
                final provider = AuthProvider();
                // 应用启动时初始化认证状态
                provider.initialize();
                return provider;
              },
            ),
            ChangeNotifierProvider(create: (_) => EntryProvider()),
            ChangeNotifierProvider(create: (_) => TagProvider()),
          ],
          child: MaterialApp.router(
            title: '虚拟乌托邦',
            theme: AppTheme.lightTheme,
            routerConfig: AppRoutes.createRouter(),
            debugShowCheckedModeBanner: false,
            // 添加全局的 ScaffoldMessenger
            scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
          ),
        );
      },
    );
  }
}
