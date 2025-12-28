import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../data/language_constants.dart';
import 'vocab_screen.dart';
import 'grammar_patterns_screen.dart';
import 'history_screen.dart';
import 'paywall_screen.dart';
import 'splash_screen.dart'; // For logout navigation

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  // Local state for immediate UI updates, reflecting auth service state
  late String _name;
  late String _email;
  late String _avatarUrl;
  late String _gender;
  late String _nativeLanguage;
  late String _targetLanguage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _name = user.name;
        _email = user.email;
        _avatarUrl = user.avatarUrl ?? 'assets/images/user_avatar_male.png';
        _gender = user.gender;
        _nativeLanguage = user.nativeLanguage;
        _targetLanguage = user.targetLanguage;
      });
    } else {
      // Fallback if accessed without auth (shouldn't happen in new flow)
       setState(() {
        _name = 'Guest';
        _email = 'guest@example.com';
        _avatarUrl = 'assets/images/user_avatar_male.png';
        _gender = 'male';
        _nativeLanguage = LanguageConstants.defaultNativeLanguage;
        _targetLanguage = LanguageConstants.defaultTargetLanguage;
      });
    }
  }

  Future<void> _updateNativeLanguage(String language) async {
    await _userService.updateUserProfile(nativeLanguage: language);
    _loadUserData(); // Reload to reflect changes
  }

  Future<void> _updateTargetLanguage(String language) async {
    await _userService.updateUserProfile(targetLanguage: language);
    _loadUserData();
  }
  
  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showLanguageDialog(
      String title, String currentLanguage, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: LanguageConstants.supportedLanguages.map((lang) {
                  final isSelected = lang == currentLanguage;
                  return InkWell(
                    onTap: () {
                      onSelect(lang);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade100,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.blue
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check, color: Colors.blue, size: 24),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Profile Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                   Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                    ),
                    child: ClipOval(
                      child: _avatarUrl.startsWith('assets/') 
                        ? Image.asset(
                            _avatarUrl,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            _avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to gender-based avatar
                              final fallbackPath = _gender == 'female'
                                  ? 'assets/images/user_avatar_female.png'
                                  : 'assets/images/user_avatar_male.png';
                              return Image.asset(fallbackPath, fit: BoxFit.cover);
                            },
                          ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          _name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Text(
                    'Language Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: 'Native Language',
                    subtitle: _nativeLanguage,
                    icon: Icons.language,
                    iconColor: Colors.teal,
                    onTap: () {
                      _showLanguageDialog(
                          'Select Native Language', _nativeLanguage, _updateNativeLanguage);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: 'Learning Language',
                    subtitle: _targetLanguage,
                    icon: Icons.school,
                    iconColor: Colors.indigo,
                    onTap: () {
                      _showLanguageDialog('Select Learning Language', _targetLanguage,
                          _updateTargetLanguage);
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Tools',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: 'Vocabulary Notebook',
                    icon: Icons.book,
                    iconColor: Colors.amber,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VocabScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: 'Sentence Patterns',
                    icon: Icons.auto_awesome_rounded, // Consistent with AnalysisSheet
                    iconColor: Colors.green,
                    onTap: () {
                      Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => const GrammarPatternsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: 'Chat History',
                    icon: Icons.history,
                    iconColor: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: 'Upgrade to Pro',
                    subtitle: 'Get unlimited chats and advanced feedback',
                    icon: Icons.star_border,
                    iconColor: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaywallScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Logout Button
                   _buildMenuCard(
                    context,
                    title: 'Log Out',
                    icon: Icons.logout,
                    iconColor: Colors.red,
                    onTap: _handleLogout,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500, // Make subtitle slightly more visible
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
