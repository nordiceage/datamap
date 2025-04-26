// import 'dart:math';
//
// class WeatherImages {
//   static const Map<String, List<String>> images = {
//     'Clear': [
//       'https://drive.google.com/uc?id=1kSmBX2ftuSMXdOJn2uHhQXb7kgvSX09d',
//       'https://drive.google.com/uc?id=1jBvCGjEH9R22u5RNCo4pwlzb4tBcLTo5',
//     ],
//     'Clouds': [
//       'https://drive.google.com/uc?id=1XK_IYsZv0In1Y04NYNO9tSlR8AyhGqIq',
//       'https://drive.google.com/uc?id=1cUAqz1e4Mjmwr58mPPx0N21xtVaXe',
//       'https://drive.google.com/uc?id=1Rn6NFGCjY3n5HkaP34OhGiJUdz3e4wrh',
//       'https://drive.google.com/uc?id=170VT0Qs4DTm-LtTydhuII9nWXhxaRx8F',
//     ],
//     'Rain': [
//       'https://drive.google.com/uc?id=1I3oIoOwqRg8EFZaOTxCjtlFVGZARIHmN',
//       'https://drive.google.com/uc?id=1HeWQ5pE1YbZpjEeE_KbK81pctborNwpf',
//       'https://drive.google.com/uc?id=1v3oD0goCRemZByW-R5nc0ZaoteD9wC2O',
//     ],
//     'Thunderstorm': [
//       'https://drive.google.com/uc?id=1KrlVzjXq9BXJNyIvYYuTopJHSdGX',
//       'https://drive.google.com/uc?id=1GZfvNWJ9tUQpHZbWIGkedDBUvRAaLCCW',
//       'https://drive.google.com/uc?id=1_dUHSoGnwNuC0J-JtCx7iglFbaKdUl53',
//       'https://drive.google.com/uc?id=1lQhVPegE31Qvz3GJfy1ym_Adm5bOkbbw',
//     ],
//   };
//
//   static String getRandomImage(String condition) {
//     final List<String>? conditionImages = images[condition];
//     if (conditionImages != null && conditionImages.isNotEmpty) {
//       final Random random = Random();
//       return conditionImages[random.nextInt(conditionImages.length)];
//     } else {
//       // Default to Clear if no images are found for the condition
//       return images['Clear']![0];
//     }
//   }
// }
