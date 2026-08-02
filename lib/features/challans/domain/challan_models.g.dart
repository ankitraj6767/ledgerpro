// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challan_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CapturedPortalPayload _$CapturedPortalPayloadFromJson(
  Map<String, dynamic> json,
) => _CapturedPortalPayload(
  challanNumber: json['challanNumber'] as String?,
  uidNumber: json['uidNumber'] as String?,
  challanDate: json['challanDate'] == null
      ? null
      : DateTime.parse(json['challanDate'] as String),
  validUntil: json['validUntil'] == null
      ? null
      : DateTime.parse(json['validUntil'] as String),
  consignorName: json['consignorName'] as String?,
  consigneeName: json['consigneeName'] as String?,
  generatedFrom: json['generatedFrom'] as String?,
  sourceLocation: json['sourceLocation'] as String?,
  destination: json['destination'] as String?,
  vehicleType: json['vehicleType'] as String?,
  vehicleNumber: json['vehicleNumber'] as String?,
  mineralName: json['mineralName'] as String?,
  quantity: (json['quantity'] as num?)?.toDouble(),
  quantityText: json['quantityText'] as String?,
  quantityUnit: json['quantityUnit'] as String?,
  royaltyAmountPaise: (json['royaltyAmountPaise'] as num?)?.toInt(),
  rawFields:
      (json['rawFields'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  portalMessage: json['portalMessage'] as String?,
  responseHash: json['responseHash'] as String?,
  capturedAt: json['capturedAt'] == null
      ? null
      : DateTime.parse(json['capturedAt'] as String),
);

Map<String, dynamic> _$CapturedPortalPayloadToJson(
  _CapturedPortalPayload instance,
) => <String, dynamic>{
  'challanNumber': instance.challanNumber,
  'uidNumber': instance.uidNumber,
  'challanDate': instance.challanDate?.toIso8601String(),
  'validUntil': instance.validUntil?.toIso8601String(),
  'consignorName': instance.consignorName,
  'consigneeName': instance.consigneeName,
  'generatedFrom': instance.generatedFrom,
  'sourceLocation': instance.sourceLocation,
  'destination': instance.destination,
  'vehicleType': instance.vehicleType,
  'vehicleNumber': instance.vehicleNumber,
  'mineralName': instance.mineralName,
  'quantity': instance.quantity,
  'quantityText': instance.quantityText,
  'quantityUnit': instance.quantityUnit,
  'royaltyAmountPaise': instance.royaltyAmountPaise,
  'rawFields': instance.rawFields,
  'portalMessage': instance.portalMessage,
  'responseHash': instance.responseHash,
  'capturedAt': instance.capturedAt?.toIso8601String(),
};

_ChallanCaptureResult _$ChallanCaptureResultFromJson(
  Map<String, dynamic> json,
) => _ChallanCaptureResult(
  success: json['success'] as bool,
  payload: json['payload'] == null
      ? null
      : CapturedPortalPayload.fromJson(json['payload'] as Map<String, dynamic>),
  errorKind: json['errorKind'] as String?,
  errorMessage: json['errorMessage'] as String?,
  portalUrl: json['portalUrl'] as String?,
  status: $enumDecode(_$ChallanVerificationStatusEnumMap, json['status']),
  method: $enumDecode(_$ChallanVerificationMethodEnumMap, json['method']),
);

Map<String, dynamic> _$ChallanCaptureResultToJson(
  _ChallanCaptureResult instance,
) => <String, dynamic>{
  'success': instance.success,
  'payload': instance.payload,
  'errorKind': instance.errorKind,
  'errorMessage': instance.errorMessage,
  'portalUrl': instance.portalUrl,
  'status': _$ChallanVerificationStatusEnumMap[instance.status]!,
  'method': _$ChallanVerificationMethodEnumMap[instance.method]!,
};

const _$ChallanVerificationStatusEnumMap = {
  ChallanVerificationStatus.portalCaptured: 'portalCaptured',
  ChallanVerificationStatus.manualUnverified: 'manualUnverified',
  ChallanVerificationStatus.officialApiVerified: 'officialApiVerified',
  ChallanVerificationStatus.invalid: 'invalid',
  ChallanVerificationStatus.expired: 'expired',
};

const _$ChallanVerificationMethodEnumMap = {
  ChallanVerificationMethod.webviewHumanVerification:
      'webviewHumanVerification',
  ChallanVerificationMethod.manualEntry: 'manualEntry',
  ChallanVerificationMethod.officialApi: 'officialApi',
};

_EPassChallanDraft _$EPassChallanDraftFromJson(Map<String, dynamic> json) =>
    _EPassChallanDraft(
      projectId: json['projectId'] as String,
      financialYear: json['financialYear'] as String,
      challanNumber: json['challanNumber'] as String,
      selectedMaterialType: $enumDecodeNullable(
        _$ChallanMaterialTypeEnumMap,
        json['selectedMaterialType'],
      ),
      payload: CapturedPortalPayload.fromJson(
        json['payload'] as Map<String, dynamic>,
      ),
      verificationStatus:
          $enumDecodeNullable(
            _$ChallanVerificationStatusEnumMap,
            json['verificationStatus'],
          ) ??
          ChallanVerificationStatus.portalCaptured,
      verificationMethod:
          $enumDecodeNullable(
            _$ChallanVerificationMethodEnumMap,
            json['verificationMethod'],
          ) ??
          ChallanVerificationMethod.webviewHumanVerification,
      portalUrl: json['portalUrl'] as String?,
      sourcePortal: json['sourcePortal'] as String? ?? 'bihar_khanan_soft',
    );

Map<String, dynamic> _$EPassChallanDraftToJson(_EPassChallanDraft instance) =>
    <String, dynamic>{
      'projectId': instance.projectId,
      'financialYear': instance.financialYear,
      'challanNumber': instance.challanNumber,
      'selectedMaterialType':
          _$ChallanMaterialTypeEnumMap[instance.selectedMaterialType],
      'payload': instance.payload,
      'verificationStatus':
          _$ChallanVerificationStatusEnumMap[instance.verificationStatus]!,
      'verificationMethod':
          _$ChallanVerificationMethodEnumMap[instance.verificationMethod]!,
      'portalUrl': instance.portalUrl,
      'sourcePortal': instance.sourcePortal,
    };

const _$ChallanMaterialTypeEnumMap = {
  ChallanMaterialType.sand: 'sand',
  ChallanMaterialType.stone: 'stone',
  ChallanMaterialType.brick: 'brick',
  ChallanMaterialType.aggregate: 'aggregate',
  ChallanMaterialType.boulder: 'boulder',
  ChallanMaterialType.dust: 'dust',
  ChallanMaterialType.gitti: 'gitti',
  ChallanMaterialType.balu: 'balu',
  ChallanMaterialType.other: 'other',
};

_EPassChallan _$EPassChallanFromJson(Map<String, dynamic> json) =>
    _EPassChallan(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      projectId: json['projectId'] as String,
      sourcePortal: json['sourcePortal'] as String? ?? 'bihar_khanan_soft',
      portalUrl: json['portalUrl'] as String?,
      financialYear: json['financialYear'] as String,
      challanNumber: json['challanNumber'] as String,
      normalizedChallanNumber: json['normalizedChallanNumber'] as String,
      uidNumber: json['uidNumber'] as String?,
      challanDate: json['challanDate'] == null
          ? null
          : DateTime.parse(json['challanDate'] as String),
      validUntil: json['validUntil'] == null
          ? null
          : DateTime.parse(json['validUntil'] as String),
      selectedMaterialType: $enumDecodeNullable(
        _$ChallanMaterialTypeEnumMap,
        json['selectedMaterialType'],
      ),
      portalMineralName: json['portalMineralName'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      quantityUnit: json['quantityUnit'] as String? ?? 'MT',
      vehicleType: json['vehicleType'] as String?,
      vehicleNumber: json['vehicleNumber'] as String,
      normalizedVehicleNumber: json['normalizedVehicleNumber'] as String,
      consignorName: json['consignorName'] as String?,
      consigneeName: json['consigneeName'] as String?,
      sourceLocation: json['sourceLocation'] as String?,
      destination: json['destination'] as String?,
      generatedFrom: json['generatedFrom'] as String?,
      royaltyAmountPaise: (json['royaltyAmountPaise'] as num?)?.toInt(),
      portalPayload:
          json['portalPayload'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      portalResponseHash: json['portalResponseHash'] as String?,
      verificationStatus:
          $enumDecodeNullable(
            _$ChallanVerificationStatusEnumMap,
            json['verificationStatus'],
          ) ??
          ChallanVerificationStatus.manualUnverified,
      verificationMethod:
          $enumDecodeNullable(
            _$ChallanVerificationMethodEnumMap,
            json['verificationMethod'],
          ) ??
          ChallanVerificationMethod.manualEntry,
      capturedAt: json['capturedAt'] == null
          ? null
          : DateTime.parse(json['capturedAt'] as String),
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      projectName: json['projectName'] as String?,
    );

Map<String, dynamic> _$EPassChallanToJson(_EPassChallan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'projectId': instance.projectId,
      'sourcePortal': instance.sourcePortal,
      'portalUrl': instance.portalUrl,
      'financialYear': instance.financialYear,
      'challanNumber': instance.challanNumber,
      'normalizedChallanNumber': instance.normalizedChallanNumber,
      'uidNumber': instance.uidNumber,
      'challanDate': instance.challanDate?.toIso8601String(),
      'validUntil': instance.validUntil?.toIso8601String(),
      'selectedMaterialType':
          _$ChallanMaterialTypeEnumMap[instance.selectedMaterialType],
      'portalMineralName': instance.portalMineralName,
      'quantity': instance.quantity,
      'quantityUnit': instance.quantityUnit,
      'vehicleType': instance.vehicleType,
      'vehicleNumber': instance.vehicleNumber,
      'normalizedVehicleNumber': instance.normalizedVehicleNumber,
      'consignorName': instance.consignorName,
      'consigneeName': instance.consigneeName,
      'sourceLocation': instance.sourceLocation,
      'destination': instance.destination,
      'generatedFrom': instance.generatedFrom,
      'royaltyAmountPaise': instance.royaltyAmountPaise,
      'portalPayload': instance.portalPayload,
      'portalResponseHash': instance.portalResponseHash,
      'verificationStatus':
          _$ChallanVerificationStatusEnumMap[instance.verificationStatus]!,
      'verificationMethod':
          _$ChallanVerificationMethodEnumMap[instance.verificationMethod]!,
      'capturedAt': instance.capturedAt?.toIso8601String(),
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'projectName': instance.projectName,
    };

_ChallanFilter _$ChallanFilterFromJson(Map<String, dynamic> json) =>
    _ChallanFilter(
      query: json['query'] as String? ?? '',
      projectId: json['projectId'] as String?,
      portal: $enumDecodeNullable(_$ChallanPortalEnumMap, json['portal']),
      materialType: $enumDecodeNullable(
        _$ChallanMaterialTypeEnumMap,
        json['materialType'],
      ),
      status: $enumDecodeNullable(
        _$ChallanVerificationStatusEnumMap,
        json['status'],
      ),
      fromDate: json['fromDate'] == null
          ? null
          : DateTime.parse(json['fromDate'] as String),
      toDate: json['toDate'] == null
          ? null
          : DateTime.parse(json['toDate'] as String),
    );

Map<String, dynamic> _$ChallanFilterToJson(_ChallanFilter instance) =>
    <String, dynamic>{
      'query': instance.query,
      'projectId': instance.projectId,
      'portal': _$ChallanPortalEnumMap[instance.portal],
      'materialType': _$ChallanMaterialTypeEnumMap[instance.materialType],
      'status': _$ChallanVerificationStatusEnumMap[instance.status],
      'fromDate': instance.fromDate?.toIso8601String(),
      'toDate': instance.toDate?.toIso8601String(),
    };

const _$ChallanPortalEnumMap = {
  ChallanPortal.bihar: 'bihar',
  ChallanPortal.jharkhand: 'jharkhand',
  ChallanPortal.madhyaPradesh: 'madhyaPradesh',
};
