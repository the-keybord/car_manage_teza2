import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/car_list_controller.dart';

class CarListScreen extends StatelessWidget {
  final Function(String carId, String carName, String bleDeviceId) onCarSelected;

  CarListScreen({required this.onCarSelected, Key? key}) : super(key: key);

  final CarListController controller = Get.find<CarListController>();

  @override
  Widget build(BuildContext context) {
    print("📲 CarListScreen build triggered");

    return Scaffold(
      appBar: AppBar(title: Text("My Cars")),
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
                print("🎯 Obx rebuild: selectedCarId = ${controller.selectedCarId.value}");
                return ListView.builder(
                  itemCount: cars.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        title: const Text("🚫 No Car Selected"),
                        subtitle: const Text("Tap to deselect current car"),
                        tileColor: controller.selectedCarId.value == 'none'
                            ? Colors.blue.withOpacity(0.2)
                            : null,
                        onTap: () {
                          print("❎ No car selected tapped");
                          controller.saveSelectedCar('none', 'No Car', 'none');
                          onCarSelected('none', 'No Car', 'none');
                        },
                      );
                    }

                    var car = cars[index - 1].data() as Map<String, dynamic>;
                    String carId = cars[index - 1].id;
                    String carName = car['name'] ?? "Unknown Car";
                    String bleDeviceId = car['bleDeviceId'] ?? "";

                    return ListTile(
                      title: Text(carName),
                      subtitle: Text("${car['brand']} - ${car['year']}"),
                      trailing: Text(car['status'] ?? "Unknown"),
                      tileColor: controller.selectedCarId.value == carId
                          ? Colors.blue.withOpacity(0.2)
                          : null,
                      onTap: () {
                        print("✅ Car tapped: $carName ($carId)");
                        if (bleDeviceId.isNotEmpty) {
                          controller.saveSelectedCar(carId, carName, bleDeviceId);
                          onCarSelected(carId, carName, bleDeviceId);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("⚠ No BLE device linked to this car")),
                          );
                        }
                      },
                    );
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
