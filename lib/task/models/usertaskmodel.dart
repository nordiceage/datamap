
class Plant {
  final String id;
  final String plantType;
  final String? commonName;
  final String? scientificName;
  final String? imageUrl;

  Plant({
    required this.id,
    required this.plantType,
    this.commonName,
    this.scientificName,
    this.imageUrl,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] ?? '',
      plantType: json['plantType'] ?? '',
      commonName: json['commonName'],
      scientificName: json['scientificName'],
      imageUrl: json['plantImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantType': plantType,
      'commonName': commonName,
      'scientificName': scientificName,
      'plantImage': imageUrl,
    };
  }
}

class Site {
  final String id;
  final String siteType;
  final String siteName;

  Site({
    required this.id,
    required this.siteType,
    required this.siteName,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'] ?? '',
      siteType: json['siteType'] ?? '',
      siteName: json['siteName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteType': siteType,
      'siteName': siteName,
    };
  }
}

class UserPlant {
  final Plant plant;
  final Site? site;

  UserPlant({
    required this.plant,
    this.site,
  });

  factory UserPlant.fromJson(Map<String, dynamic> json) {
    return UserPlant(
      plant: Plant.fromJson(json['plant']),
      site: json['site'] != null ? Site.fromJson(json['site']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plant': plant.toJson(),
      'site': site?.toJson(),
    };
  }
}

class UserTaskModel {
  final String id;
  final String taskType;
  final String? scheduledAt;
  final String? description;
  final String userId;
  final String username;
  final UserPlant? userPlant;
  final bool isComplete; // added for complete task

  UserTaskModel({
    required this.id,
    required this.taskType,
    this.scheduledAt,
    this.description,
    required this.userId,
    required this.username,
    this.userPlant,
    required this.isComplete, // added for complete task
  });

  factory UserTaskModel.fromJson(Map<String, dynamic> json) {
    return UserTaskModel(
      id: json['id'] ?? '',
      taskType: json['taskType'] ?? '',
      scheduledAt: json['scheduledAt'],
      description: json['description'] ?? '',
      userId: json['user']['id'] ?? '',
      username: json['user']['username'] ?? 'Unknown',
      userPlant: json['userPlant'] != null
          ? UserPlant.fromJson(json['userPlant'])
          : null,
          isComplete: json['isComplete'] != null, // added for complete task
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskType': taskType,
      'scheduledAt': scheduledAt,
      'description': description,
      'userId': userId,
      'username': username,
      'userPlant': userPlant?.toJson(),
      'isComplete': isComplete, // added for complete task
    };
  }
}
