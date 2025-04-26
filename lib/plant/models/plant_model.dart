import 'package:flutter/cupertino.dart';

class PlantModel {
  final String id;
  final String plantId;
  final String commonName;
  final String scientificName;
  final String categoryId;
  final String categoryName;
  final String? family;
  final String? genus;
  final String? description;
  final String? habitat;
  final String? climate;
  final String? soilType;
  final String? waterRequirement;
  final String? sunlightRequirement;
  final String? mistingRequirement;
  final String? fertilizerRequirement;
  final String? growthRate;
  final String? bloomTime;
  final String? toxicity;
  final String? medicinalUses;
  final String? edibleParts;
  final String? propagationMethod;
  final String? conservationStatus;
  final String? geographicOrigin;
  final String? imageUrl;
  final String? plantType;
  final String? waterDescription;
  final String? mistingDescription;
  final String? fertilizerDescription;
  final String? difficultyLevel;
  final String? lightingNeeded;
  final String? matureSize;
  final String? commonPests;
  final String? suitableTemperature;
  final String? commonProblemsOrDiseases;
  final String? humidity;
  final String? soilPh;
  final String? color;
  final String? uses;
  final String? waterOverview;
  final String? mistingOverview;
  final String? suitableTemperatureDetail;
  final String? fertilizerOverview;
  final String? whenToFertilize;
  final String? potOverview;
  final String? suitablePotType;
  final String? potDrainage;
  final String? suitableSoil;
  final String? commonPestsAndProblems;
  final String? specialCare;
  final String? additionalNameUno;
  final String? additionalNameDos;
  final String? additionalInfoUno;
  final String? additionalInfoDos;
  final String? additionalInfoTres;
  final int? waterRequirements;
  final int? mistingRequirements;
  final int? fertilizerRequirements;
  final String? plantName;
  final String? siteName;
  final String? siteType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? siteId;

