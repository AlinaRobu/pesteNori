import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import '../../controllers/UserProfileCtrl.dart';
import 'package:peste_nori/globals.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  _WelcomeScreenState();

  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _sex;
  bool _showBirthdayBadge = false;

  static const Color primaryColor = Color(0xFF315DCC);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              Color(0xFFEAF3FF),
              Color(0xFFD6E8FF),
            ],
          ),
        ),
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Center(
                      child: Container(
                        width: 100,
                        height: 90,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/logo_welcome.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: 
                        Text(
                          translations.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF17223B),
                          ),
                        ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      translations.welcomeTo,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17223B),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      translations.createProfileFor,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Color(0xFF667085),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // First name
                    Text(
                      translations.firstName,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    buildTextField(
                      controller: _firstNameController,
                      hint: translations.addFirstName,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 18),

                    // Last name
                    Text(translations.name,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    buildTextField(
                      controller: _lastNameController,
                      hint: translations.addName,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 18),

                    // Date of birth
                    Text(
                      translations.dateOfBirth,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    
                    InkWell(
                      onTap: _selectDateOfBirth,
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 50,
                        child: InputDecorator(
                          decoration: _inputDecoration(
                            hint: translations.selectDateOfBirth,
                            icon: Icons.calendar_today_outlined,
                            suffixIcon: const Icon(
                              Icons.calendar_month_rounded,
                              color: primaryColor,
                            ),
                          ),
                          child: Text(
                            _dateOfBirth == null
                                ? 'DD / MM / YYYY'
                                : '${_dateOfBirth!.day.toString().padLeft(2, '0')} / '
                                  '${_dateOfBirth!.month.toString().padLeft(2, '0')} / '
                                  '${_dateOfBirth!.year}',
                            style: TextStyle(
                              fontSize: 17,
                              color: _dateOfBirth == null
                                  ? Colors.blueGrey
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Sex
                    const Text(
                      'Sex',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSexOption(
                          value: 'M',
                          label: translations.male,
                          icon: Icons.male_rounded,
                        ),
                        const SizedBox(width: 12),
                        _buildSexOption(
                          value: 'F',
                          label: translations.female,
                          icon: Icons.female_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Badge checkbox
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showBirthdayBadge = !_showBirthdayBadge;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _showBirthdayBadge
                                    ? primaryColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: _showBirthdayBadge
                                      ? primaryColor
                                      : const Color(0xFFD0D5DD),
                                  width: 1.5,
                                ),
                                boxShadow: _showBirthdayBadge
                                    ? [
                                        BoxShadow(
                                          color: primaryColor.withValues(alpha: 0.20),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: _showBirthdayBadge
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 17,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                translations.showBirthdayBadge,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _showBirthdayBadge
                                      ? primaryColor
                                      : const Color(0xFF344054),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Submit button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.cloud),
                        label: Text(
                          translations.contin,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      )
    );
  }

///----------------------------------------- PRIVATE METHODS---------------------------------///
Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: translations.selectDateOfBirth,
    );

    if (date != null && mounted) {
      setState(() => _dateOfBirth = date);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_firstNameController.text == "") {
      _showMessage(translations.emptyFirstName);
      return;
    }

    if (_lastNameController.text == "") {
      _showMessage(translations.emptyName);
      return;
    }

    if (_dateOfBirth == null) {
      _showMessage(translations.emptyDateOfBirth);
      return;
    }

    if (_sex == null) {
      _showMessage(translations.emptySex);
      return;
    }

    // Use the collected data here.
  final UserProfileCtrl _userProfileCtrl = UserProfileCtrl();
  Timestamp timestamp = Timestamp.fromDate(_dateOfBirth!);

    Map<String, Object> data = {"firstName": _firstNameController.text, "lastName": _lastNameController.text, 
    "dateOfBirth": timestamp, "sex": _sex!, "showBirthdayBadge": _showBirthdayBadge};
    _userProfileCtrl.setUserMainData(data);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blueGrey),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD9DFEA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD9DFEA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildSexOption({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final selected = _sex == value;

    return InkWell(
        onTap: () => setState(() => _sex = value),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          height: 65,
          width: 150,
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE9EFFF)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? primaryColor
                  : const Color(0xFFD9DFEA),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 27,
                color: selected ? primaryColor : Colors.blueGrey,
              ),
             Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? primaryColor : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: TextField(
        textCapitalization: TextCapitalization.words,
        textAlignVertical: TextAlignVertical.center,
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 17,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 17,
          ),
          prefixIcon: icon != null ? Icon(
            icon,
            color: Colors.blueGrey,
            size: 27,
          ): SizedBox(width: 0),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
        ),
      ),
    );
  }
}
