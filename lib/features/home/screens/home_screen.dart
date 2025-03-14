import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

import '../models/user_profile_model.dart';
import '../services/home_service.dart';
import '../widgets/profile_card.dart';
import '../widgets/profile_page_indicator.dart';
import '../widgets/home_screen_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = HomeService();
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  bool _isLoading = true;
  List<UserProfileModel> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // บันทึกเวลาเริ่มต้น
    final startTime = DateTime.now();

    await _loadProfiles();

    final elapsedTime = DateTime.now().difference(startTime).inMilliseconds;
    final minimumLoadingTime = 3500;

    if (elapsedTime < minimumLoadingTime) {
      await Future.delayed(
        Duration(milliseconds: minimumLoadingTime - elapsedTime),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProfiles() async {
    try {
      setState(() => _isLoading = true);

      // ดึงข้อมูลผู้ใช้ปัจจุบันและเพื่อน
      final currentUser = await _homeService.fetchCurrentUser();
      final friends = await _homeService.fetchFriends();

      setState(() {
        _profiles = [currentUser, ...friends];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getBackgroundImage(Map<String, dynamic> unlockedTopics) {
    if ((unlockedTopics['C2'] ?? {}).containsValue(true)) {
      return 'assets/images/winter.png';
    }
    if ((unlockedTopics['C1'] ?? {}).containsValue(true)) {
      return 'assets/images/autumn.png';
    }
    if ((unlockedTopics['B2'] ?? {}).containsValue(true)) {
      return 'assets/images/summer.png';
    }
    return 'assets/images/spring.png';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: HomeScreenLoading(),
      );
    }

    bootstrapGridParameters(gutterSize: 16);

    return Scaffold(
      appBar: AppBar(
        title: Text('หน้าหลัก', style: AppTextStyles.headline),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : BootstrapContainer(
              fluid: true,
              children: [
                BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-6',
                      offsets:
                          "offset-xs-0 offset-sm-0 offset-md-2 offset-lg-3",
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Expanded(
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (page) =>
                                    setState(() => _currentPage = page),
                                itemCount: _profiles.length,
                                itemBuilder: (context, index) {
                                  final profile = _profiles[index];
                                  final isCurrentPage = index == _currentPage;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    margin: EdgeInsets.symmetric(
                                      vertical: isCurrentPage ? 5 : 10,
                                      horizontal: 8,
                                    ),
                                    child: ProfileCard(
                                      username: profile.username,
                                      joinedAt: profile.createdAt,
                                      profileImageUrl: profile.profileImageUrl,
                                      isUser: profile.isUser,
                                      unlockedTopics: profile.unlockedTopics,
                                      backgroundImage: _getBackgroundImage(
                                          profile.unlockedTopics),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            ProfilePageIndicator(
                              currentPage: _currentPage,
                              totalPages: _profiles.length,
                            ),
                            const SizedBox(height: 35),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
