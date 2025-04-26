import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:treemate/controllers/user_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategory('General', [
            _buildSetting(
              context,
              'Notifications',
              Icons.notifications_outlined,
              Colors.green,
            ),
            _buildSetting(
                context, 'Location', Icons.location_on_outlined, Colors.grey,
                enabled: false),
            _buildSetting(context, 'Weather', Icons.cloud_outlined, Colors.grey,
                enabled: false),
          ]),
          _buildAccountPrivacy(context),
          _buildCategory('Help', [
            _buildSetting(
                context, 'Contact us', Icons.phone_outlined, Colors.green),
            _buildSetting(context, 'Terms & conditions',
                Icons.description_outlined, Colors.green),
            _buildSetting(context, 'Privacy policy', Icons.privacy_tip_outlined,
                Colors.green),
            _buildSetting(
                context, 'About us', Icons.info_outline, Colors.green),
          ]),
          const SizedBox(height: 16),
          _buildLogoutButton(context),
          const SizedBox(height: 16),
          _buildDeleteAccountButton(context),
        ],
      ),
    );
  }

  Widget _buildCategory(String name, List<Widget> settings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          ...settings,
        ],
      ),
    );
  }

  Widget _buildAccountPrivacy(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        title: const Text(
          'Account & privacy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        // onTap: () => _navigateToPage(context, 'Account & privacy'),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AccountPrivacyPage())),
      ),
    );
  }

  Widget _buildSetting(
      BuildContext context, String name, IconData icon, Color color,
      {bool enabled = true}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        name,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      // onTap: enabled ? () => _navigateToPage(context, name) : null,
      onTap: enabled ? () => _navigateToPage(context, name) : null,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.red[300]!, Colors.red[400]!],
        ),
      ),
      child: ElevatedButton(
        onPressed: () => _showLogoutConfirmation(context),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.transparent,
          elevation: 0,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Log out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget _buildDeleteAccountButton(BuildContext context) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(30),
  //       gradient: LinearGradient(
  //         colors: [Colors.red[700]!, Colors.red[800]!],
  //       ),
  //     ),
  //     child: ElevatedButton(
  //       onPressed: () => _showDeleteAccountConfirmation(context),
  //       child: Text(
  //         'Delete Account',
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       style: ElevatedButton.styleFrom(
  //         foregroundColor: Colors.white,
  //         backgroundColor: Colors.transparent,
  //         elevation: 0,
  //         minimumSize: Size(double.infinity, 60),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(30),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildDeleteAccountButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.red[700]!, Colors.red[800]!],
        ),
      ),
      child: ElevatedButton(
        onPressed: () =>  Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const DeleteAccountPage())),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Delete Account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String pageName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _getPageForSetting(pageName),
      ),
    );
  }

  Widget _getPageForSetting(String pageName) {
    switch (pageName) {
      case 'Notifications':
        return const NotificationsPage();
      case 'Location':
        return const LocationPage();
      case 'Weather':
        return const WeatherPage();
      case 'Contact us':
        return const ContactUsPage();
      case 'Terms & conditions':
        return const TermsConditionsPage();
      case 'Privacy policy':
        return const PrivacyPolicyPage();
      case 'About us':
        return const AboutUsPage();
      default:
        return Scaffold(
          appBar: AppBar(title: Text(pageName)),
          body: const Center(child: Text('Page not found')),
        );
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                UserController().logout(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

}


class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/commingsoon.json',
              width: 200, // Adjust size as needed
              height: 200, // Adjust size as needed
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              'Coming Soon!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[900]),
            ),
            const SizedBox(height: 10),
            Text(
              "Notification settings are under development.\nTill then, don't forget to water your plants!",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.green[100],
    );
  }
}

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: const Center(child: Text('Location settings page')),
    );
  }
}

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: const Center(child: Text('Weather settings page')),
    );
  }
}


