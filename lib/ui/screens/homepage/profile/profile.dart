import 'package:agapay_users/ui/screens/auth/auth-service.dart';
import 'package:agapay_users/ui/screens/auth/login/Login.dart';
import 'package:agapay_users/ui/screens/homepage/profile/change_pass.dart';
import 'package:agapay_users/ui/screens/homepage/profile/personal_info.dart';
import 'package:agapay_users/utils/toast_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileContent extends StatelessWidget {
  final AuthService _authService = AuthService();
  ProfileContent({super.key});

  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("No user logged in."));
    }

    final userDocStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: userDocStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("User data not found."));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        // ✅ Combine first and last name
        final photoUrl = userData['selfieUrl'] ?? '';
        final firstName = userData['firstName'] ?? '';
        final lastName = userData['lastName'] ?? '';
        final name = '$firstName $lastName'.trim().isEmpty
            ? 'Unknown User'
            : '$firstName $lastName';

        final phone = userData['phoneNumber'] ?? 'No phone';
        final email = user.email ?? 'No email';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 120),

              // 🟦 Profile Header
              Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SvgPicture.asset(
                        'assets/images/prof_box.svg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE8F0FB),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: photoUrl.isNotEmpty
                                ? Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.person, size: 40, color: Colors.grey),
                                  )
                                : const Icon(Icons.person, size: 40, color: Colors.grey),
                          ),

                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  phone,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 🔹 ACCOUNT & SECURITY
              const SectionHeader(title: 'Account & Security'),
              ProfileItem(
                svgIcon: 'assets/images/profile.svg',
                title: 'Personal Information',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalInfoPage(),
                    ),
                  );
                },
              ),
              ProfileItem(
                svgIcon: 'assets/images/pass.svg',
                title: 'Change Password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // 🔹 PREFERENCES
              const SectionHeader(title: 'Preferences'),
              const ProfileItem(
                svgIcon: 'assets/images/country.svg',
                title: 'Country',
                trailingText: 'Philippines',
                onTap: null,
              ),
              const ProfileItem(
                svgIcon: 'assets/images/language.svg',
                title: 'Language',
                trailingText: 'English',
                onTap: null,
              ),

              const SizedBox(height: 25),

              // 🔹 GENERAL
              const SectionHeader(title: 'General'),
              const ProfileItem(
                svgIcon: 'assets/images/app_ver.svg',
                title: 'App Version',
                trailingText: '0.0.1',
                onTap: null,
              ),
              const ProfileItem(
                svgIcon: 'assets/images/tnc.svg',
                title: 'Terms & Conditions',
                onTap: null,
              ),
              const ProfileItem(
                svgIcon: 'assets/images/priv_pol.svg',
                title: 'Privacy Policy',
                onTap: null,
              ),
              const ProfileItem(
                svgIcon: 'assets/images/help.svg',
                title: 'Help Center',
                onTap: null,
              ),

              const SizedBox(height: 25),

              // 🔴 LOGOUT BUTTON
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return SafeArea(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFE7F5FC),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFE8F0FB),
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SvgPicture.asset(
                                  'assets/images/logout2.svg',
                                  width: 100,
                                  height: 100,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Are you Sure you Want\nto Log Out?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 25),
                                SizedBox(
                                  width: 200,
                                  height: 45,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFEA5757),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () async {
                                      Navigator.pushReplacement(
                                        context, 
                                        MaterialPageRoute(builder: (context) => LoginScreen())
                                        );
                                      await signOut();
                                      ToastHelper.showSuccess(
                                          context, "User Logged Out");
                                    },
                                    child: const Text(
                                      'Log Out',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Colors.grey.shade300, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/logout.svg',
                        width: 34,
                        height: 34,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}

// ✅ Section Header widget
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ✅ Profile Item widget
class ProfileItem extends StatelessWidget {
  final String svgIcon;
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;

  const ProfileItem({
    super.key,
    required this.svgIcon,
    required this.title,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: ListTile(
        leading: SvgPicture.asset(svgIcon, width: 34, height: 34),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailingText != null
            ? Text(
                trailingText!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.black45,
                ),
              )
            : const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.black38),
        onTap: onTap,
      ),
    );
  }
}
