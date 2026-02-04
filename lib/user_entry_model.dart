class UserData {
  final String stateName;
  final int stateID;
  final String district;
  final int districtID;
  final String block;
  final int blockID;
  final String facility;
  final int facilityID;
  final String subfacility;
  final int subfacilityID;
  final int rchID;
  final String lmpdate;
  final String edddate;
  final String createdOn;
  final String createdBy;

  UserData({
    required this.stateName,
    required this.stateID,
    required this.district,
    required this.districtID,
    required this.block,
    required this.blockID,
    required this.facility,
    required this.facilityID,
    required this.subfacility,
    required this.subfacilityID,
    required this.rchID,
    required this.lmpdate,
    required this.edddate,
    required this.createdOn,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'stateName': stateName,
      'stateID': stateID,
      'district': district,
      'districtID': districtID,
      'block': block,
      'blockID': blockID,
      'facility': facility,
      'facilityID': facilityID,
      'subFacility': subfacility,
      'subFacilityID': subfacilityID,
      'rchID': rchID,
      'lmpDate': lmpdate,
      'eddDate': edddate,
      'createdOn': createdOn,
      'createdBy': createdBy,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      stateName: map['stateName'],
      stateID: map['stateID'],
      district: map['district'],
      districtID: map['districtID'],
      block: map['block'],
      blockID: map['blockID'],
      facility: map['facility'],
      facilityID: map['facilityID'],
      subfacility: map['subFacility'],
      subfacilityID: map['subFacilityID'],
      rchID: map['rchID'],
      lmpdate: map['lmpDate'],
      edddate: map['eddDate'],
      createdOn: map['createdOn'],
      createdBy: map['createdBy'],
    );
  }
  Map<String, dynamic> toJson() => toMap();
}
