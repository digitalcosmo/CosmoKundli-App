import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationController extends GetxController {
  var allLocations = <String>[].obs;
  var filteredLocations = <String>[].obs;
  var selectedLocation = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadLocations();
  }

  void loadLocations() {
    allLocations.assignAll([
      // Countries
      'India', 'USA', 'Canada', 'Australia', 'UK',
      // States
      'Gujarat', 'Maharashtra', 'California', 'Texas', 'Ontario',
      // Cities
      'Ahmedabad', 'Mumbai', 'Los Angeles', 'Houston', 'Toronto',
    ]);
    filteredLocations.assignAll(allLocations);
  }

  void filterLocations(String query) {
    if (query.isEmpty) {
      filteredLocations.assignAll(allLocations);
    } else {
      filteredLocations.value = allLocations
          .where((loc) => loc.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}

class LocationSearchPage extends StatelessWidget {
  final LocationController controller = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Type city, state, or country',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: controller.filterLocations,
            ),
          ),

          // Filtered location list
          Expanded(
            child: Obx(() => controller.filteredLocations.isEmpty
                ? const Center(child: Text('No results found'))
                : ListView.builder(
              itemCount: controller.filteredLocations.length,
              itemBuilder: (context, index) {
                final location = controller.filteredLocations[index];
                return ListTile(
                  title: Text(location),
                  onTap: () {
                    controller.selectedLocation.value = location;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: $location')),
                    );
                  },
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
