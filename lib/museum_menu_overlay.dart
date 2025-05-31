// import 'dart:ui'; // Required for ImageFilter.blur
// import 'package:flutter/material.dart';

// // Data for the menu items
// const Map<String, List<String>> _menuData = {
//   "VISIT": [
//     "Plan Your Visit",
//     "Hours & Admission",
//     "Getting Here",
//     "Accessibility",
//     "Group Visits",
//   ],
//   "EXHIBITIONS": [
//     "Current Exhibitions",
//     "Upcoming Exhibitions",
//     "Past Exhibitions",
//     "Online Exhibitions",
//   ],
//   "EVENTS": [
//     "Calendar",
//     "Kids & Families",
//     "Adults",
//     "Teen & Pre-teens",
//     "Summer Programs",
//     "Community Science",
//     "Lectures & Talks",
//   ],
//   "COLLECTION": [
//     "Search Collection",
//     "Highlights",
//     "New Acquisitions",
//     "Conservation",
//   ],
//   "SHOP": ["Online Store", "Books", "Prints", "Gifts", "Membership Gifts"],
//   "ABOUT US": [
//     "Mission & History",
//     "Our Team",
//     "Press Room",
//     "Careers",
//     "Contact Us",
//   ],
//   "BLOGS & VIDEOS": [
//     "Latest Posts",
//     "Video Archive",
//     "Curator Insights",
//     "Artist Interviews",
//   ],
//   "MEMBERSHIP": [
//     "Become a Member",
//     "Renew Membership",
//     "Member Benefits",
//     "Gift a Membership",
//   ],
// };

// const List<String> _mainNavOrder = [
//   "VISIT",
//   "EXHIBITIONS",
//   "EVENTS",
//   "COLLECTION",
//   "SHOP",
//   "ABOUT US",
//   "BLOGS & VIDEOS",
//   "MEMBERSHIP",
// ];

// class MuseumMenuOverlay extends StatefulWidget {
//   const MuseumMenuOverlay({super.key});

//   @override
//   State<MuseumMenuOverlay> createState() => _MuseumMenuOverlayState();
// }

// class _MuseumMenuOverlayState extends State<MuseumMenuOverlay> {
//   String? _activeMainItem;
//   String? _activeSubItem;
//   String _activeLanguage = "EN";

//   late Map<String, GlobalKey> _mainNavKeys;
//   double _subNavTopOffset = 0.0;
//   List<String> _currentSubNavItems = [];

//   static const double _mainNavColumnWidth =
//       280.0; // Adjusted width for larger text
//   static const double _paddingBetweenNavs = 60.0;
//   static const _screenPadding = EdgeInsets.only(
//     top: 20.0,
//     left: 60.0,
//     right: 60.0,
//     bottom: 40.0,
//   ); // Main content padding

//   @override
//   void initState() {
//     super.initState();
//     _mainNavKeys = {for (var item in _mainNavOrder) item: GlobalKey()};

//     // Pre-select "EVENTS" and "Adults" as per the image
//     _activeMainItem = "EVENTS";
//     _currentSubNavItems = _menuData["EVENTS"] ?? [];
//     _activeSubItem = "Adults";

//     // Calculate initial position for sub-nav after the first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _calculateAndSetSubNavPosition("EVENTS");
//     });
//   }

//   void _calculateAndSetSubNavPosition(String itemTitle) {
//     if (_mainNavKeys[itemTitle]?.currentContext == null) {
//       // If context is not yet available, try again in the next frame
//       WidgetsBinding.instance.addPostFrameCallback(
//         (_) => _calculateAndSetSubNavPosition(itemTitle),
//       );
//       return;
//     }

//     final RenderBox? renderBox =
//         _mainNavKeys[itemTitle]?.currentContext?.findRenderObject()
//             as RenderBox?;
//     if (renderBox != null) {
//       // Get the global position of the main nav item
//       final mainNavItemGlobalPosition = renderBox.localToGlobal(Offset.zero);

//       // Calculate the top offset for the Positioned sub-nav.
//       // This needs to be relative to the Stack that contains the Positioned widget.
//       // The Stack is inside Scaffold.body, which is below AppBar and system status bar,
//       // and has _screenPadding.top.
//       final topOffsetOfStackParent =
//           kToolbarHeight + // AppBar height
//           MediaQuery.of(context).padding.top + // Status bar height
//           _screenPadding.top;

