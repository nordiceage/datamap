// import 'package:flutter/material.dart';
// import '../models/plant_model.dart';

// class PlantDetailPage extends StatelessWidget {
//   final PlantModel plant;

//   PlantDetailPage({required this.plant});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(plant.commonName),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Image.network(plant.imageUrl),
//               SizedBox(height: 10),
//               Text(
//                 'Common Name: ${plant.commonName}',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               Text('Scientific Name: ${plant.scientificName}'),
//               Text('Family: ${plant.family}'),
//               Text('Genus: ${plant.genus}'),
//               Text('Description: ${plant.description}'),
//               // Add other fields similarly...
//               SizedBox(height: 20),
//               Text('Habitat: ${plant.habitat}'),
//               Text('Climate: ${plant.climate}'),
//               Text('Soil Type: ${plant.soilType}'),
//               // Continue for other properties...
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
