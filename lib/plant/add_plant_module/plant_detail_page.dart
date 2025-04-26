// import 'package:flutter/material.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:treemate/models/plant_model.dart';
// // import 'package:treemate/add_plant_module/plant_care_section.dart';
//
// import 'automated_watering_page.dart';
//
//
//
// enum PlantCareSection {
//   waterAndMisting,
//   siteLightAndTemperature,
//   fertilizer,
//   potAndSoil,
// }
//
// enum PlantLanguage {
//   english('English', 'Snake Plant'),
//   hindi('Hindi', 'नागदमन'),
//   assamese('Assamese', 'পৰ্ৰোলী');
//
//   final String label;
//   final String plantName;
//   const PlantLanguage(this.label, this.plantName);
// }
// class FAQItem {
//   final String question;
//   final String answer;
//   bool isExpanded;
//
//   FAQItem({
//     required this.question,
//     required this.answer,
//     this.isExpanded = false,
//   });
// }
//
// class PlantDetailPage extends StatefulWidget {
//   final PlantModel plant; // Add this line to accept the plant object
//   // const PlantDetailPage({Key? key}) : super(key: key);
//   const PlantDetailPage({Key? key, required this.plant}) : super(key: key); // Update the constructor
//
//   @override
//   State<PlantDetailPage> createState() => _PlantDetailPageState();
// }
//
// class _PlantDetailPageState extends State<PlantDetailPage> {
//   final ScrollController _scrollController = ScrollController();
//   final PageController _pageController = PageController();
//   PlantLanguage _selectedLanguage = PlantLanguage.english;
//
//   // Section positions
//   final GlobalKey _overviewKey = GlobalKey();
//   final GlobalKey _plantCareKey = GlobalKey();
//   final GlobalKey _characteristicsKey = GlobalKey();
//   final GlobalKey _faqKey = GlobalKey();
//
//   int _selectedTabIndex = 0;
//   bool _isTabBarVisible = true;
//   double _previousScrollOffset = 0;
//
//   final Map<PlantCareSection, bool> _expandedSections = {
//     PlantCareSection.waterAndMisting: false,
//     PlantCareSection.siteLightAndTemperature: false,
//     PlantCareSection.fertilizer: false,
//     PlantCareSection.potAndSoil: false,
//   };
//   bool _isCharacteristicsExpanded = false;
//
//   final List<FAQItem> _faqItems = [
//     FAQItem(
//       question: "Is this tree/plant easy to grow?",
//       answer: "Yes, the Snake Plant is one of the most easy-to-grow houseplants. It's highly tolerant of low light conditions and irregular watering, making it perfect for beginners.",
//     ),
//     FAQItem(
//       question: "How fast does this tree/plant name grow?",
//       answer: "Snake Plants are relatively slow growers. Under optimal conditions, they can grow 2-3 new leaves per growing season, with each leaf reaching about 1-2 inches per month.",
//     ),
//     FAQItem(
//       question: "Can I plant snake plant outside?",
//       answer: "Snake Plants can be grown outdoors in warm climates (USDA zones 9-11). However, they need to be protected from direct sunlight and cold temperatures below 50°F (10°C).",
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   void _onScroll() {
//     setState(() {
//       if (_scrollController.offset <= 0) {
//         _isTabBarVisible = true;
//       } else {
//         _isTabBarVisible = _scrollController.offset < _previousScrollOffset;
//       }
//       _previousScrollOffset = _scrollController.offset;
//     });
//     // Get app bar height
//     double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight + 40;
//
//     // Calculate positions with offset
//     final plantCarePosition = (_plantCareKey.currentContext?.findRenderObject() as RenderBox?)
//         ?.localToGlobal(Offset.zero).dy ?? 0;
//     final characteristicsPosition = (_characteristicsKey.currentContext?.findRenderObject() as RenderBox?)
//         ?.localToGlobal(Offset.zero).dy ?? 0;
//     final faqPosition = (_faqKey.currentContext?.findRenderObject() as RenderBox?)
//         ?.localToGlobal(Offset.zero).dy ?? 0;
//
//     // Update selected tab based on scroll position
//     if (_scrollController.offset >= (faqPosition - appBarHeight)) {
//       setState(() => _selectedTabIndex = 3);
//     } else if (_scrollController.offset >= (characteristicsPosition - appBarHeight)) {
//       setState(() => _selectedTabIndex = 2);
//     } else if (_scrollController.offset >= (plantCarePosition - appBarHeight)) {
//       setState(() => _selectedTabIndex = 1);
//     } else {
//       setState(() => _selectedTabIndex = 0);
//     }
//   }
//
//   void _scrollToSection(int index) {
//     double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight + 40;
//
//     double offset = 0;
//     switch (index) {
//       case 0:
//         offset = 0;
//         break;
//       case 1:
//         offset = (_plantCareKey.currentContext?.findRenderObject() as RenderBox)
//             .localToGlobal(Offset.zero).dy ??
//             0 - appBarHeight;
//         break;
//       case 2:
//         offset = (_characteristicsKey.currentContext?.findRenderObject() as RenderBox)
//             .localToGlobal(Offset.zero).dy  ??
//             0 - appBarHeight;
//         break;
//       case 3:
//         offset = (_faqKey.currentContext?.findRenderObject() as RenderBox)
//             .localToGlobal(Offset.zero).dy  ??
//             0 - appBarHeight;
//         break;
//     }
//     _scrollController.animateTo(
//       offset,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFEEF1EF),
//       body: Stack(
//         children: [
//           CustomScrollView(
//             controller: _scrollController,
//             slivers: [
//               SliverAppBar(
//                 pinned: true,
//                 floating: true,
//                 elevation: 0,
//                 backgroundColor: const Color(0xFFEEF1EF),
//                 expandedHeight: kToolbarHeight + 40, // Increased to accommodate tab bar
//                 flexibleSpace: FlexibleSpaceBar(
//                   expandedTitleScale: 1.0,
//                   title: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       _buildTabBar(),
//                     ],
//                   ),
//                 ),
//                 leading: IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 actions: [
//                   if (_isTabBarVisible)
//                   PopupMenuButton(
//                     icon: const Icon(Icons.more_horiz),
//                     itemBuilder: (context) => [
//                       PopupMenuItem(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const  [
//                             // Icon(Icons.share_outlined),
//                             // SizedBox(width: 8),
//                             Text('Share'),
//                           ],
//                         ),
//                       ),
//                       PopupMenuItem(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             // Icon(Icons.flag_outlined),
//                             // SizedBox(width: 8),
//                             Text('Report'),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               SliverToBoxAdapter(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       key: _overviewKey,
//                       child: _buildOverviewSection(),
//                     ),
//                     Container(
//                       key: _plantCareKey,
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: _buildPlantCareSection(),
//                     ),
//                     const SizedBox(height: 28),
//                     Container(
//                       key: _characteristicsKey,
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: _buildCharacteristicsSection(),
//                     ),
//                     const SizedBox(height: 28),
//                     Container(
//                       key: _faqKey,
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: _buildFAQSection(),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTabBar() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Container(
//         height: 36,
//         padding: const EdgeInsets.symmetric(horizontal: 19),
//         child: Row(
//           children: [
//             _buildTab("Overview", 0),
//             _buildTab("Plant Care", 1),
//             _buildTab("Characteristics", 2),
//             _buildTab("FAQ", 3),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTab(String text, int index) {
//     final isSelected = _selectedTabIndex == index;
//     return GestureDetector(
//       onTap: () {
//         setState(() => _selectedTabIndex = index);
//         _scrollToSection(index);
//       },
//       child: Container(
//         margin: const EdgeInsets.only(right: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFCDE1D2) : Colors.transparent,
//           border: isSelected
//               ? Border.all(color: const Color(0xFF2B9348))
//               : null,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           text,
//           style: const TextStyle(
//             fontFamily: 'Open Sans',
//             fontSize: 16,
//             color: Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _buildPlantImage() {
//     // List of image paths for each slide
//     final List<String> imagePaths = [
//       'assets/image/Snake.png',
//       'assets/image/Snake2.png',
//       'assets/image/Snake3.png',
//     ];
//
//     return Stack(
//       alignment: Alignment.bottomCenter,
//       children: [
//         SizedBox(
//           height: 260,
//           child: PageView(
//             controller: _pageController,
//             children: List.generate(
//               3,
//                   (index) => Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: const Color(0xFFD9D9D9),
//                     width: 0.5,
//                   ),
//                   image: DecorationImage(
//                     // Use different image for each index
//                     image: AssetImage(imagePaths[index]),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: SmoothPageIndicator(
//             controller: _pageController,
//             count: 3,
//             effect: const ExpandingDotsEffect(
//               dotColor: Colors.white60,
//               activeDotColor: Colors.white,
//               dotHeight: 6,
//               dotWidth: 6,
//               expansionFactor: 4,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//   Widget _buildPlantInfo() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           _selectedLanguage.plantName,  // Using selected language's plant name
//           style: const TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 28,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const Text(
//           "Sansevieria Trifasciata, Mother-in-Law's Tongue, Viper's Bowstring Hemp",
//           style: TextStyle(
//             fontFamily: 'Open Sans',
//             fontSize: 16,
//             color: Color(0xFF737373),
//           ),
//         ),
//         const SizedBox(height: 10),
//         _buildLanguageSelector(),
//       ],
//     );
//   }
//
//   Widget _buildLanguageSelector() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<PlantLanguage>(
//           value: _selectedLanguage,
//           isExpanded: true,
//           isDense: true,
//           // itemHeight: 40,
//           menuMaxHeight: 200,
//           padding: EdgeInsets.zero,
//           icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF737373),
//             size: 20,
//           ),
//           items: PlantLanguage.values.map((language) {
//             return DropdownMenuItem(
//               value: language,
//               child: Text(
//                 language.label,
//                 style: const TextStyle(
//                   fontFamily: 'Open Sans',
//                   fontSize: 16,
//                 ),
//               ),
//             );
//           }).toList(),
//           onChanged: (PlantLanguage? newValue) {
//             if (newValue != null) {
//               setState(() {
//                 _selectedLanguage = newValue;
//               });
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOverviewSection() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildPlantImage(),
//           const SizedBox(height: 10),
//           _buildPlantInfo(),
//           const SizedBox(height: 10),
//           _buildQuickStats(),
//           const SizedBox(height: 10),
//           _buildDescription(),
//           const SizedBox(height: 10),
//           // _buildReportSection(),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildDescription() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Plant description',
//             style: TextStyle(
//               fontFamily: 'Open Sans',
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF737373),
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'Lorem ipsum dolor sit amet consectetur. Ut nam lobortis donec urna. Vitae praesent amet eget nunc dapibus et dis. Cursus aliquam convallis id eu magna aliquet adipiscing.',
//             style: TextStyle(
//               fontFamily: 'Open Sans',
//               fontSize: 16,
//               height: 1.5,
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuickStats() {
//     return Column(
//       children: [
//         Container(
//           // margin: const EdgeInsets.symmetric(vertical: 10),
//           margin: const EdgeInsets.only(top: 10, bottom: 0),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   height: 52,  // Fixed height for the button
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.add, color: Colors.white),
//                     label: const Text(
//                       'Add Plant',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontFamily: 'Open Sans',
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF2B9348),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(26),
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 24),
//                     ),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AutomatedWateringPage(
//                             //plantName: 'xxxx'
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Container(
//                 width: 52,
//                 height: 52,
//                 padding: const EdgeInsets.all(12),
//                 child: IconButton(
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                   icon: const Icon(
//                     Icons.favorite_outline,
//                     size: 28,
//                     color: Colors.black,
//                   ),
//                   onPressed: () {
//                   //   todo:
//                   },
//                 ),
//               )
//             ],
//           ),
//         ),
//         Container(
//           // margin: const EdgeInsets.only(bottom: 10),
//           margin: EdgeInsets.zero,
//           child: GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 2,
//             mainAxisSpacing: 12,
//             crossAxisSpacing: 12,
//             childAspectRatio: 2.5,
//             children: [
//               _buildInfoChip(Icons.water_drop_outlined, 'Minimum'),
//               _buildInfoChip(Icons.trending_up, 'Easy'),
//               _buildInfoChip(Icons.location_on_outlined, 'Indoor'),
//               _buildInfoChip(Icons.warning_outlined, 'Non Toxic'),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//
//
//   Widget _buildInfoChip(IconData icon, String label) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Container(
//             margin: const EdgeInsets.all(8),
//             width: 36,
//             height: 36,
//             decoration: const BoxDecoration(
//               color: Color(0xFFAFAFAF),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: Colors.white, size: 20),
//           ),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: const TextStyle(
//               fontFamily: 'Open Sans',
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildPlantCareSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Plant Care',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 24,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 14),
//         _buildExpandableCareCard(
//           'Water & Misting',
//           PlantCareSection.waterAndMisting,
//           [
//             _buildCareItem(
//               icon: Icons.water_drop,
//               backgroundColor: const Color(0xFF53CBFF),
//               title: 'Water every 10 days',
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 0),
//               child: Divider(color: Color(0xFFD9D9D9)),
//             ),
//             _buildCareItem(
//               icon: Icons.opacity,
//               backgroundColor: const Color(0xFF34CDC4),
//               title: 'Misting every 3 days',
//             ),
//           ],
//         ),
//         const SizedBox(height: 14),
//         _buildExpandableCareCard(
//           'Site, light & temperature',
//           PlantCareSection.siteLightAndTemperature,
//           [
//             _buildCareItem(
//               icon: Icons.home_outlined,
//               backgroundColor: const Color(0xFF42A4C2),
//               title: 'Indoor, Outdoor',
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 0),
//               child: Divider(color: Color(0xFFD9D9D9)),
//             ),
//             _buildCareItem(
//               icon: Icons.wb_sunny_outlined,
//               backgroundColor: const Color(0xFFFFBA53),
//               title: 'Part shade, part sun',
//             ),
//           ],
//         ),
//         const SizedBox(height: 14),
//         _buildExpandableCareCard(
//           'Fertilizer',
//           PlantCareSection.fertilizer,
//           [
//             _buildCareItem(
//               icon: Icons.local_florist,
//               backgroundColor: const Color(0xFFFA4CFE),
//               title: 'Fertilize every 30 days',
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 0),
//               child: Divider(color: Color(0xFFD9D9D9)),
//             ),
//             _buildCareItem(
//               icon: Icons.science,
//               backgroundColor: const Color(0xFF797979),
//               title: 'Liquid, Solid',
//             ),
//           ],
//         ),
//         const SizedBox(height: 14),
//         _buildExpandableCareCard(
//           'Pot and Soil',
//           PlantCareSection.potAndSoil,
//           [
//             _buildCareItem(
//               icon: Icons.update,
//               backgroundColor: const Color(0xFFAFAFAF),
//               title: 'Repot every 3 months',
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 0),
//               child: Divider(color: Color(0xFFD9D9D9)),
//             ),
//             _buildCareItem(
//               icon: Icons.landscape,
//               backgroundColor: const Color(0xFFAFAFAF),
//               title: 'Part muddy',
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildExpandableCareCard(String title, PlantCareSection section,
//       List<Widget> items) {
//     final isExpanded = _expandedSections[section] ?? false;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05), // ADDED: new shadow
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start, // CHANGED: added crossAxisAlignment
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Color(0xFF737373),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'Open Sans',
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ...items,
//               ],
//             ),
//           ),
//           if (isExpanded) ...[
//             // const Divider(height: 1, color: Color(0xFFEEEEEE)), // CHANGED: color from 0xFFD9D9D9
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 14),
//               child: Divider(color: Color(0xFFD9D9D9)),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Care Instructions',
//                     style: TextStyle(
//                       fontFamily: 'Open Sans',
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     'Lorem ipsum dolor sit amet consectetur. Ut nam lobortis donec urna. '
//                         'Vitae praesent amet eget nunc dapibus et dis. Cursus aliquam convallis '
//                         'id eu magna aliquet adipiscing.',
//                     style: const TextStyle(
//                       fontFamily: 'Open Sans',
//                       fontSize: 14,
//                       height: 1.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//           InkWell(
//             onTap: () {
//               setState(() {
//                 _expandedSections[section] = !isExpanded;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFDFDFD),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Center(
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       isExpanded ? 'Show less' : 'Learn more',
//                       style: const TextStyle(
//                         color: Color(0xFF727272),
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'Open Sans',
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     Icon(
//                       isExpanded ? Icons.keyboard_arrow_up : Icons
//                           .keyboard_arrow_down,
//                       color: const Color(0xFF727272),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCareItem({
//     required IconData icon,
//     required Color backgroundColor,
//     required String title,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         children: [
//           Container(
//             width: 46,
//             height: 46,
//             decoration: BoxDecoration(
//               color: backgroundColor,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: Colors.white, size: 28),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontFamily: 'Open Sans',
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCharacteristicsSection() {
//     // Define all characteristics items
//     final List<Map<String, String>> characteristics = [
//       {'label': 'Plant type', 'value': 'Type name'},
//       {'label': 'Common name', 'value': 'Name'},
//       {'label': 'Toxicity', 'value': 'Non-toxic'},
//       {'label': 'Common problems', 'value': 'None'},
//       {'label': 'Common pests', 'value': 'None'},
//       {'label': 'Suitable temperature', 'value': '18-24°C'},
//       {'label': 'Flower', 'value': 'Yes'},
//       {'label': 'Bloom time', 'value': 'Spring'},
//       {'label': 'Mature size', 'value': '0.5-1m'},
//       {'label': 'Leaf color', 'value': 'Green'},
//     ];
//
//     // Calculate items to show based on expanded state
//     final itemsToShow = _isCharacteristicsExpanded
//         ? characteristics
//         : characteristics.take(3).toList();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Characteristics',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 24,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 14),
//         Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             // Added shadow for depth
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // Show limited or all items based on expanded state
//               ...itemsToShow.map((item) => _buildCharacteristicItem(
//                 item['label']!,
//                 item['value']!,
//                 // Remove divider for last item
//                 showDivider: item != itemsToShow.last,
//               )),
//               // Show more/less button
//               InkWell(
//                 onTap: () {
//                   setState(() {
//                     _isCharacteristicsExpanded = !_isCharacteristicsExpanded;
//                   });
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         _isCharacteristicsExpanded ? 'Show less' : 'Show more',
//                         style: const TextStyle(
//                           color: Color(0xFF727272),
//                           fontFamily: 'Open Sans',
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Icon(
//                         _isCharacteristicsExpanded
//                             ? Icons.keyboard_arrow_up
//                             : Icons.keyboard_arrow_down,
//                         color: const Color(0xFF727272),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
// // Modified characteristic item with optional divider
//   Widget _buildCharacteristicItem(String label, String value, {bool showDivider = true}) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: Row(
//             children: [
//               Container(
//                 width: 46,
//                 height: 46,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFAFAFAF),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       label,
//                       style: const TextStyle(
//                         fontFamily: 'Open Sans',
//                         fontSize: 16,
//                       ),
//                     ),
//                     Text(
//                       value,
//                       style: const TextStyle(
//                         fontFamily: 'Open Sans',
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (showDivider) const Divider(color: Color(0xFFD9D9D9)),
//       ],
//     );
//   }
//
//   // Widget _buildFAQSection() {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       const Text(
//   //         'FAQ',
//   //         style: TextStyle(
//   //           fontFamily: 'Poppins',
//   //           fontSize: 24,
//   //           fontWeight: FontWeight.w500,
//   //         ),
//   //       ),
//   //       const SizedBox(height: 14),
//   //       _buildFAQItem('Is this tree/plant easy to grow?'),
//   //       _buildFAQItem('How fast does this tree/plant name grow?'),
//   //       _buildFAQItem('Can I plant snake plant outside?'),
//   //       const SizedBox(height: 28),
//   //       _buildReportSection(),
//   //     ],
//   //   );
//   // }
//   Widget _buildFAQSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'FAQ',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 24,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 14),
//         ...List.generate(
//           _faqItems.length,
//               (index) => _buildFAQItem(_faqItems[index], index),
//         ),
//         const SizedBox(height: 28),
//         _buildReportSection(),
//       ],
//     );
//   }
//
//   // Widget _buildFAQItem(String question) {
//   //   return Container(
//   //     margin: const EdgeInsets.only(bottom: 14),
//   //     padding: const EdgeInsets.all(14),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(14),
//   //     ),
//   //     child: Row(
//   //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //       children: [
//   //         Expanded(
//   //           child: Text(
//   //             question,
//   //             style: const TextStyle(
//   //               fontFamily: 'Open Sans',
//   //               fontSize: 16,
//   //               fontWeight: FontWeight.w600,
//   //             ),
//   //           ),
//   //         ),
//   //         const Icon(Icons.keyboard_arrow_down),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   Widget _buildFAQItem(FAQItem item, int index) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           InkWell(
//             onTap: () {
//               setState(() {
//                 item.isExpanded = !item.isExpanded;
//               });
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(14),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       item.question,
//                       style: const TextStyle(
//                         fontFamily: 'Open Sans',
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   Icon(
//                     item.isExpanded
//                         ? Icons.keyboard_arrow_up
//                         : Icons.keyboard_arrow_down,
//                     color: const Color(0xFF727272),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (item.isExpanded) ...[
//             const Divider(
//               height: 1,
//               color: Color(0xFFD9D9D9),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(14),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.answer,
//                     style: const TextStyle(
//                       fontFamily: 'Open Sans',
//                       fontSize: 14,
//                       height: 1.5,
//                       color: Color(0xFF737373),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//   Widget _buildReportSection() {
//     return Column(
//       children: [
//         const Text(
//           'Is the information wrong? If you find anything wrong, please help us by reporting it below.',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontFamily: 'Open Sans',
//             fontSize: 16,
//             color: Colors.black,
//           ),
//         ),
//         const SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: () {
//             // Handle report button press
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFFF0857D),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(50),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 53, vertical: 10),
//           ),
//           child: const Text(
//             'Report',
//             style: TextStyle(
//               fontFamily: 'Open Sans',
//               fontSize: 16,
//               color: Colors.black,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:treemate/controllers/plant_controller.dart';
// import 'package:treemate/models/plant_model.dart';
//
// enum PlantCareSection {
//   waterAndMisting,
//   siteLightAndTemperature,
//   fertilizer,
//   potAndSoil,
// }
//
// enum PlantLanguage {
//   english('English', 'Snake Plant'),
//   hindi('Hindi', 'नागदमन'),
//   assamese('Assamese', 'পৰ্ৰোলী');
//
//   final String label;
//   final String plantName;
//   const PlantLanguage(this.label, this.plantName);
// }
//
// class FAQItem {
//   final String question;
//   final String answer;
//   bool isExpanded;
//
//   FAQItem({
//     required this.question,
//     required this.answer,
//     this.isExpanded = false,
//   });
// }
//
// class PlantDetailPage extends StatefulWidget {
//   final String plantId;
//   const PlantDetailPage({Key? key, required this.plantId}) : super(key: key);
//
//   @override
//   State<PlantDetailPage> createState() => _PlantDetailPageState();
// }
//
// class _PlantDetailPageState extends State<PlantDetailPage> {
//   final ScrollController _scrollController = ScrollController();
//   final PageController _pageController = PageController();
//   PlantLanguage _selectedLanguage = PlantLanguage.english;
//
//   final GlobalKey _overviewKey = GlobalKey();
//   final GlobalKey _plantCareKey = GlobalKey();
//   final GlobalKey _characteristicsKey = GlobalKey();
//   final GlobalKey _faqKey = GlobalKey();
//
//   int _selectedTabIndex = 0;
//   bool _isTabBarVisible = true;
//   double _previousScrollOffset = 0;
//
//   late Future<Map<String, dynamic>> _plantDataFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//     _plantDataFuture = _fetchPlantDetails(widget.plantId);
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   Future<Map<String, dynamic>> _fetchPlantDetails(String plantId) async {
//     try {
//       final PlantModel plant = await PlantsController().getPlantById(plantId);
//       print("[DEBUG] API Response: ${plant.toJson()}");
//       return plant.toJson();
//     } catch (e) {
//       print("[ERROR] Error fetching plant details: $e");
//       throw Exception('Error fetching plant details: $e');
//     }
//   }
//
//   void _scrollToSection(int index) {
//     double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight + 40;
//
//     double offset = 0;
//     switch (index) {
//       case 0:
//         offset = 0; // Scroll to the top (Overview section)
//         break;
//       case 1:
//         offset = (_plantCareKey.currentContext?.findRenderObject() as RenderBox?)
//             ?.localToGlobal(Offset.zero)
//             .dy ??
//             0 - appBarHeight;
//         break;
//       case 2:
//         offset = (_characteristicsKey.currentContext?.findRenderObject() as RenderBox?)
//             ?.localToGlobal(Offset.zero)
//             .dy ??
//             0 - appBarHeight;
//         break;
//       case 3:
//         offset = (_faqKey.currentContext?.findRenderObject() as RenderBox?)
//             ?.localToGlobal(Offset.zero)
//             .dy ??
//             0 - appBarHeight;
//         break;
//     }
//     _scrollController.animateTo(
//       offset,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   void _onScroll() {
//     setState(() {
//       if (_scrollController.offset <= 0) {
//         _isTabBarVisible = true;
//       } else {
//         _isTabBarVisible = _scrollController.offset < _previousScrollOffset;
//       }
//       _previousScrollOffset = _scrollController.offset;
//     });
//
//     double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight + 40;
//
//     final plantCarePosition = (_plantCareKey.currentContext?.findRenderObject() as RenderBox?)
//         ?.localToGlobal(Offset.zero)
//         .dy ?? 0;
//     final characteristicsPosition = (_characteristicsKey.currentContext?.findRenderObject() as RenderBox?)
//         ?.localToGlobal(Offset.zero)
//         .dy ?? 0;
//     final faqPosition = (_faqKey.currentContext?.findRenderObject() as RenderBox?)
//         ?.localToGlobal(Offset.zero)
//         .dy ?? 0;
//
//     if (_scrollController.offset >= (faqPosition - appBarHeight)) {
//       setState(() => _selectedTabIndex = 3);
//     } else if (_scrollController.offset >= (characteristicsPosition - appBarHeight)) {
//       setState(() => _selectedTabIndex = 2);
//     } else if (_scrollController.offset >= (plantCarePosition - appBarHeight)) {
//       setState(() => _selectedTabIndex = 1);
//     } else {
//       setState(() => _selectedTabIndex = 0);
//     }
//   }
//
//   Future<bool> _addPlantForUser({
//     required String plantName,
//     required String plantId,
//     required String siteId,
//     required String lastWateredAt,
//   }) async {
//     const String endpoint = "/userPlants/addPlantForUser";
//     const FlutterSecureStorage secureStorage = FlutterSecureStorage();
//
//     try {
//       // Fetch the access token directly from secure storage
//       final String? accessToken = await secureStorage.read(key: 'accessToken');
//       if (accessToken == null || accessToken.isEmpty) {
//         print("[ERROR] Access token is missing or empty.");
//         return false;
//       }
//
//       // Construct the headers
//       final Map<String, String> headers = {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       };
//
//       // Construct the API URL
//       const String baseUrl =
//           "https://treemate-app-azgqccezecdjgzac.centralindia-01.azurewebsites.net/api/v1";
//       final Uri url = Uri.parse("$baseUrl$endpoint");
//
//       // Create the request body
//       final Map<String, dynamic> body = {
//         "plantName": plantName,
//         "plantId": plantId,
//         "siteId": siteId,
//         "lastWateredAt": lastWateredAt,
//       };
//
//       // Make the POST request
//       final http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: jsonEncode(body),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("[DEBUG] Plant added successfully: ${response.body}");
//         return true;
//       } else {
//         print("[ERROR] Failed to add plant: ${response.statusCode} - ${response.body}");
//         return false;
//       }
//     } catch (e) {
//       print("[ERROR] Exception in adding plant: $e");
//       return false;
//     }
//   }
//
//
//
//   Widget _buildAddPlantButton(BuildContext context, Map<String, dynamic> plantData) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFF2B9348),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//       ),
//       onPressed: () async {
//         try {
//           final response = await _addPlantForUser(
//             plantName: plantData['commonName'] ?? 'Unknown Plant',
//             plantId: widget.plantId,
//             siteId: "37044411-2f98-49b4-bf0a-71b6b75519f5",
//             lastWateredAt: "YESTERDAY",
//           );
//
//           if (response) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("Plant added successfully!"),
//                 backgroundColor: Colors.green,
//               ),
//             );
//           } else {
//             throw Exception("Failed to add the plant.");
//           }
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Error: $e"),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       },
//       child: const Text(
//         "Add Plant",
//         style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   Widget _buildOverviewSection(Map<String, dynamic> plantData) {
//     final imageUrl = plantData['plantImage'] ?? '';
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             radius: 80,
//             backgroundColor: Colors.grey[200],
//             backgroundImage: imageUrl.isNotEmpty
//                 ? NetworkImage(imageUrl)
//                 : const AssetImage('assets/image/plant.png') as ImageProvider,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             plantData['commonName'] ?? 'NA',
//             style: const TextStyle(
//               fontFamily: 'Poppins',
//               fontSize: 28,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           Text(
//             plantData['scientificName'] ?? 'Scientific name unavailable',
//             style: const TextStyle(
//               fontFamily: 'Open Sans',
//               fontSize: 16,
//               color: Color(0xFF737373),
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildAddPlantButton(context, plantData),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _plantDataFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Text(
//               "Failed to fetch plant details. Please try again later.",
//               style: const TextStyle(
//                 color: Colors.green,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           );
//         } else if (!snapshot.hasData) {
//           return Center(child: Text("No data available for this plant."));
//         }
//
//         final plantData = snapshot.data!;
//         return Scaffold(
//           backgroundColor: const Color(0xFFEEF1EF),
//           body: Stack(
//             children: [
//               CustomScrollView(
//                 controller: _scrollController,
//                 slivers: [
//                   SliverAppBar(
//                     pinned: true,
//                     floating: true,
//                     elevation: 0,
//                     backgroundColor: const Color(0xFFEEF1EF),
//                     expandedHeight: kToolbarHeight + 40,
//                     flexibleSpace: FlexibleSpaceBar(
//                       expandedTitleScale: 1.0,
//                       title: Column(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           _buildTabBar(),
//                         ],
//                       ),
//                     ),
//                     leading: IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                   SliverToBoxAdapter(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           key: _overviewKey,
//                           child: _buildOverviewSection(plantData),
//                         ),
//                         // Additional sections...
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTabBar() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Container(
//         height: 36,
//         padding: const EdgeInsets.symmetric(horizontal: 19),
//         child: Row(
//           children: [
//             _buildTab("Overview", 0),
//             _buildTab("Plant Care", 1),
//             _buildTab("Characteristics", 2),
//             _buildTab("FAQ", 3),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTab(String text, int index) {
//     final isSelected = _selectedTabIndex == index;
//     return GestureDetector(
//       onTap: () {
//         setState(() => _selectedTabIndex = index);
//         _scrollToSection(index);
//       },
//       child: Container(
//         margin: const EdgeInsets.only(right: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFCDE1D2) : Colors.transparent,
//           border: isSelected
//               ? Border.all(color: const Color(0xFF2B9348))
//               : null,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           text,
//           style: const TextStyle(
//             fontFamily: 'Open Sans',
//             fontSize: 16,
//             color: Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:treemate/plant/controllers/plant_controller.dart';
import 'package:treemate/plant/models/plant_model.dart';
import 'automated_watering_page.dart';

enum PlantCareSection {
  waterAndMisting,
  siteLightAndTemperature,
  fertilizer,
  potAndSoil,
}

enum PlantLanguage {
  english('English', 'NA'),
  hindi('Hindi', 'NA'),
  assamese('Assamese', 'NA');

  final String label;
  final String plantName;
  const PlantLanguage(this.label, this.plantName);
}

class FAQItem {
  final String question;
  final String answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

class PlantDetailPage extends StatefulWidget {
  final String plantId;
  const PlantDetailPage({super.key, required this.plantId});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  PlantLanguage _selectedLanguage = PlantLanguage.english;

  // Section positions
  final GlobalKey _overviewKey = GlobalKey();
  final GlobalKey _plantCareKey = GlobalKey();
  final GlobalKey _characteristicsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  int _selectedTabIndex = 0;
  bool _isTabBarVisible = true;
  double _previousScrollOffset = 0;

  final Map<PlantCareSection, bool> _expandedSections = {
    PlantCareSection.waterAndMisting: false,
    PlantCareSection.siteLightAndTemperature: false,
    PlantCareSection.fertilizer: false,
    PlantCareSection.potAndSoil: false,
  };
  bool _isCharacteristicsExpanded = false;

  final List<FAQItem> _faqItems = [
    FAQItem(
      question: "Is this tree/plant easy to grow?",
      answer: "Coming Soon!",
    ),
    FAQItem(
      question: "How fast does this tree/plant grow?",
      answer: "Coming Soon!",
    ),
    FAQItem(
      question: "Can I plant this plant outside?",
      answer: "Coming Soon!",
    ),
  ];

  PlantModel? _plant;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchPlantData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _fetchPlantData() async {
    try {
      PlantModel plant = await PlantsController().getPlantById(widget.plantId);
      setState(() {
        _plant = plant;
      });
    } catch (e) {
      setState(() {
        _plant = null;
      });
      // Optionally, show an error message to the user
    }
  }

  void _onScroll() {
    setState(() {
      if (_scrollController.offset <= 0) {
        _isTabBarVisible = true;
      } else {
        _isTabBarVisible = _scrollController.offset < _previousScrollOffset;
      }
      _previousScrollOffset = _scrollController.offset;
    });
    // Get app bar height
    double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight + 40;

    // Calculate positions with offset
    final plantCarePosition =
        (_plantCareKey.currentContext?.findRenderObject() as RenderBox?)
            ?.localToGlobal(Offset.zero)
            .dy ??
            0;
    final characteristicsPosition =
        (_characteristicsKey.currentContext?.findRenderObject() as RenderBox?)
            ?.localToGlobal(Offset.zero)
            .dy ??
            0;
    final faqPosition =
        (_faqKey.currentContext?.findRenderObject() as RenderBox?)
            ?.localToGlobal(Offset.zero)
            .dy ??
            0;

    // Update selected tab based on scroll position
    if (_scrollController.offset >= (faqPosition - appBarHeight)) {
      setState(() => _selectedTabIndex = 3);
    } else if (_scrollController.offset >= (characteristicsPosition - appBarHeight)) {
      setState(() => _selectedTabIndex = 2);
    } else if (_scrollController.offset >= (plantCarePosition - appBarHeight)) {
      setState(() => _selectedTabIndex = 1);
    } else {
      setState(() => _selectedTabIndex = 0);
    }
  }

  void _scrollToSection(int index) {
    double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight + 40;

    double offset = 0;
    switch (index) {
      case 0:
        offset = 0;
        break;
      case 1:
        offset =
            (_plantCareKey.currentContext?.findRenderObject() as RenderBox?)
                ?.localToGlobal(Offset.zero)
                .dy ??
                0 - appBarHeight;
        break;
      case 2:
        offset =
            (_characteristicsKey.currentContext?.findRenderObject() as RenderBox?)
                ?.localToGlobal(Offset.zero)
                .dy ??
                0 - appBarHeight;
        break;
      case 3:
        offset =
            (_faqKey.currentContext?.findRenderObject() as RenderBox?)
                ?.localToGlobal(Offset.zero)
                .dy ??
                0 - appBarHeight;
        break;
    }
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_plant == null) {
      // Show loading indicator or error message
      return const Scaffold(
        backgroundColor: Color(0xFFEEF1EF),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1EF),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                elevation: 0,
                backgroundColor: const Color(0xFFEEF1EF),
                expandedHeight: kToolbarHeight + 40, // Increased to accommodate tab bar
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.0,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildTabBar(),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  if (_isTabBarVisible)
                    PopupMenuButton(
                      icon: const Icon(Icons.more_horiz),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Share'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Report'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      key: _overviewKey,
                      child: _buildOverviewSection(),
                    ),
                    Container(
                      key: _plantCareKey,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildPlantCareSection(),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      key: _characteristicsKey,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildCharacteristicsSection(),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      key: _faqKey,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildFAQSection(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 19),
        child: Row(
          children: [
            _buildTab("Overview", 0),
            _buildTab("Plant Care", 1),
            _buildTab("Characteristics", 2),
            _buildTab("FAQ", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTabIndex = index);
        _scrollToSection(index);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCDE1D2) : Colors.transparent,
          border: isSelected ? Border.all(color: const Color(0xFF2B9348)) : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildPlantImage() {
    // Use the imageUrl from PlantModel
    final imageUrl = _plant!.imageUrl ?? '';
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 260,
          child: PageView(
            controller: _pageController,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD9D9D9),
                    width: 0.5,
                  ),
                  image: DecorationImage(
                    image: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/image/placeholder.png') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Additional dummy images or placeholders if needed
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[300],
                ),
                child: const Center(child: Text('NA', style: TextStyle(fontSize: 24))),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SmoothPageIndicator(
            controller: _pageController,
            count: 2,
            effect: const ExpandingDotsEffect(
              dotColor: Colors.white60,
              activeDotColor: Colors.white,
              dotHeight: 6,
              dotWidth: 6,
              expansionFactor: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _plant!.commonName ?? 'NA',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          _plant!.scientificName ?? 'NA',
          style: const TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 16,
            color: Color(0xFF737373),
          ),
        ),
        const SizedBox(height: 10),
        _buildLanguageSelector(),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PlantLanguage>(
          value: _selectedLanguage,
          isExpanded: true,
          isDense: true,
          menuMaxHeight: 200,
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF737373),
            size: 20,
          ),
          items: PlantLanguage.values.map((language) {
            return DropdownMenuItem(
              value: language,
              child: Text(
                language.label,
                style: const TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
          onChanged: (PlantLanguage? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedLanguage = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlantImage(),
          const SizedBox(height: 10),
          _buildPlantInfo(),
          const SizedBox(height: 10),
          _buildQuickStats(),
          const SizedBox(height: 10),
          _buildDescription(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plant description',
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF737373),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _plant!.description ?? 'NA',
            style: const TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 16,
              height: 1.5,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  String truncateString(String? text, int maxLength) {
    if (text == null) return 'NA';
    return text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
  }

  Widget _buildQuickStats() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add Plant',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Open Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B9348),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    // onPressed: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => AutomatedWateringPage(),
                    //     ),
                    //   );
                    // },
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AutomatedWateringPage(
                            plantId: _plant!.id, // Pass the plant ID
                            plantName: _plant!.commonName ?? 'NA', // Pass the plant name
                            plantImageUrl: _plant!.imageUrl ?? '', // Pass the plant image URL
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(12),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.favorite_outline,
                    size: 28,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    // TODO: Implement favorite functionality
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.zero,
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildInfoChip(
                Icons.water_drop_outlined,
                _plant!.waterRequirement ?? 'NA',
                iconColor: const Color(0xFF2B9348),              // Desired icon color
                backgroundColor: const Color(0xFFDEF0E3),
              ),
              _buildInfoChip(
                Icons.trending_up,
                _plant!.difficultyLevel ?? 'NA',
              ),
              _buildInfoChip(
                Icons.location_on_outlined,
                _plant!.plantType ?? 'NA',
              ),
              // _buildInfoChip(
              //   Icons.warning_outlined,
              //   _plant!.toxicity ?? 'NA',
              // ),

              _buildInfoChip(
                Symbols.skull,
                truncateString(_plant!.toxicity, 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildInfoChip(IconData icon, String label) {
  Widget _buildInfoChip(
      IconData icon,
      String label, {
        Color iconColor = const Color(0xFF2B9348),            // Default icon color
        Color backgroundColor = const Color(0xFFDEF0E3), // Default background color
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              // color: Color(0xFFDEF0E3),
              color: backgroundColor, // Use the dynamic background color
              shape: BoxShape.circle,
            ),
            // child: Icon(icon, color: Colors.white, size: 20),
            child: Icon(icon, color: iconColor, size: 20), // Use the dynamic icon color
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plant Care',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        _buildExpandableCareCard(
          'Water & Misting',
          PlantCareSection.waterAndMisting,
          [
            _buildCareItem(
              icon: Icons.water_drop,
              backgroundColor: const Color(0xFF53CBFF),
              // title: _plant!.waterRequirement ?? 'NA',
              title: 'Water requirement is ${_plant!.waterRequirement ?? 'NA'}',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Divider(color: Color(0xFFD9D9D9)),
            ),
            _buildCareItem(
              icon: Symbols.household_supplies,
              backgroundColor: const Color(0xFF34CDC4),
              // title: _plant!.mistingRequirement ?? 'NA',
              title: _plant!.mistingRequirement != null
                  ? 'Misting every ${_plant!.mistingRequirement} days'
                  : 'NA',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildExpandableCareCard(
          'Site, light & temperature',
          PlantCareSection.siteLightAndTemperature,
          [
            _buildCareItem(
              icon: Icons.home_outlined,
              iconColor: const Color(0xFF2B9348),
              backgroundColor: const Color(0xFF2B9348),
              // title: _plant!.plantType ?? 'NA',
              title: _plant!.plantType != null
                  ? 'Suitable Site: ${_plant!.plantType}'
                  : 'NA',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Divider(color: Color(0xFFD9D9D9)),
            ),
            _buildCareItem(
              icon: Icons.wb_sunny_outlined,
              iconColor: const Color(0xFF2B9348),
              backgroundColor: const Color(0xFFFFBA53),
              // title: _plant!.sunlightRequirement ?? 'NA',
              title: _plant!.sunlightRequirement != null
                  ? 'Light: ${_plant!.sunlightRequirement}'
                  : 'NA',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildExpandableCareCard(
          'Fertilizer',
          PlantCareSection.fertilizer,
          [
            _buildCareItem(
              icon: Symbols.medication_liquid,
              backgroundColor: const Color(0xFFFA4CFE),
              // title: _plant!.fertilizerRequirement ?? 'NA',
              title: _plant!.fertilizerRequirement != null
                  ? 'Fertilize                          Every ${_plant!.fertilizerRequirement} days'
                  : 'NA',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Divider(color: Color(0xFFD9D9D9)),
            ),
            _buildCareItem(
              icon: Symbols.bloodtype,
              backgroundColor: const Color(0xFF797979),
              title: 'Fertilizer type                 Liquid, Solid',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildExpandableCareCard(
          'Pot and Soil',
          PlantCareSection.potAndSoil,
          [
            _buildCareItem(
              icon: Symbols.grass,
              backgroundColor: const Color(0xFF2B9348),
              // title: _plant!.soilType ?? 'NA',
              title: _plant!.soilType != null
                  ? 'Suitable soil type: ${_plant!.soilType}'
                  : 'NA',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Divider(color: Color(0xFFD9D9D9)),
            ),
            _buildCareItem(
              icon: Symbols.compost,
              backgroundColor: const Color(0xFF797979),
              title: 'Repot every 3 months',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandableCareCard(
      String title, PlantCareSection section, List<Widget> items) {
    final isExpanded = _expandedSections[section] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Added shadow
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Added crossAxisAlignment
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF737373),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Open Sans',
                  ),
                ),
                const SizedBox(height: 16),
                ...items,
              ],
            ),
          ),
          if (isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Divider(color: Color(0xFFD9D9D9)),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Care Instructions',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Coming Soon!',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[section] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFDFD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpanded ? 'Show less' : 'Learn more',
                      style: const TextStyle(
                        color: Color(0xFF727272),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Open Sans',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFF727272),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareItem({
    required IconData icon,
    required Color backgroundColor,
    required String title,
    Color iconColor = const Color(0xFF2B9348),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicsSection() {
    // Define all characteristics items
    // final List<Map<String, String>> characteristics = [
    //   {'label': 'Plant type', 'value': _plant!.plantType ?? 'NA'},
    //   {'label': 'Common name', 'value': _plant!.commonName ?? 'NA'},
    //   {'label': 'Toxicity', 'value': _plant!.toxicity ?? 'NA'},
    //   {'label': 'Common problems', 'value': 'NA'},
    //   {'label': 'Common pests', 'value': 'NA'},
    //   {'label': 'Suitable temperature', 'value': 'NA'},
    //   {'label': 'Flower', 'value': 'NA'},
    //   {'label': 'Bloom time', 'value': _plant!.bloomTime ?? 'NA'},
    //   {'label': 'Mature size', 'value': _plant!.matureSize ?? 'NA'},
    //   {'label': 'Leaf color', 'value': 'NA'},
    // ];
    final List<Map<String, String>> characteristics = [
      {
        'label': 'Plant type',
        'value': truncateString(_plant!.plantType, 13),
        // _plant!.plantType ?? 'NA'
      },
      {
        'label': 'Common name',
        'value': truncateString(_plant!.commonName, 13),
        // _plant!.commonName ?? 'NA'
      },
      {
        'label': 'Toxicity',
        'value': truncateString(_plant!.toxicity, 13),
        // _plant!.toxicity ?? 'NA'
      },
      {
        'label': 'Common problems',
        'value': truncateString(_plant!.commonProblemsOrDiseases, 13),
        // 'NA'
      },
      {
        'label': 'Common pests',
        'value': truncateString(_plant!.commonPests, 13),
        // 'NA'
      },
      {
        'label': 'Suitable temperature',
        'value': truncateString(_plant!.suitableTemperature, 13),
        // 'NA'
      },
      {
        'label': 'Flower',
        'value': truncateString(null, 13),
        // 'NA'
      },
      {
        'label': 'Bloom time',
        'value': truncateString(_plant!.bloomTime, 13),
        // _plant!.bloomTime ?? 'NA'
      },
      {
        'label': 'Mature size',
        'value': truncateString(_plant!.matureSize, 13),
        // _plant!.matureSize ?? 'NA'
      },
      {
        'label': 'Leaf color',
        'value': truncateString(null, 13),
        // 'NA'
      },
    ];


    // Calculate items to show based on expanded state
    final itemsToShow =
    _isCharacteristicsExpanded ? characteristics : characteristics.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Characteristics',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            // Added shadow for depth
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Show limited or all items based on expanded state
              ...itemsToShow.map((item) => _buildCharacteristicItem(
                item['label']!,
                item['value']!,
                // Remove divider for last item
                showDivider: item != itemsToShow.last,
              )),
              // Show more/less button
              InkWell(
                onTap: () {
                  setState(() {
                    _isCharacteristicsExpanded = !_isCharacteristicsExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isCharacteristicsExpanded ? 'Show less' : 'Show more',
                        style: const TextStyle(
                          color: Color(0xFF727272),
                          fontFamily: 'Open Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isCharacteristicsExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF727272),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Modified characteristic item with optional divider
  Widget _buildCharacteristicItem(String label, String value, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFDEF0E3),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(color: Color(0xFFD9D9D9)),
      ],
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FAQ',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(
          _faqItems.length,
              (index) => _buildFAQItem(_faqItems[index], index),
        ),
        const SizedBox(height: 28),
        _buildReportSection(),
      ],
    );
  }

  Widget _buildFAQItem(FAQItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                item.isExpanded = !item.isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.question,
                      style: const TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    item.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF727272),
                  ),
                ],
              ),
            ),
          ),
          if (item.isExpanded) ...[
            const Divider(
              height: 1,
              color: Color(0xFFD9D9D9),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.answer,
                    style: const TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF737373),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportSection() {
    return Column(
      children: [
        const Text(
          'Is the information wrong? If you find anything wrong, please help us by reporting it below.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Handle report button press
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF0857D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 53, vertical: 10),
          ),
          child: const Text(
            'Report',
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
