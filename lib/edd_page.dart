import 'package:edd_calc/user_details_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'local_data_storage.dart';
import 'package:flutter/services.dart';
import 'user_entry_model.dart';
import 'user_database.dart';
import 'device_id.dart';

class EddCalculatorPage extends StatefulWidget {
  @override
  _EddCalculatorPageState createState() => _EddCalculatorPageState();
}

class _EddCalculatorPageState extends State<EddCalculatorPage> {
  Map<String, dynamic>? userDetails;
  DateTime _selectedLmpDate = DateTime.now();
  final DateFormat _dateFormatter = DateFormat('MMMM d, yyyy');
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _printAllUserData() async {
    List<UserData> users = await UserDatabase.instance.getAllUsers();

    for (var user in users) {
      print('---');
      print('State: ${user.stateName}');
      print('District: ${user.district}');
      print('Block: ${user.block}');
      print('Facility: ${user.facility}');
      print('SubFacility: ${user.subfacility}');
      print('LMP Date: ${user.lmpdate}');
      print('EDD Date: ${user.edddate}');
      print('Created On: ${user.createdOn}');
      print('Created By: ${user.createdBy}');
      print('📦 Total entries in DB: ${users.length}');
    }
  }

  Future<void> _saveEntryToDatabase() async {
    if (userDetails == null) return;

    final createdBy = await DeviceIDHelper.getDeviceId();
    final createdOn = DateTime.now().toIso8601String();
    final eddDate = _selectedLmpDate.add(Duration(days: 283));

    final userEntry = UserData(
      stateName: userDetails!['stateName'],
      stateID: 0,
      district: userDetails!['districtName'],
      districtID: 0,
      block: userDetails!['block'],
      blockID: 0,
      facility: userDetails!['facility'],
      facilityID: 0,
      subfacility: userDetails!['subFacility'],
      subfacilityID: 0,
      rchID: 0,
      lmpdate: _selectedLmpDate.toIso8601String(),
      edddate: eddDate.toIso8601String(),
      createdOn: createdOn,
      createdBy: createdBy,
    );

    await UserDatabase.instance.insertUser(userEntry);
    await _printAllUserData();

    // print('Saving user entry...');
    // int id = await UserDatabase.instance.insertUser(userEntry);
    // print('Inserted record with id: $id');
  }

  Future<void> _loadUserDetails() async {
    final details = await LocalStorage.getUserDetails();
    setState(() {
      userDetails = details;
    });
  }

