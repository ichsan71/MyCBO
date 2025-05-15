import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../auth/presentation/pages/login_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Kelola Jadwal Kunjungan',
      description:
          'Atur dan kelola jadwal kunjungan Anda dengan mudah dan efisien',
      image: 'assets/images/schedule.png',
    ),
    OnboardingItem(
      title: 'Persetujuan Jadwal Kunjungan',
      description: 'Permudah persetujuan jadwal kunjungan Anda',
      image: 'assets/images/product.png',
    ),
    OnboardingItem(
      title: 'Laporan Real-time',
      description: 'Pantau aktivitas dan capaian Anda secara real-time',
      image: 'assets/images/report.png',
    ),
  ];

  void _finishOnboarding() async {
    try {
      if (kDebugMode) {
        print('Mencoba menyimpan status onboarding...');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);

      if (kDebugMode) {
        print('Status onboarding berhasil disimpan: isFirstTime = false');
        final value = prefs.getBool('isFirstTime');
        print('Verifikasi nilai yang tersimpan: isFirstTime = $value');
      }

      if (!mounted) {
        if (kDebugMode) {
          print('Widget tidak lagi mounted, navigasi dibatalkan');
        }
        return;
      }

      if (kDebugMode) {
        print('Melakukan navigasi ke halaman login...');
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saat menyimpan status onboarding: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  'Lewati',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _items.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              _items[index].image,
                              height: 300,
                              errorBuilder: (context, error, stackTrace) {
                                if (kDebugMode) {
                                  print('Error memuat gambar: $error');
                                }
                                return const Icon(
                                  Icons.image_not_supported,
                                  size: 200,
                                  color: Colors.grey,
                                );
                              },
                            ),
                            const SizedBox(height: 40),
                            Text(
                              _items[index].title,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _items[index].description,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicators and buttons
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Kembali',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 80),

                      // Page indicators
                      Row(
                        children: List.generate(
                          _items.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),

                      // Next/Finish button
                      TextButton(
                        onPressed: () {
                          if (_currentPage == _items.length - 1) {
                            _finishOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          _currentPage == _items.length - 1
                              ? 'Mulai'
                              : 'Lanjut',
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
  });
}
