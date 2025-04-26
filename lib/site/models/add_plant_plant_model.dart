import 'package:treemate/site/models/add_plant_site_model.dart';

class AddPlantPlantModel {
  String id;
  UserModel user;
  Plant plant;
  Site? site;
  String? plantName;
  String? plantImage;
  DateTime createdAt;
  DateTime? updatedAt;

  AddPlantPlantModel({
    required this.id,
    required this.user,
    required this.plant,
    this.site,
    this.plantName,
    this.plantImage,
    required this.createdAt,
    this.updatedAt,
  });

  factory AddPlantPlantModel.fromJson(Map<String, dynamic> json) {
    return AddPlantPlantModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      plant: Plant.fromJson(json['plant']),
      site: json['site'] != null ? Site.fromJson(json['site']) : null,
      plantName: json['plantName'],
      plantImage: json['plantImage'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
class Plant {
  String id;
  String plantType;
  String siteTypes;
  String toxicity;
  String maintenanceLevel;
  String waterNeeded;
  String description;
  String commonName;
  String scientificName;
  String plantImage;
  String commonPests;
  String suitableTemperature;
  String commonProblemsOrDiseases;
  String lightingNeeded;
  String humidity;
  String soilType;
  String soilPh;
  String difficultyLevel;
  String matureSize;
  String bloomTime;
  String color;
  String geographicOrigin;
  String uses;
  String? additionalNameUno;
  String? additionalNameDos;
  int waterRequirements;
  int mistingRequirements;
  int fertilizerRequirements;
  String waterOverview;
  String waterDescription;
  String mistingOverview;
  String mistingDescription;
  String suitableLighting;
  String suitableTemperatureDetail;
  String fertilizerOverview;
  String whenToFertilize;
  String fertilizerDescription;
  String potOverview;
  String suitablePotType;
  String potDrainage;
  String suitableSoil;
  String propagation;
  String commonPestsAndProblems;
  String specialCare;
  String? additionalInfoUno;
  String? additionalInfoDos;
  String? additionalInfoTres;
  Category category;
  DateTime createdAt;
  DateTime? updatedAt;

  Plant({
    required this.id,
    required this.plantType,
    required this.siteTypes,
    required this.toxicity,
    required this.maintenanceLevel,
    required this.waterNeeded,
    required this.description,
    required this.commonName,
    required this.scientificName,
    required this.plantImage,
    required this.commonPests,
    required this.suitableTemperature,
    required this.commonProblemsOrDiseases,
    required this.lightingNeeded,
    required this.humidity,
    required this.soilType,
    required this.soilPh,
    required this.difficultyLevel,
    required this.matureSize,
    required this.bloomTime,
    required this.color,
    required this.geographicOrigin,
    required this.uses,
    this.additionalNameUno,
    this.additionalNameDos,
    required this.waterRequirements,
    required this.mistingRequirements,
    required this.fertilizerRequirements,
    required this.waterOverview,
    required this.waterDescription,
    required this.mistingOverview,
    required this.mistingDescription,
    required this.suitableLighting,
    required this.suitableTemperatureDetail,
    required this.fertilizerOverview,
    required this.whenToFertilize,
    required this.fertilizerDescription,
    required this.potOverview,
    required this.suitablePotType,
    required this.potDrainage,
    required this.suitableSoil,
    required this.propagation,
    required this.commonPestsAndProblems,
    required this.specialCare,
    this.additionalInfoUno,
    this.additionalInfoDos,
    this.additionalInfoTres,
    required this.category,
    required this.createdAt,
    this.updatedAt,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      plantType: json['plantType'],
      siteTypes: json['siteTypes'],
      toxicity: json['toxicity'],
      maintenanceLevel: json['maintenanceLevel'],
      waterNeeded: json['waterNeeded'],
      description: json['description'],
      commonName: json['commonName'],
      scientificName: json['scientificName'],
      plantImage: json['plantImage'],
      commonPests: json['commonPests'],
      suitableTemperature: json['suitableTemperature'],
      commonProblemsOrDiseases: json['commonProblemsOrDiseases'],
      lightingNeeded: json['lightingNeeded'],
      humidity: json['humidity'],
      soilType: json['soilType'],
      soilPh: json['soilPh'],
      difficultyLevel: json['difficultyLevel'],
      matureSize: json['matureSize'],
      bloomTime: json['bloomTime'],
      color: json['color'],
      geographicOrigin: json['geographicOrigin'],
      uses: json['uses'],
      additionalNameUno: json['additionalNameUno'],
      additionalNameDos: json['additionalNameDos'],
      waterRequirements: json['waterRequirements'],
      mistingRequirements: json['mistingRequirements'],
      fertilizerRequirements: json['fertilizerRequirements'],
      waterOverview: json['waterOverview'],
      waterDescription: json['waterDescription'],
      mistingOverview: json['mistingOverview'],
      mistingDescription: json['mistingDescription'],
      suitableLighting: json['suitableLighting'],
      suitableTemperatureDetail: json['suitableTemperatureDetail'],
      fertilizerOverview: json['fertilizerOverview'],
      whenToFertilize: json['whenToFertilize'],
      fertilizerDescription: json['fertilizerDescription'],
      potOverview: json['potOverview'],
      suitablePotType: json['suitablePotType'],
      potDrainage: json['potDrainage'],
      suitableSoil: json['suitableSoil'],
      propagation: json['propagation'],
      commonPestsAndProblems: json['commonPestsAndProblems'],
      specialCare: json['specialCare'],
      additionalInfoUno: json['additionalInfoUno'],
      additionalInfoDos: json['additionalInfoDos'],
      additionalInfoTres: json['additionalInfoTres'],
      category: Category.fromJson(json['category']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class Site {
  String id;
  UserModel user;
  String siteName;
  String siteType;
  String? siteImage;
  bool isDefaultSite;
  DateTime createdAt;
  DateTime? updatedAt;

  Site({
    required this.id,
    required this.user,
    required this.siteName,
    required this.siteType,
    this.siteImage,
    required this.isDefaultSite,
    required this.createdAt,
    this.updatedAt,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      siteName: json['siteName'],
      siteType: json['siteType'],
      siteImage: json['siteImage'],
      isDefaultSite: json['isDefaultSite'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
class Category {
  String id;
  String name;
  String image;
  DateTime createdAt;
  DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}