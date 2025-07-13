import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/camera_recognition_page.dart';
import '../presentation/pages/entry/create_entry_page.dart';
import '../presentation/pages/tags/tag_selector_page.dart';
import '../presentation/providers/auth_provider.dart';

class AppRoutes {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/login',
      debugLogDiagnostics: true, // 启用路由调试日志
      redirect: (context, state) {
        final authProvider = context.read<AuthProvider>();
        final isLoggedIn = authProvider.isLoggedIn;
        final isInitialized = authProvider.initialized;
        final location = state.uri.toString();

        print('🧭 路由重定向检查:');
        print('   当前路径: $location');
        print('   已初始化: $isInitialized');
        print('   已登录: $isLoggedIn');

        // 如果还没初始化，先初始化
        if (!isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.initialize();
          });
          return null; // 保持当前路径
        }

        final isAuthPage = location == '/login' || location == '/register';

        // 如果未登录且不在认证页面，跳转到登录页
        if (!isLoggedIn && !isAuthPage) {
          print('🔄 重定向到登录页');
          return '/login';
        }

        // 如果已登录且在认证页面，跳转到首页
        if (isLoggedIn && isAuthPage) {
          print('🔄 重定向到首页');
          return '/home';
        }

        print('✅ 路径检查通过，无需重定向');
        return null;
      },
      routes: [
        // 认证相关路由
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) {
            print('📱 构建登录页面');
            return const LoginPage();
          },
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) {
            print('📱 构建注册页面');
            return const RegisterPage();
          },
        ),

        // 主要功能路由
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) {
            print('📱 构建首页');
            return const HomePage();
          },
        ),
        GoRoute(
          path: '/camera-recognition',
          name: 'camera-recognition',
          builder: (context, state) {
            print('📱 构建拍照识别页面');
            return const CameraRecognitionPage();
          },
        ),
        GoRoute(
          path: '/create-entry',
          name: 'create-entry',
          builder: (context, state) {
            print('📱 构建创建图鉴页面');
            return const CreateEntryPage();
          },
        ),
        GoRoute(
          path: '/tag-selector',
          name: 'tag-selector',
          builder: (context, state) {
            print('📱 构建标签选择页面');
            return const TagSelectorPage();
          },
        ),

        // 详情页路由
        GoRoute(
          path: '/entry/:id',
          name: 'entry-detail',
          builder: (context, state) {
            final entryId = state.pathParameters['id']!;
            print('📱 构建图鉴详情页面 - ID: $entryId');
            return Scaffold(
              appBar: AppBar(title: const Text('图鉴详情')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('图鉴详情页 - ID: $entryId'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('返回首页'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
