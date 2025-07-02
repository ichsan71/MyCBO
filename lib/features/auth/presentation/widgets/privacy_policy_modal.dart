import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';
import 'package:test_cbo/features/auth/presentation/bloc/privacy_policy_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyModal extends StatefulWidget {
  const PrivacyPolicyModal({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyModal> createState() => _PrivacyPolicyModalState();
}

class _PrivacyPolicyModalState extends State<PrivacyPolicyModal> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReachedBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _hasReachedBottom = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _closeModal(BuildContext context, {bool agreed = false}) {
    if (!agreed) {
      // Reset checkbox state when closing without agreement
      context.read<PrivacyPolicyBloc>().add(
            const PrivacyPolicyAgreedChanged(false),
          );
    }
    context.read<PrivacyPolicyBloc>().add(
          const PrivacyPolicyModalVisibilityChanged(false),
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closeModal(context);
        return false;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 8,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Privacy Policy',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                    onPressed: () => _closeModal(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: RawScrollbar(
                    controller: _scrollController,
                    thumbColor: AppTheme.primaryColor.withOpacity(0.6),
                    radius: const Radius.circular(8),
                    thickness: 6,
                    thumbVisibility: true,
                    trackVisibility: true,
                    trackColor: Colors.grey[200],
                    trackRadius: const Radius.circular(8),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Last Updated: July 02, 2025'),
                            const SizedBox(height: 16),
                            _buildPolicyText(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!_hasReachedBottom)
                Text(
                  'Scroll sampai bawah untuk menyetujui',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasReachedBottom
                      ? AppTheme.primaryColor
                      : Colors.grey[400],
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: _hasReachedBottom
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                ),
                onPressed: _hasReachedBottom
                    ? () => _closeModal(context, agreed: true)
                    : null,
                child: Text(
                  'Saya Mengerti',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPolicyText() {
    return Text(
      '''This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.

We use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy.

Interpretation and Definitions

Interpretation
The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.

Definitions
For the purposes of this Privacy Policy:

• Account means a unique account created for You to access our Service or parts of our Service.

• Affiliate means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.

• Application refers to My BCO, the software program provided by the Company.

• Company (referred to as either "the Company", "We", "Us" or "Our" in this Agreement) refers to Mazta Farma.

• Country refers to: Indonesia

• Device means any device that can access the Service such as a computer, a cellphone or a digital tablet.

• Personal Data is any information that relates to an identified or identifiable individual.

• Service refers to the Application.

• Service Provider means any natural or legal person who processes the data on behalf of the Company.

• Usage Data refers to data collected automatically, either generated by the use of the Service or from the Service infrastructure itself.

Types of Data Collected

Personal Data
While using Our Service, We may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You. This may include:

• Email address
• First name and last name
• Usage Data
• Location data
• Device information

Use of Your Personal Data
The Company may use Personal Data for the following purposes:

• To provide and maintain our Service
• To manage Your Account
• For the performance of a contract
• To contact You
• To provide You with news and updates
• To manage Your requests
• For business transfers
• For other purposes with Your consent

Security of Your Personal Data
The security of Your Personal Data is important to Us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure.

Contact Us
If you have any questions about this Privacy Policy, You can contact us:
By email: it_ho@maztafarma.com''',
      style: GoogleFonts.poppins(
        fontSize: 14,
        height: 1.6,
        color: Colors.black87,
      ),
    );
  }
}