class AccountPrivacyPage extends StatelessWidget {
  const AccountPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Privacy', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/commingsoon.json', // Replace with your Lottie animation path
              width: 200, // Adjust size as needed
              height: 200, // Adjust size as needed
              fit: BoxFit.contain, // Ensure animation is visible without cropping
            ),
            const SizedBox(height: 20),
            Text(
              'Coming Soon!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[900]),
            ),
            const SizedBox(height: 10),
            Text(
              "This feature is under development. Till then, don't forget to water your plants!",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.green[100],
    );
  }
}

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us', style: TextStyle(color: Colors.green[800])),
        backgroundColor: Colors.green[100],
        iconTheme: IconThemeData(color: Colors.green[800]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in Touch with TREEmate',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0),
            _buildContactInfo(
              icon: Icons.location_on,
              label: 'Address',
              content: 'Laipuli Kaptanchuk Village, Tinsukia, Assam India',
              onTap: null,
            ),
            const SizedBox(height: 20.0),
            _buildContactInfo(
              icon: Icons.email,
              label: 'Email',
              content: 'contact@treemate.com',
              onTap: () => _launchEmail('contact@treemate.com'),
            ),

            const SizedBox(height: 40),
            Center(
                // child: Icon(
                //   Icons.headset_mic,
                //   size: 80,
                //   color: Colors.green[700],
                // )
                child: Lottie.asset(
                  'assets/animations/contactus.json',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                )
            )
          ],
        ),
      ),
      backgroundColor: Colors.green[100],
    );
  }

  Widget _buildContactInfo({required IconData icon, required String label, required String content,  VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 30.0,),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.green[800])),
                const SizedBox(height: 4.0),
                Text(content, style: TextStyle(fontSize: 16.0, color: Colors.grey[800])),
              ],
            ),
          )
        ],
      ),
    );
  }
  _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try{
      await launchUrl(emailUri);

    }catch(e){
      throw 'Could not launch email';
    }
  }
}


class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms & Conditions', style: TextStyle(color: Colors.green[800])),
        backgroundColor: Colors.green[100],
        iconTheme: IconThemeData(color: Colors.green[800]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TREEmate App Terms and Conditions',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text('Last Updated: 13/11/2024',style: TextStyle(color: Colors.grey[700]),textAlign: TextAlign.center,),
            const SizedBox(height: 20.0),
            _buildSection(
              '1. Acceptance of Terms',
              'By using the TREEmate app, you acknowledge that you have read, understood, and agreed to be bound by these Terms and Conditions. If you do not agree, please do not use the app.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '2. User Account',
              'You must create an account to access certain features of the app.\n\n'
                  '   •  You are responsible for maintaining the confidentiality of your account and password.\n'
                  '   •  TREEmate reserves the right to suspend or terminate accounts that violate these Terms.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '3. User Content',
              'Users may share content such as photos, plant information, and experiences.\n\n'
                  '   •  By sharing content, you grant TREEmate a non-exclusive, worldwide, royalty-free license to use, modify, and display the content on the app.\n'
                  '   •  You are solely responsible for the content you post and must ensure it does not infringe on the rights of others.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '4. Plant AI & Information',
              'The app\'s "Plant AI" feature provides information on various plants.\n\n'
                  '   •  TREEmate does not guarantee the accuracy or completeness of the data. The information provided is for general guidance only.\n'
                  '   •  For critical plant care, consult a professional.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '5. Purchases & Commissions',
              'TREEmate will list its own products along with other brands in the gardening, eco-friendly, and agricultural spaces.\n\n'
                  '   •  A fixed commission will be charged by TREEmate for delivering these products directly to customers\' doorsteps.\n'
                  '   •  Delivery times may range from 3 to 15 working days, depending on product availability and the delivery service used.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '6. Community Guidelines',
              'Respectful behavior is expected within the TREEmate community. Harassment, hate speech, and offensive content are strictly prohibited.\n\n'
                  '   • Violations may lead to content removal or account suspension.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '7. Privacy',
              'Your privacy is important to us. Please review our Privacy Policy for detailed information on data collection and usage.\n\n'
                  '   • By using the app, you consent to data collection as outlined in the Privacy Policy.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '8. Intellectual Property',
              'All content and features in the app are the property of TREEmate or its licensors.\n\n'
                  '   • Users may not copy, distribute, or reproduce any content without explicit permission.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '9. Limitation of Liability',
              'TREEmate is not liable for any indirect, incidental, or consequential damages arising from the use of the app.\n\n'
                  '   • The app is provided "as is" without any warranties, expressed or implied.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '10. Modification of Terms',
              'TREEmate reserves the right to modify or update these Terms and Conditions at any time.\n\n'
                  '   • Changes will be effective upon posting. Continued use of the app implies acceptance of updated terms.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '11. Governing Law',
              'These Terms are governed by and construed in accordance with the laws of India.\n\n'
                  '   • Any disputes arising under these terms will be subject to the exclusive jurisdiction of the courts in Tinsukia/India.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '12. Contact Us',
              'For any questions or concerns regarding these Terms and Conditions, please contact us at:\n\n'
                  'Address: Laipuli Kaptanchuk Village, Tinsukia, Assam India\n'
                  'Email: contact@treemate.com',
            ),
            const SizedBox(height: 30.0),
            Center(
              child:  Icon(
                Icons.rule,
                size: 80,
                color: Colors.green[700],
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.green[100],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.green[800]),
        ),
        const SizedBox(height: 8.0),
        Text(
          content,
          style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
        ),
      ],
    );
  }
}


