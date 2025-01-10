import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:flood_management_system/component/constant.dart';

class ChecklistScreen extends StatefulWidget {
  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late List<SwipeItem> _checklistSwipeItems;
  late MatchEngine _matchEngine;

  final List<ChecklistItem> _checklistItems = [
    ChecklistItem("Do Immediately", [
      "Be calm",
      "Pack important documents, medicine, phone and wallet",
      "Pets, pet supplies (if any).",
      "See the next Go Bag supplies.",
      "Complete the individual or group report",
    ]),

    ChecklistItem("Go Bag supplies", [
      "At least have your own water bottle",
      "Food : 3-day supply",
      "Warmth/Shelter : Emergency blanket, 3 body warmers (12-hour), poncho",
      "Medical Supplies : First aid kit, pain reliever, 3 pairs of medical gloves, 3-7 days of life-saving medications, copies of prescriptions, N95/cloth mask, hand sanitizer",
      "Lighting : Flashlight (with batteries or crank)",
      "Radio : AM/FM emergency radio (with batteries)",
      "Support Supplies : Whistle, work gloves, sturdy shoes, change of clothes, 3 face masks, wet wipes, tissue pack, 30-gallon plastic bag, 3 10-gallon plastic bags",
      "Packaging: Bag, backpack, or bucket with handle"
    ]),

    ChecklistItem("Do If You Have One Hour", [
      "Basic toiletries such as soap, shampoo, and toothpaste..",
      "Close windows, doors and power supply.",
      "Bring additional clothing.",
      "Bring irreplaceable items such as childrens’ favorite dolls / toys, photos, heirlooms, keepsakes"
    ]),
    ChecklistItem("Do If You Have More than One Hour", [
      "Secure windows and doors – Ensure they are closed and locked.",
      "Check roof and walls",
      "Remove objects outside – Eliminate anything that could become a projectile or cause damage.",
      "Reinforce the structure",
      "Locate an evacuation centre to stay.",
      "Camping gear."
    ]),
    ChecklistItem("Always Ready", [
      "Go Bag in car, home, office.",
      "Fuel in vehicle, at least a half tank at all times.",
      "Know how to open garage door manually."
    ]),
  ];

  // List of colors from constants
  final List<Color> _colorList = [
    kGradientColorTwo,
    kGradientColorOne,
    kAppIconBackgroundColor,
    kWeatherTextColor,
    kButtonTextColor
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the swipe items for the checklist titles
    _checklistSwipeItems = _checklistItems
        .map((checklistItem) => SwipeItem(
      content: SwipeItemContent(text: checklistItem.title),
      likeAction: () {
        // Handle like action if needed
      },
      nopeAction: () {
        // Handle nope action if needed
      },
      superlikeAction: () {
        // Handle superlike action if needed
      },
    ))
        .toList();

    _matchEngine = MatchEngine(swipeItems: _checklistSwipeItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: const Text("Checklist"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height - kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SwipeCards(
            matchEngine: _matchEngine,
            itemBuilder: (BuildContext context, int index) {
              // Get the color from the list using the index, loop if out of bounds
              Color cardColor = _colorList[index % _colorList.length];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SwipeableActionsScreen(checklistItem: _checklistItems[index]),
                    ),
                  );
                },
                child: Card(
                  color: cardColor, // Set the card color dynamically
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        _checklistItems[index].title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
            itemChanged: (SwipeItem item, int index) {
              // You can handle item change if necessary
            },
            onStackFinished: () {
              // Action when all cards are finished
              // Reset to the first card for circular swipe
              setState(() {
                _matchEngine = MatchEngine(swipeItems: _checklistSwipeItems);
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("All checklist items shown"),
                duration: Duration(milliseconds: 500),
              ));
            },
            leftSwipeAllowed: true,
            rightSwipeAllowed: true,
            fillSpace: true,
          ),
        ),
      ),
    );
  }
}

class SwipeableActionsScreen extends StatefulWidget {
  final ChecklistItem checklistItem;

  const SwipeableActionsScreen({Key? key, required this.checklistItem}) : super(key: key);

  @override
  _SwipeableActionsScreenState createState() => _SwipeableActionsScreenState();
}

class _SwipeableActionsScreenState extends State<SwipeableActionsScreen> {
  late List<SwipeItem> _swipeItems;
  late List<bool> _swipedStatuses;

  @override
  void initState() {
    super.initState();

    // Initialize swipe items and swiped statuses for the actions
    _swipeItems = widget.checklistItem.actions
        .map((action) => SwipeItem(content: SwipeItemContent(text: action)))
        .toList();

    _swipedStatuses = List.generate(widget.checklistItem.actions.length, (index) => false);
  }

  // Function to check if all actions are completed
  bool _areAllActionsCompleted() {
    return _swipedStatuses.every((status) => status);
  }

  String getAppBarTitle() {
    if (widget.checklistItem.title == "Do Immediately") {
      return "Do Immediately";
    } else if (widget.checklistItem.title == "Go Bag supplies") {
      return "Go Bag Supplies";
    } else if (widget.checklistItem.title == "Do If You Have One Hour") {
      return "1 Hour Have";
    } else if (widget.checklistItem.title == "Do If You Have More than One Hour") {
      return "More than 1 Hour";
    } else if (widget.checklistItem.title == "Always Ready") {
      return "Always Ready";
    } else {
      return widget.checklistItem.title;  // Fallback if title doesn't match any condition
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Text(getAppBarTitle()),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: kScaffoldColor,
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          child: ListView.builder(
            itemCount: _swipeItems.length,
            itemBuilder: (BuildContext context, int index) {
              // Card color changes to green after ticked
              Color cardColor = _swipedStatuses[index] ? kGradientColorTwo :kCardColor;

              return GestureDetector(
                onTap: () {
                  // Mark action as completed and change color to green
                  setState(() {
                    _swipedStatuses[index] = true;  // Mark as swiped
                  });

                  // If all actions are completed, navigate back to ChecklistScreen
                  if (_areAllActionsCompleted()) {
                    Navigator.pop(context); // Navigate back to ChecklistScreen
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("${widget.checklistItem.title} actions completed"),
                      duration: Duration(milliseconds: 500),
                    ));
                  }
                },
                child: Card(
                  color: cardColor,
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_swipedStatuses[index])
                            Icon(Icons.check, color: kButtonTextColor, size: 30), // Show checkmark icon
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _swipeItems[index].content.text,
                              style: TextStyle(
                                color: kButtonTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ChecklistItem {
  final String title;
  final List<String> actions;

  ChecklistItem(this.title, this.actions);
}

// Define the content class used in Swipe Cards
class SwipeItemContent {
  final String text;

  SwipeItemContent({required this.text});
}