  // void _resetUserDetails() async {
  //   await LocalStorage.clearUserDetails();
  //   Navigator.pop(context);
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (_) => UserDetailsPage()),
  //   );
  // }

  Future<void> _pickLmpDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedLmpDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(
                255,
                233,
                145,
                169,
              ), // Header background & selected date
              onPrimary: Colors.white, // Text/icon on header
              onSurface: Colors.black, // Default day text
              surface: const Color.fromARGB(
                255,
                255,
                231,
                238,
              ), // Background of the calendar
            ),
            dialogBackgroundColor: Color(
              0xFFFFF5F8,
            ), // Background of entire dialog
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 233, 145, 169),
                foregroundColor: Colors.white, // Cancel/OK button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedLmpDate = picked;
        _showResults = true;
      });
      await _saveEntryToDatabase();
      print('DB entry saved');
    }
  }

  String _calculateGestationalAge() {
    final now = DateTime.now();
    final difference = now.difference(_selectedLmpDate);
    final weeks = (difference.inDays / 7).floor();

    return 'Gestational Age is\n$weeks ${weeks == 1 ? 'week' : 'weeks'}';
  }

  // void _showResetConfirmationDialog() {
  //   showDialog(
  //     context: context,
  //     barrierColor: const Color.fromARGB(117, 158, 158, 158),
  //     builder: (context) => AlertDialog(
  //       title: Text(
  //         'Reset Account',
  //         style: TextStyle(
  //           fontWeight: FontWeight.bold,
  //           fontFamily: 'Sansation',
  //           fontSize: 25,
  //         ),
  //       ),
  //       content: Text(
  //         'Are you sure you want to reset your account?',
  //         style: TextStyle(fontWeight: FontWeight.w100),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'Cancel',
  //             style: TextStyle(fontWeight: FontWeight.w200),
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _resetUserDetails();
  //           },
  //           child: Text('Reset', style: TextStyle(fontWeight: FontWeight.w200)),
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<bool> _showExitConfirmationDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierColor: const Color.fromARGB(148, 70, 70, 70),
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 231, 238),
        title: Text(
          'Exiting?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Sansation',
            fontSize: 25,
          ),
        ),
        content: Text(
          'Are you sure you want to exit the app?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Don't exit
            child: Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Confirm exit
            child: Text('Yes', style: TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 253, 191, 208),
            ),
          ),
        ],
      ),
    );

    // If user presses outside the dialog, treat as cancel
    return shouldExit ?? false;
  }

  Widget buildSuperscriptNumber(String number, String suffix) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontFamily: 'Sansation',
        ),
        children: [
          TextSpan(text: number),
          WidgetSpan(
            child: Transform.translate(
              offset: const Offset(2, -6),
              child: Text(
                suffix,
                textScaleFactor: 0.6,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          TextSpan(text: '  Trimester'),
        ],
      ),
    );
  }

  Widget _buildTrimesterBox(Widget title, String dateRange) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 253, 191, 208)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          title,
          // Text(
          //   title,
          // textAlign: TextAlign.center,
          // style: TextStyle(
          //   fontWeight: FontWeight.bold,
          //   fontFamily: 'Sansation',
          //   fontSize: 16,
          // ),
          // ),
          // SizedBox(height: 5),
          // Text(
          //   dateRange,
          //   textAlign: TextAlign.center,
          //   style: TextStyle(fontFamily: 'Sansation'),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final edd = _selectedLmpDate.add(Duration(days: 283));
    final firstTrimesterEnd = _selectedLmpDate.add(Duration(days: 90));
    final secondTrimesterEnd = _selectedLmpDate.add(Duration(days: 180));

    return WillPopScope(
      onWillPop: () async {
        final exit = await _showExitConfirmationDialog();
        if (exit) {
          SystemNavigator.pop();
        }
        return false; // Prevent automatic pop
      },
      child: Scaffold(
        drawer: Drawer(
          elevation: 20.0,
          backgroundColor: const Color.fromARGB(255, 255, 231, 238),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 253, 191, 208),
                  ),
                  padding: EdgeInsetsGeometry.symmetric(),
                  curve: Curves.easeOutExpo,
                  child: Center(
                    child: Text(
                      'GA\nCalculator',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sansation',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              //updating user details
              ListTile(
                leading: Icon(Icons.person_2_rounded),
                title: Text('Update Your Details'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserDetailsPage(isEditMode: true),
                    ),
                  ).then((result) {
                    if (result == true) {
                      _loadUserDetails();
                    }
                  });
                },
              ),

              //reset user details with an alert bar pop up
              // ListTile(
              //   leading: Icon(Icons.refresh),
              //   title: Text('Reset Account'),
              //   onTap: () {
              //     _showResetConfirmationDialog();
              //   },
              // ),

              // app exit
              ListTile(
                leading: Icon(Icons.exit_to_app_rounded),
                title: Text('Exit App'),
                onTap: () async {
                  bool shouldExit = await _showExitConfirmationDialog();
                  if (shouldExit) {
                    SystemNavigator.pop(); //closes app
                  }
                },
              ),

              Spacer(),
            ],
          ),
        ),

        // Padding(
        //   padding: const EdgeInsets.symmetric(
        //     horizontal: 16.0,
        //     vertical: 20,
        //   ),
        //   child: ElevatedButton(
        //     onPressed: _resetUserDetails,
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: const Color.fromARGB(255, 253, 191, 208),
        //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //     ),
        //     child: Center(
        //       child: Text(
        //         "Reset & Enter New Details",
        //         style: TextStyle(
        //           fontWeight: FontWeight.w800,
        //           fontFamily: 'Sansation',
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        backgroundColor: const Color.fromARGB(255, 255, 231, 238),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/jhpiego_splash_logo.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),

        appBar: AppBar(
          title: Text(
            'GA Calculator',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontFamily: 'Sansation',
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 253, 191, 208),
        ),
        body: userDetails == null
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Saved Info
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 253, 191, 208),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome! Here's your saved info:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Sansation',
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "State Name: ${userDetails!['stateName']}",
                              style: TextStyle(fontFamily: 'Sansation'),
                            ),
                            Text(
                              "District Name: ${userDetails!['districtName']}",
                              style: TextStyle(fontFamily: 'Sansation'),
                            ),
                            Text(
                              "Block: ${userDetails!['block']}",
                              style: TextStyle(fontFamily: 'Sansation'),
                            ),
                            Text(
                              "Facility: ${userDetails!['facility']}",
                              style: TextStyle(fontFamily: 'Sansation'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Sub Facility: ${userDetails!['subFacility']}",
                                  style: TextStyle(fontFamily: 'Sansation'),
                                ),
                                InkWell(
                                  onTap: () async {
                                    // Navigator.pop(context);
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            UserDetailsPage(isEditMode: true),
                                      ),
                                    ).then((result) {
                                      if (result == true) {
                                        _loadUserDetails();
                                      }
                                    });
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: const Color.fromARGB(170, 0, 0, 0),
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40),

                      // LMP Picker
                      InkWell(
                        onTap: _pickLmpDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Enter your LMP date here",
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Sansation',
                              fontSize: 22,
                            ),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: const Color.fromARGB(103, 251, 155, 181),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dateFormatter.format(_selectedLmpDate),
                                style: TextStyle(fontFamily: 'Sansation'),
                              ),
                              Icon(
                                Icons.edit_calendar_rounded,
                                color: const Color.fromARGB(170, 0, 0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // // Submit Button
                      // Center(
                      //   child: ElevatedButton(
                      //     onPressed: () {
                      //       setState(() {
                      //         _showResults = true;
                      //       });
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: const Color.fromARGB(
                      //         255,
                      //         253,
                      //         191,
                      //         208,
                      //       ),
                      //       padding: EdgeInsets.symmetric(
                      //         horizontal: 46,
                      //         vertical: 18,
                      //       ),
                      //     ),
                      //     child: Text(
                      //       "Submit",
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.w800,
                      //         fontFamily: 'Sansation',
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      if (_showResults) ...[
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            "Expected delivery date is\n${_dateFormatter.format(edd)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              fontFamily: 'Sansation',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 25),

                        Center(
                          child: Text(
                            _calculateGestationalAge(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              fontFamily: 'Sansation',
                            ),
                          ),
                        ),
                        SizedBox(height: 12),

                        Divider(
                          color: const Color.fromARGB(255, 253, 191, 208),
                          thickness: 1,
                          indent: 15,
                          endIndent: 15,
                        ),

                        SizedBox(height: 10),

                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _buildTrimesterBox(
                                  Column(
                                    children: [
                                      buildSuperscriptNumber('1', 'st'),
                                      Text(
                                        'ends on\n${_dateFormatter.format(firstTrimesterEnd)}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Sansation',
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // '1st Trimester\nends on\n${_dateFormatter.format(firstTrimesterEnd)}',
                                  '',
                                  // "${_dateFormatter.format(_selectedLmpDate)} to ${_dateFormatter.format(firstTrimesterEnd)}",
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: _buildTrimesterBox(
                                  Column(
                                    children: [
                                      buildSuperscriptNumber('2', 'nd'),
                                      Text(
                                        'ends on\n${_dateFormatter.format(secondTrimesterEnd)}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Sansation',
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // "2nd Trimester\nends on\n${_dateFormatter.format(secondTrimesterEnd)}",
                                  '',
                                  // "${_dateFormatter.format(firstTrimesterEnd.add(Duration(days: 1)))} to ${_dateFormatter.format(secondTrimesterEnd)}",
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: _buildTrimesterBox(
                            Column(
                              children: [
                                buildSuperscriptNumber('3', 'rd'),
                                Text(
                                  'ends on\n${_dateFormatter.format(edd)}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Sansation',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            // "3rd Trimester\nends on\n${_dateFormatter.format(edd)}",
                            '',
                            // "${_dateFormatter.format(secondTrimesterEnd.add(Duration(days: 1)))} to ${_dateFormatter.format(edd)}",
                          ),
                        ),
                      ],

                      SizedBox(height: 40),

                      // Center(
                      //   child: ElevatedButton(
                      //     onPressed: _resetUserDetails,
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: const Color.fromARGB(
                      //         255,
                      //         253,
                      //         191,
                      //         208,
                      //       ),
                      //       padding: EdgeInsets.symmetric(
                      //         horizontal: 42,
                      //         vertical: 16,
                      //       ),
                      //     ),
                      //     child: Text(
                      //       "Reset & Enter New Details",
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.w800,
                      //         fontFamily: 'Sansation',
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
