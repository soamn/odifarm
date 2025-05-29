import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:odifarm/models/country.dart';
import 'package:odifarm/services/auth_service.dart';
import 'package:odifarm/services/user_service.dart';
import 'package:odifarm/models/user.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  UserModel? user;
  bool isLoading = true;

  final _formKeyBasic = GlobalKey<FormState>();
  final _formKeyContact = GlobalKey<FormState>();

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isUpdatingBasic = false;
  bool _isUpdatingContact = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final email = await AuthService().fetchUserByemail();
      final fetchedUser = await UserService().fetchUserData(email);

      if (fetchedUser != null) {
        user = fetchedUser;
        firstNameController.text = user!.firstName ?? '';
        lastNameController.text = user!.lastName ?? '';
        emailController.text = user!.email;
        phoneController.text = user!.phone ?? '';
      } else {
        _showSnack("User data not found");
      }
    } catch (e) {
      _showSnack("Failed to load user data");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _updateBasicInfo() async {
    if (_formKeyBasic.currentState!.validate()) {
      setState(() => _isUpdatingBasic = true);
      try {
        await UserService().updateBasicInfo(
          email: emailController.text,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
        );
        _showSnack("Basic information updated");
      } catch (e) {
        _showSnack("Failed to update basic information");
      } finally {
        setState(() => _isUpdatingBasic = false);
      }
    }
  }

  void _updateContactInfo() async {
    if (_formKeyContact.currentState!.validate()) {
      setState(() => _isUpdatingContact = true);
      try {
        await UserService().updateContactInfo(
          email: emailController.text,
          phone: phoneController.text,
        );
        _showSnack("Contact information updated");
      } catch (e) {
        _showSnack("Failed to update contact information");
      } finally {
        setState(() => _isUpdatingContact = false);
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _sectionContainer(
    String title,
    GlobalKey<FormState> formKey,
    List<Widget> children,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _rectangularButton(
    String text,
    VoidCallback? onPressed, {
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(text),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.white),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
        child: Column(
          children: [
            _sectionContainer("Basic Info", _formKeyBasic, [
              _inputField("First Name", firstNameController, required: true),
              _inputField("Last Name", lastNameController, required: true),
              const SizedBox(height: 10),
              _rectangularButton(
                "Update Basic Info",
                _updateBasicInfo,
                loading: _isUpdatingBasic,
              ),
            ]),
            _sectionContainer("Contact Info", _formKeyContact, [
              _inputField(
                "Email",
                emailController,
                enabled: false,
                keyboardType: TextInputType.emailAddress,
              ),
              _inputField(
                "Phone",
                phoneController,
                required: true,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              _rectangularButton(
                "Update Contact Info",
                _updateContactInfo,
                loading: _isUpdatingContact,
              ),
            ]),
            // Address section moved to separate widget
            _AddressSection(user: user!),
          ],
        ),
      ),
    );
  }
}

// --------------------- Address Section Widget ---------------------
class _AddressSection extends StatefulWidget {
  final UserModel user;

  const _AddressSection({required this.user});

  @override
  __AddressSectionState createState() => __AddressSectionState();
}

class __AddressSectionState extends State<_AddressSection> {
  final _formKeyAddress = GlobalKey<FormState>();

  late final TextEditingController addressLine1Controller;
  late final TextEditingController addressLine2Controller;
  late final TextEditingController streetController;
  late final TextEditingController cityController;
  late final TextEditingController stateController;
  late final TextEditingController zipCodeController;

  String? selectedCountry;
  List<Country> countryList = [];
  bool _isUpdatingAddress = false;
  bool _isLoadingCountries = true;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    addressLine1Controller = TextEditingController(text: user.addressline1);
    addressLine2Controller = TextEditingController(text: user.addressline2);
    streetController = TextEditingController(text: user.street);
    cityController = TextEditingController(text: user.city);
    stateController = TextEditingController(text: user.state);
    zipCodeController = TextEditingController(text: user.zipCode);
    selectedCountry = user.countryId;

    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final fetched = await UserService().fetchCountries();
      setState(() {
        countryList = List<Country>.from(fetched);
        _isLoadingCountries = false;
      });
    } catch (e) {
      _showSnack("Failed to load countries: $e");
      setState(() {
        _isLoadingCountries = false;
      });
    }
  }

  @override
  void dispose() {
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _updateAddressInfo() async {
    if (_formKeyAddress.currentState!.validate()) {
      setState(() => _isUpdatingAddress = true);
      try {
        final address = UserModel(
          id: widget.user.id,
          email: widget.user.email,
          addressline1: addressLine1Controller.text,
          addressline2: addressLine2Controller.text,
          state: stateController.text,
          city: cityController.text,
          street: streetController.text,
          zipCode: zipCodeController.text,
          countryId: selectedCountry,
        );
        await UserService().updateAddressInfo(address: address);
        _showSnack("Address information updated");
      } catch (e) {
        _showSnack("$e");
      } finally {
        setState(() => _isUpdatingAddress = false);
      }
    }
  }

  Widget _countryDropdown() {
    if (_isLoadingCountries) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedCountry,
        decoration: const InputDecoration(
          labelText: "Country",
          border: OutlineInputBorder(),
        ),
        items: countryList
            .map(
              (country) => DropdownMenuItem(
                value: country.id,
                child: Text(country.name),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedCountry = value;
          });
        },
        validator: (value) =>
            (value == null || value.isEmpty) ? "Country is required" : null,
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _rectangularButton(
    String text,
    VoidCallback? onPressed, {
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Form(
        key: _formKeyAddress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _inputField(
              "Address Line 1",
              addressLine1Controller,
              required: true,
            ),
            _inputField("Address Line 2", addressLine2Controller),
            _inputField("Street", streetController, required: true),
            _inputField("City", cityController, required: true),
            _inputField("State", stateController, required: true),
            _inputField(
              "Zip Code",
              zipCodeController,
              keyboardType: TextInputType.number,
              required: true,
            ),
            _countryDropdown(),
            const SizedBox(height: 10),
            _rectangularButton(
              "Update Address Info",
              _updateAddressInfo,
              loading: _isUpdatingAddress,
            ),
          ],
        ),
      ),
    );
  }
}