class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: TextStyle(color: Colors.green[800])),
        backgroundColor: Colors.green[100],
        iconTheme: IconThemeData(color: Colors.green[800]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TREEmate Privacy Policy',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),

            _buildSection(
              'Introduction',
              'At TREEmate, we are committed to protecting your privacy. This Privacy Policy outlines how we collect, use, and protect your information when you use our mobile app and website. By using our services, you consent to the data practices described below.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '1. Information Collection',
              'We collect information to improve your user experience and provide better services:\n\n'
                  '   •  **Personal Information:** We may collect personal details such as name, email, phone number, and address when you register, make a purchase, or contact us.\n'
                  '   •  **Plant Information:** When using the "Plant Manager" feature, you may provide specific data on your plants, their condition, and their growth.\n'
                  '   •  **App Usage Information:** We gather data about how you use our app, including pages viewed, features accessed, and the duration of use, to enhance our services.\n'
                  '   •  **Device and Location Information:** We may collect data on your device type, IP address, operating system, and geolocation (if enabled) to offer personalized recommendations.',
            ),

            const SizedBox(height: 20.0),
            _buildSection(
              '2. Use of Information',
              'TREEmate uses the information collected for the following purposes:\n\n'
                  '   •  To improve, personalize, and optimize the app\'s features and user experience.\n'
                  '   •  To manage your account, process transactions, and handle customer inquiries.\n'
                  '   •  To send notifications, updates, and relevant plant care reminders.\n'
                  '   •  To understand user trends, conduct research, and develop new features.\n'
                  '   •  To facilitate targeted advertising, promotions, and surveys.\n'
                  '   •  To fulfill orders, manage deliveries, and provide customer support.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '3. Information Sharing',
              'We do not sell your personal information to third parties. However, we may share information in the following cases:\n\n'
                  '   •  **With Service Providers:** To fulfill orders, process payments, and facilitate services through trusted third parties.\n'
                  '   •  **With Partners:** To feature products from other brands and handle commission payments.\n'
                  '   •  **For Legal Compliance:** When required by law or to protect TREEmate’s rights, user safety, or the security of the app.\n'
                  '   •  **In Business Transactions:** In the event of a merger, acquisition, or asset sale, your information may be transferred.',
            ),

            const SizedBox(height: 20.0),
            _buildSection(
              '4. Data Security',
              'We employ industry-standard security measures to protect your data from unauthorized access, alteration, or disclosure. These include encryption, secure servers, and regular security assessments. Despite our efforts, no method of transmission over the internet or electronic storage is completely secure.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '5. Cookies & Tracking Technologies',
              'TREEmate uses cookies and similar tracking technologies to collect data on user behavior and preferences. These are used to improve website functionality and provide tailored content. You can disable cookies in your browser settings, but this may affect app performance.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '6. Data Retention',
              'We retain your information for as long as necessary to fulfill the purposes outlined in this policy. If you delete your account, some data may be retained for legal, regulatory, or security reasons.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '7. Your Rights & Choices',
              'You have the right to access, update, or delete your personal information at any time. You can manage your communication preferences and unsubscribe from our promotional emails. For assistance with data requests, please contact us at [contact email].',
            ),

            const SizedBox(height: 20.0),
            _buildSection(
              '8. Third-Party Links',
              'Our app and website may contain links to third-party websites. We are not responsible for the privacy practices or content of these sites. We recommend reviewing their privacy policies before providing any personal information.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '9. Children\'s Privacy',
              'TREEmate does not knowingly collect personal information from individuals under 13 years of age. If you believe we have collected such information, please contact us to remove it.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '10. Changes to This Policy',
              'TREEmate may update this Privacy Policy periodically. We will notify you of significant changes through email or app notifications. We encourage you to review this policy regularly to stay informed about our data practices.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              '11. Contact Information',
              'For any questions or concerns regarding this Privacy Policy, please contact us at:\n\n'
                  'Email: contact@treemate.in\n'
                  'Address: Laipuli Kaptanchuk Village, Tinsukia, Assam, India',
            ),
            const SizedBox(height: 30.0),
            Center(
              child:  Icon(
                Icons.policy,
                size: 80,
                color: Colors.green[700],
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.green[100],
    );
  }
  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.green[800]),
        ),
        const SizedBox(height: 8.0),
        Text(
          content,
          style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
        ),
      ],
    );
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us', style: TextStyle(color: Colors.green[800])),
        backgroundColor: Colors.green[100],
        iconTheme: IconThemeData(color: Colors.green[800]),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TREEmate: Growing a Greener World',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.green[900]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),

            _buildSection(
              'Our Vision',
              'At TREEmate, we’re not just building an app—we\'re creating a movement. We believe in a world where technology meets nature, making plant care as simple, intuitive, and impactful as possible. Our mission is clear: to inspire people to reconnect with the earth, one plant at a time.',
            ),

            const SizedBox(height: 20.0),

            _buildSection(
              'For Everyone',
              'TREEmate is for those who care about more than just greenery—it’s for those who want to make a difference. We’ve designed a platform that empowers everyone, from the curious beginner to the experienced gardener, to take control of their plant care with confidence and precision. Our features—Plant Manager, Plant AI, and Community—are built to be powerful yet simple, helping you get the information you need and connect with a like-minded community.',
            ),


            const SizedBox(height: 20.0),

            _buildSection(
              'More than just Plant Care',
              'Beyond plant care, TREEmate offers a curated selection of gardening and eco-friendly products. We’re here to make sustainable living accessible and support a greener lifestyle.',
            ),

            const SizedBox(height: 20.0),
            Text(
              'It’s not just about growing plants; it\'s about growing a greener world, together. Welcome to TREEmate—let’s make an impact.',
              style: TextStyle(fontSize: 18.0, fontStyle: FontStyle.italic, color: Colors.green[800]),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30.0),
            Center(
              // child:  Icon(
              //   Icons.eco,
              //   size: 80,
              //   color: Colors.green[700],
              // ),
              child:  Image.asset(
                'assets/icons/appicon.png',
                width: 80,
                height: 80,
                //color: Colors.green[700],
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.green[100], // Light green background
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.green[800]),
        ),
        const SizedBox(height: 8.0),
        Text(
          content,
          style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
        ),
      ],
    );
  }
}

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _reasonController = TextEditingController();
  bool _deleteButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_checkWordCount);
  }

  void _checkWordCount() {
    setState(() {
      _deleteButtonEnabled = _reasonController.text.trim().split(' ').length >= 10;
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
  // void _showDeleteAccountConfirmation(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Delete Account'),
  //         content: Text(
  //             'Are you sure you want to delete your account? This action is irreversible.'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //               child: Text('Delete'),
  //               onPressed: () async {
  //                 Navigator.of(context).pop();
  //                 final UserController _userController = UserController();
  //                 await _userController.init(context);
  //                 bool deleted = await _userController.deleteUser(context);
  //                 if (deleted) {
  //                   Navigator.pushNamedAndRemoveUntil(
  //                       context, '/login', (route) => false);
  //                 }
  //               }),
  //         ],
  //       );
  //     },
  //   );
  // }
  void _showDeleteAccountConfirmation(BuildContext context) { // Added BuildContext
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action is irreversible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: const Text('Delete'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final UserController userController = UserController();
                  await userController.init(context);
                  bool deleted = await userController.deleteUser(context);
                  if (deleted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  }
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Please tell us why you want to delete your account.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter at least 10 words...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteButtonEnabled ? () => _showDeleteAccountConfirmation(context) : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _deleteButtonEnabled ? Colors.red[700] : Colors.grey[500],
                elevation: 0,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Delete Account'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}