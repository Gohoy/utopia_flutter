import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/entry_provider.dart';
import '../../providers/tag_provider.dart';
import '../../widgets/entry/entry_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final entryProvider = context.read<EntryProvider>();
    final tagProvider = context.read<TagProvider>();

    entryProvider.loadEntries();
    tagProvider.initialize();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final entryProvider = context.read<EntryProvider>();
      if (_tabController.index == 0) {
        entryProvider.loadEntries();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),

          // 标签页
          _buildTabBar(),

          // 内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllEntriesTab(),
                _buildMyEntriesTab(),
                _buildHotEntriesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Text(
            '虚拟乌托邦',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'Beta',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, authProvider),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline),
                      SizedBox(width: 12.w),
                      const Text('个人资料'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Icons.settings_outlined),
                      SizedBox(width: 12.w),
                      const Text('设置'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout_outlined),
                      SizedBox(width: 12.w),
                      const Text('退出登录'),
                    ],
                  ),
                ),
              ],
              child: Container(
                margin: EdgeInsets.only(right: 16.w),
                child: CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    authProvider.user?.nickname?.substring(0, 1) ??
                        authProvider.user?.username.substring(0, 1) ??
                        '?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: CustomTextField(
        controller: _searchController,
        hint: '搜索图鉴...',
        type: TextFieldType.search,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            context.read<EntryProvider>().searchEntries(value.trim());
            _showSearchResults();
          }
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        tabs: const [
          Tab(text: '全部'),
          Tab(text: '我的'),
          Tab(text: '热门'),
        ],
      ),
    );
  }

  Widget _buildAllEntriesTab() {
    return Consumer<EntryProvider>(
      builder: (context, entryProvider, child) {
        if (entryProvider.isLoading && entryProvider.entries.isEmpty) {
          return const LoadingWidget(message: '加载中...');
        }

        if (entryProvider.entries.isEmpty) {
          return const EmptyWidget(
            message: '还没有图鉴条目\n快来创建第一个吧！',
            icon: Icon(
              Icons.article_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => entryProvider.loadEntries(),
          child: ListView.builder(
            controller: _scrollController,
            itemCount:
                entryProvider.entries.length + (entryProvider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == entryProvider.entries.length) {
                return ListLoadingWidget(
                  isLoading: entryProvider.isLoadingMore,
                  message: '加载更多...',
                );
              }

              final entry = entryProvider.entries[index];
              return EntryCard(
                entry: entry,
                onTap: () => _onEntryTap(entry.id),
                showAuthor: true,
                showStats: true,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMyEntriesTab() {
    return Consumer<EntryProvider>(
      builder: (context, entryProvider, child) {
        if (entryProvider.isLoading && entryProvider.myEntries.isEmpty) {
          return const LoadingWidget(message: '加载我的图鉴...');
        }

        if (entryProvider.myEntries.isEmpty) {
          return EmptyWidget(
            message: '你还没有创建任何图鉴\n点击右下角按钮开始创建',
            icon: const Icon(
              Icons.create_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            onRetry: () {
              entryProvider.loadMyEntries();
            },
            retryText: '刷新',
          );
        }

        return RefreshIndicator(
          onRefresh: () => entryProvider.loadMyEntries(),
          child: ListView.builder(
            itemCount: entryProvider.myEntries.length,
            itemBuilder: (context, index) {
              final entry = entryProvider.myEntries[index];
              return EntryCard(
                entry: entry,
                onTap: () => _onEntryTap(entry.id),
                showAuthor: false,
                showStats: true,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHotEntriesTab() {
    return Consumer<EntryProvider>(
      builder: (context, entryProvider, child) {
        return RefreshIndicator(
          onRefresh: () => entryProvider.loadHotEntries(),
          child: ListView.builder(
            itemCount: entryProvider.entries.length,
            itemBuilder: (context, index) {
              final entry = entryProvider.entries[index];
              return EntryCard(
                entry: entry,
                type: EntryCardType.featured,
                onTap: () => _onEntryTap(entry.id),
                showAuthor: true,
                showStats: true,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => context.push('/create-entry'),
      child: const Icon(Icons.add),
    );
  }

  void _handleMenuAction(String action, AuthProvider authProvider) {
    switch (action) {
      case 'profile':
        // TODO: 导航到个人资料页面
        break;
      case 'settings':
        // TODO: 导航到设置页面
        break;
      case 'logout':
        _showLogoutDialog(authProvider);
        break;
    }
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _onEntryTap(String entryId) {
    context.push('/entry/$entryId');
  }

  void _showSearchResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildSearchResultsSheet(),
    );
  }

  Widget _buildSearchResultsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Text(
                '搜索结果',
                style: AppTextStyles.h3,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 搜索结果
          Expanded(
            child: Consumer<EntryProvider>(
              builder: (context, entryProvider, child) {
                if (entryProvider.isLoading) {
                  return const LoadingWidget(message: '搜索中...');
                }

                if (entryProvider.searchResults.isEmpty) {
                  return const EmptyWidget(
                    message: '没有找到相关图鉴',
                    icon: Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: entryProvider.searchResults.length,
                  itemBuilder: (context, index) {
                    final entry = entryProvider.searchResults[index];
                    return EntryCard(
                      entry: entry,
                      type: EntryCardType.compact,
                      onTap: () {
                        Navigator.pop(context);
                        _onEntryTap(entry.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