//       setState(() {
//         _subNavTopOffset =
//             mainNavItemGlobalPosition.dy - topOffsetOfStackParent;
//         if (_subNavTopOffset < 0)
//           _subNavTopOffset = 0; // Ensure it's not negative
//       });
//     }
//   }

//   void _handleMainNavItemTap(String itemTitle) {
//     setState(() {
//       _activeMainItem = itemTitle;
//       _currentSubNavItems = _menuData[itemTitle] ?? [];
//       _activeSubItem = null; // Reset sub-item selection when main item changes
//       _calculateAndSetSubNavPosition(itemTitle);
//     });
//   }

//   void _handleSubNavItemTap(String subItemTitle) {
//     setState(() {
//       _activeSubItem = subItemTitle;
//       // Potentially navigate or perform an action here
//     });
//   }

//   void _handleLanguageTap(String lang) {
//     setState(() {
//       _activeLanguage = lang;
//     });
//   }

//   Widget _getLogo({bool isSmall = false}) {
//     final fontSize = isSmall ? 18.0 : 26.0; // Smaller logo for the overlay
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           'ART',
//           style: TextStyle(
//             fontSize: fontSize,
//             fontWeight: FontWeight.w100,
//             letterSpacing: 1.2,
//             color: Colors.black,
//           ),
//         ),
//         Text(
//           'ATLAS',
//           style: TextStyle(
//             fontSize: fontSize,
//             fontWeight: FontWeight.w100,
//             letterSpacing: 1.2,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMainNavItem(String title, GlobalKey key) {
//     final bool isActive = _activeMainItem == title;
//     return GestureDetector(
//       key: key,
//       onTap: () => _handleMainNavItemTap(title),
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//             vertical: 10.0,
//           ), // Adjusted padding
//           child: Text(
//             title,
//             style: TextStyle(
//               fontSize: 38, // Larger font size
//               fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//               color: isActive ? Colors.black : Colors.black.withOpacity(0.5),
//               letterSpacing: 0.5,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSubNavItem(String title) {
//     final bool isActive = _activeSubItem == title;
//     return GestureDetector(
//       onTap: () => _handleSubNavItemTap(title),
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Text(
//             title,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//               color: isActive ? Colors.black : Colors.black.withOpacity(0.7),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLanguageItem(String lang) {
//     final bool isActive = _activeLanguage == lang;
//     return GestureDetector(
//       onTap: () => _handleLanguageTap(lang),
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: Text(
//             lang,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//               color: isActive ? Colors.black : Colors.black.withOpacity(0.6),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Blurred background
//         Positioned.fill(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
//             child: Container(
//               color: Colors.black.withOpacity(0.1), // Slight tint for the blur
//             ),
//           ),
//         ),
//         // Semi-transparent white content layer
//         Container(
//           color: Colors.white.withOpacity(0.90), // Slightly more opaque
//           child: Scaffold(
//             backgroundColor: Colors.transparent, // Crucial for overlay
//             appBar: AppBar(
//               automaticallyImplyLeading: false,
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               titleSpacing:
//                   _screenPadding.left, // Align title with content padding
//               title: _getLogo(isSmall: true),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.black, size: 28),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//                 SizedBox(
//                   width: _screenPadding.right - 20,
//                 ), // Adjust for icon padding
//               ],
//             ),
//             body: Padding(
//               padding: _screenPadding,
//               child: Stack(
//                 children: [
//                   // Main Navigation Column
//                   Positioned(
//                     left: 0,
//                     top: 0,
//                     bottom: 0, // Allow it to take full height if needed
//                     child: SizedBox(
//                       width: _mainNavColumnWidth,
//                       child: ListView(
//                         // Use ListView for consistent GlobalKey behavior
//                         padding: EdgeInsets.zero,
//                         children: _mainNavOrder
//                             .map(
//                               (item) =>
//                                   _buildMainNavItem(item, _mainNavKeys[item]!),
//                             )
//                             .toList(),
//                       ),
//                     ),
//                   ),

//                   // Sub Navigation Column (conditionally visible and positioned)
//                   if (_activeMainItem != null && _currentSubNavItems.isNotEmpty)
//                     Positioned(
//                       left: _mainNavColumnWidth + _paddingBetweenNavs,
//                       top: _subNavTopOffset,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: _currentSubNavItems
//                             .map((subItem) => _buildSubNavItem(subItem))
//                             .toList(),
//                       ),
//                     ),

//                   // Language Selector
//                   Align(
//                     alignment: Alignment.bottomRight,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         _buildLanguageItem("HI"),
//                         _buildLanguageItem("EN"),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