  PlantModel({
    required this.id,
    required this.plantId,
    required this.commonName,
    required this.scientificName,
    required this.categoryId,
    required this.categoryName,
    this.family,
    this.genus,
    this.description,
    this.habitat,
    this.climate,
    this.soilType,
    this.commonPests,
    this.suitableTemperature,
    this.commonProblemsOrDiseases,
    this.humidity,
    this.waterRequirement,
    this.sunlightRequirement,
    this.mistingRequirement,
    this.fertilizerRequirement,
    this.growthRate,
    this.bloomTime,
    this.toxicity,
    this.medicinalUses,
    this.edibleParts,
    this.propagationMethod,
    this.conservationStatus,
    this.geographicOrigin,
    this.imageUrl,
    this.plantType,
    this.waterDescription,
    this.mistingDescription,
    this.fertilizerDescription,
    this.difficultyLevel,
    this.lightingNeeded,
    this.matureSize,
    this.soilPh,
    this.color,
    this.uses,
    this.waterOverview,
    this.mistingOverview,
    this.suitableTemperatureDetail,
    this.fertilizerOverview,
    this.whenToFertilize,
    this.potOverview,
    this.suitablePotType,
    this.potDrainage,
    this.suitableSoil,
    this.commonPestsAndProblems,
    this.specialCare,
    this.additionalNameUno,
    this.additionalNameDos,
    this.additionalInfoUno,
    this.additionalInfoDos,
    this.additionalInfoTres,
    this.waterRequirements,
    this.mistingRequirements,
    this.fertilizerRequirements,
    this.plantName,
    this.siteName,
    this.siteType,
    this.createdAt,
    this.updatedAt,
    this.siteId,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    final plantData = json['plant'] ?? json;

    return PlantModel(
      id: json['id'] ?? '',
      plantId: plantData['id'] ?? '',
      commonName: plantData['commonName'] ?? 'Unknown',
      scientificName: plantData['scientificName'] ?? 'N/A',
      categoryId: plantData['category']?['id'] ?? '',
      categoryName: plantData['category']?['name'] ?? 'Uncategorized',
      family: plantData['family']?.toString(),
      genus: plantData['genus']?.toString(),
      description: plantData['description']?.toString(),
      commonPests: plantData['commonPests'] ?? 'Unknown',
      suitableTemperature: plantData['suitableTemperature'] ?? 'Unknown',
      commonProblemsOrDiseases:
          plantData['commonProblemsOrDiseases'] ?? 'Unknown',
      humidity: plantData['humidity'] ?? 'Unknown',
      habitat: plantData['habitat']?.toString(),
      climate: plantData['climate']?.toString(),
      soilType: plantData['soilType']?.toString(),
      waterRequirement: plantData['waterNeeded']?.toString(),
      sunlightRequirement: plantData['lightingNeeded']?.toString(),
      mistingRequirement: plantData['mistingRequirements']?.toString(),
      fertilizerRequirement: plantData['fertilizerRequirements']?.toString(),
      growthRate: plantData['growthRate']?.toString(),
      bloomTime: plantData['bloomTime']?.toString(),
      toxicity: plantData['toxicity']?.toString(),
      medicinalUses: plantData['uses']?.toString(),
      edibleParts: plantData['edibleParts']?.toString(),
      propagationMethod: plantData['propagation']?.toString(),
      conservationStatus: plantData['conservationStatus']?.toString(),
      geographicOrigin: plantData['geographicOrigin']?.toString(),
      imageUrl: plantData['plantImage']?.toString() ?? '',
      plantType: plantData['plantType']?.toString(),
      waterDescription: plantData['waterDescription']?.toString(),
      mistingDescription: plantData['mistingDescription']?.toString(),
      fertilizerDescription: plantData['fertilizerDescription']?.toString(),
      difficultyLevel: plantData['difficultyLevel']?.toString(),
      lightingNeeded: plantData['suitableLighting']?.toString(),
      matureSize: plantData['matureSize']?.toString(),
      soilPh: plantData['soilPh']?.toString(),
      color: plantData['color']?.toString(),
      uses: plantData['uses']?.toString(),
      waterOverview: plantData['waterOverview']?.toString(),
      mistingOverview: plantData['mistingOverview']?.toString(),
      suitableTemperatureDetail:
          plantData['suitableTemperatureDetail']?.toString(),
      fertilizerOverview: plantData['fertilizerOverview']?.toString(),
      whenToFertilize: plantData['whenToFertilize']?.toString(),
      potOverview: plantData['potOverview']?.toString(),
      suitablePotType: plantData['suitablePotType']?.toString(),
      potDrainage: plantData['potDrainage']?.toString(),
      suitableSoil: plantData['suitableSoil']?.toString(),
      commonPestsAndProblems: plantData['commonPestsAndProblems']?.toString(),
      specialCare: plantData['specialCare']?.toString(),
      additionalNameUno: plantData['additionalNameUno']?.toString(),
      additionalNameDos: plantData['additionalNameDos']?.toString(),
      additionalInfoUno: plantData['additionalInfoUno']?.toString(),
      additionalInfoDos: plantData['additionalInfoDos']?.toString(),
      additionalInfoTres: plantData['additionalInfoTres']?.toString(),
      waterRequirements: plantData['waterRequirements'],
      mistingRequirements: plantData['mistingRequirements'],
      fertilizerRequirements: plantData['fertilizerRequirements'],
      plantName: json['plantName']?.toString(),
      siteName: json['site']?['siteName']?.toString(),
      siteType: json['site']?['siteType']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
      siteId: json['site']?['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'commonName': commonName,
      'scientificName': scientificName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'commonPests': commonPests,
      'suitableTemperature': suitableTemperature,
      'commonProblemsOrDiseases': commonProblemsOrDiseases,
      'humidity': humidity,
      'family': family,
      'genus': genus,
      'description': description,
      'habitat': habitat,
      'climate': climate,
      'soilType': soilType,
      'waterRequirement': waterRequirement,
      'sunlightRequirement': sunlightRequirement,
      'mistingRequirement': mistingRequirement,
      'fertilizerRequirement': fertilizerRequirement,
      'growthRate': growthRate,
      'bloomTime': bloomTime,
      'toxicity': toxicity,
      'medicinalUses': medicinalUses,
      'edibleParts': edibleParts,
      'propagationMethod': propagationMethod,
      'conservationStatus': conservationStatus,
      'geographicOrigin': geographicOrigin,
      'imageUrl': imageUrl,
      'plantType': plantType,
      'waterDescription': waterDescription,
      'mistingDescription': mistingDescription,
      'fertilizerDescription': fertilizerDescription,
      'difficultyLevel': difficultyLevel,
      'lightingNeeded': lightingNeeded,
      'matureSize': matureSize,
      'soilPh': soilPh,
      'color': color,
      'uses': uses,
      'waterOverview': waterOverview,
      'mistingOverview': mistingOverview,
      'suitableTemperatureDetail': suitableTemperatureDetail,
      'fertilizerOverview': fertilizerOverview,
      'whenToFertilize': whenToFertilize,
      'potOverview': potOverview,
      'suitablePotType': suitablePotType,
      'potDrainage': potDrainage,
      'suitableSoil': suitableSoil,
      'commonPestsAndProblems': commonPestsAndProblems,
      'specialCare': specialCare,
      'additionalNameUno': additionalNameUno,
      'additionalNameDos': additionalNameDos,
      'additionalInfoUno': additionalInfoUno,
      'additionalInfoDos': additionalInfoDos,
      'additionalInfoTres': additionalInfoTres,
      'waterRequirements': waterRequirements,
      'mistingRequirements': mistingRequirements,
      'fertilizerRequirements': fertilizerRequirements,
      'plantName': plantName,
      'siteName': siteName,
      'siteType': siteType,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'siteId': siteId,
    };
  }
}

class ActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackgroundColor;
  final bool isEnabled;

  ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackgroundColor,
    this.isEnabled = false,
  });
}

class TaskItem {
  final String title;
  final String dueIn;
  final IconData icon;
  final Color iconColor;

  TaskItem({
    required this.title,
    required this.dueIn,
    required this.icon,
    required this.iconColor,
  });
}
