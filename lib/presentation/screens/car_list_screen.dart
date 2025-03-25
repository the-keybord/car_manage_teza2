import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/car_sharing_action_button.dart';
import '../widgets/car_sharing_dialog.dart';
import '../../controllers/car_list_controller.dart';
import '../widgets/add_car_dialog.dart';

class CarListScreen extends StatelessWidget {
  final Function(String carId, String carName, String bleDeviceId)
  onCarSelected;

  CarListScreen({required this.onCarSelected, Key? key}) : super(key: key);

  final CarListController controller = Get.find<CarListController>();

  @override
  Widget build(BuildContext context) {
    print("📲 CarListScreen build triggered");

    return Scaffold(
      appBar: AppBar(
        title: Text("My Cars"),
        actions: [
          IconButton(
            icon: Icon(Icons.cancel), // sau altă iconiță potrivită
            tooltip: 'Deselect Car',
            onPressed: () {
              print("❎ No car selected tapped");
              controller.saveSelectedCar('none', 'No Car', 'none');
              onCarSelected('none', 'No Car', 'none');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final carName = await showDialog<String>(
            context: context,
            builder: (_) => const AddCarDialog(),
          );

          if (carName != null && carName.isNotEmpty) {
            // TODO: Send to Firestore via controller
            print("🚗 Add car: $carName");
          }
        },
        icon: Icon(Icons.add),
        label: Text('Add Car'),
      ),
      body: FutureBuilder(
        future: controller.loadSelectedCar(),
        builder: (context, snapshot) {
          print("🔄 FutureBuilder state: ${snapshot.connectionState}");
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder(
            stream: controller.carStream,
            builder: (context, AsyncSnapshot snapshot) {
              print("📡 StreamBuilder triggered");

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No cars found"));
              }

              final cars = snapshot.data!.docs;
              print("🚗 Cars loaded: ${cars.length}");

              return Obx(() {
                print(
                  "🎯 Obx rebuild: selectedCarId = ${controller.selectedCarId.value}",
                );
                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    // if (index == 0) {
                    //   return ListTile(
                    //     title: const Text("🚫 No Car Selected"),
                    //     subtitle: const Text("Tap to deselect current car"),
                    //     tileColor: controller.selectedCarId.value == 'none'
                    //         ? Theme.of(context).colorScheme.primaryContainer
                    //         : null,
                    //     onTap: () {
                    //       print("❎ No car selected tapped");
                    //       controller.saveSelectedCar('none', 'No Car', 'none');
                    //       onCarSelected('none', 'No Car', 'none');
                    //     },
                    //   );
                    // }

                    var car = cars[index].data() as Map<String, dynamic>;
                    String carId = cars[index].id;
                    String carName = car['name'] ?? "Unknown Car";
                    String bleDeviceId = car['bleDeviceId'] ?? "";

                    final colorScheme = Theme.of(context).colorScheme;

                    return InkWell(
                      onTap: () {
                        print("✅ Car tapped: $carName ($carId)");
                        onCarSelected(carId, carName, bleDeviceId);
                        if (bleDeviceId.isNotEmpty) {
                          controller.saveSelectedCar(
                            carId,
                            carName,
                            bleDeviceId,
                          );

                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "⚠ No BLE device linked to this car",
                              ),
                            ),
                          );
                        }
                      },
                      child: Card(
                        color: colorScheme.surfaceContainerHighest,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                carName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 4),
                              Text(
                                "${car['brand']} - ${car['year']} - " +
                                        car['status'] ??
                                    "Unknown",
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed:
                                            () => print("✏️ Edit $carId"),
                                        icon: Icon(Icons.edit, size: 16),
                                        label: Text("Edit"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          foregroundColor: Colors.white,
                                          minimumSize: Size(80, 36),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed:
                                            () => print("🗑 Delete $carId"),
                                        icon: Icon(Icons.delete, size: 16),
                                        label: Text("Delete"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          minimumSize: Size(80, 36),
                                        ),
                                      ),
                                      CarSharingActionButton(
                                        carId: carId,
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => CarSharingDialog(
                                              carId: carId,
                                              carName: carName,
                                            ),
                                          );
                                        },
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    // return ListTile(
                    //   title: Text(carName),
                    //   subtitle: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text("${car['brand']} - ${car['year']}"),
                    //       Wrap(
                    //         spacing: 8,
                    //         children: [
                    //           ElevatedButton.icon(
                    //             onPressed: () => print("✏️ Edit $carId"),
                    //             icon: Icon(Icons.edit, size: 16),
                    //             label: Text("Edit"),
                    //           ),
                    //           ElevatedButton.icon(
                    //             onPressed: () => print("🗑 Delete $carId"),
                    //             icon: Icon(Icons.delete, size: 16),
                    //             label: Text("Delete"),
                    //           ),
                    //           ElevatedButton.icon(
                    //             onPressed: () => print("ℹ️ Info $carId"),
                    //             icon: Icon(Icons.share, size: 16),
                    //             label: Text("Share"),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    //   trailing: Text(car['status'] ?? "Unknown"),
                    //   tileColor: controller.selectedCarId.value == carId
                    //       ? Colors.blue.withOpacity(0.2)
                    //       : null,
                    //   onTap: () {
                    //     print("✅ Car tapped: $carName ($carId)");
                    //     if (bleDeviceId.isNotEmpty) {
                    //       controller.saveSelectedCar(carId, carName, bleDeviceId);
                    //       onCarSelected(carId, carName, bleDeviceId);
                    //     } else {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(content: Text("⚠ No BLE device linked to this car")),
                    //       );
                    //     }
                    //   },
                    // );
                  },
                );
              });
            },
          );
        },
      ),
    );
  }
}
