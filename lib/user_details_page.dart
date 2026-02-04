import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_data_storage.dart';
import 'edd_page.dart';

class UserDetailsPage extends StatefulWidget {
  final bool isEditMode;

  const UserDetailsPage({Key? key, this.isEditMode = false}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _filteredDistricts = [];

  int? selectedStateId;
  int? selectedDistrictId;
  String? block, facility, subFacility;

  @override
  void initState() {
    super.initState();
    _loadDataAndCheckUser();
  }

  Future<void> _loadDataAndCheckUser() async {
    final allStates = await LocalDataLoader.loadStates();
    final allDistricts = await LocalDataLoader.loadDistricts();

    _states = allStates
        .where((s) => s['StateID'] != null && s['StateName'] != null)
        .toList();

    _districts = allDistricts
        .where(
          (d) =>
              d['DistrictID'] != null &&
              d['District'] != null &&
              d['StateID'] != null,
        )
        .toList();

    final prefs = await SharedPreferences.getInstance();
    final hasData = prefs.containsKey('user_details');

    if (!widget.isEditMode && hasData) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EddCalculatorPage()),
      );
      return;
    }

    if (widget.isEditMode && hasData) {
      final saved = jsonDecode(prefs.getString('user_details')!);
      setState(() {
        selectedStateId = saved['stateId'];
        selectedDistrictId = saved['districtId'];
        block = saved['block'];
        facility = saved['facility'];
        subFacility = saved['subFacility'];
        _updateFilteredDistricts(selectedStateId!, preserveDistrict: true);
      });
    } else {
      setState(() {}); // show form if not in edit mode
    }
  }

  void _updateFilteredDistricts(int stateId, {bool preserveDistrict = false}) {
    final filtered = _districts.where((d) => d['StateID'] == stateId).toList();

    setState(() {
      _filteredDistricts = filtered;
      if (!preserveDistrict) {
        selectedDistrictId = null;
      }
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final selectedState = _states.firstWhere(
        (s) => s['StateID'] == selectedStateId,
        orElse: () => {'StateName': ''},
      );

      final selectedDistrict = _filteredDistricts.firstWhere(
        (d) => d['DistrictID'] == selectedDistrictId,
        orElse: () => {'District': ''},
      );

      await LocalStorage.saveUserDetails({
        'stateId': selectedStateId,
        'stateName': selectedState['StateName'],
        'districtId': selectedDistrictId,
        'districtName': selectedDistrict['District'],
        'block': block,
        'facility': facility,
        'subFacility': subFacility,
      });

      if (widget.isEditMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You have successfully updated your details!🎉',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        Navigator.pushReplacementNamed(context, '/edd');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontFamily: 'Sansation',
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 253, 191, 208),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 231, 238),
      body: _states.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'State',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Sansation',
                          ),
                        ),
                        value: selectedStateId,
                        items: _states.map((state) {
                          return DropdownMenuItem<int>(
                            value: state['StateID'],
                            child: Text(state['StateName']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedStateId = val;
                            _updateFilteredDistricts(val!);
                          });
                        },
                        validator: (val) =>
                            val == null ? 'Select a state' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'District',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Sansation',
                          ),
                        ),
                        value: selectedDistrictId,
                        items: _filteredDistricts.map((district) {
                          return DropdownMenuItem<int>(
                            value: district['DistrictID'],
                            child: Text(district['District']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedDistrictId = val;
                          });
                        },
                        validator: (val) =>
                            val == null ? 'Select a district' : null,
                      ),
                      const SizedBox(height: 10),
                      buildTextField(
                        "Block",
                        (val) => block = val,
                        block,
                        maxlength: 30,
                      ),
                      buildTextField(
                        "Facility",
                        (val) => facility = val,
                        facility,
                        maxlength: 50,
                      ),
                      buildTextField(
                        "Sub Facility",
                        (val) => subFacility = val,
                        subFacility,
                        maxlength: 50,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            253,
                            191,
                            208,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 54,
                            vertical: 25,
                          ),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Sansation',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildTextField(
    String label,
    Function(String?) onSaved,
    String? initialValue, {
    int maxlength = 15,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontFamily: 'Sansation',
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (value.length > maxlength) {
            return 'Must be $maxlength characters or less';
          }
          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
            return 'Only letters and spaces are allowed';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }
}
