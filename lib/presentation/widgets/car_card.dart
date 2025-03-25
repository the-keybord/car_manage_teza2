import 'package:flutter/material.dart';

class CarCard extends StatelessWidget {
  final String carId;
  final String name;
  final String plate;
  final String model;
  final String color;
  final String? photoUrl;
  final bool expanded;

  const CarCard({
    super.key,
    required this.carId,
    required this.name,
    required this.plate,
    required this.model,
    required this.color,
    this.photoUrl,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 🖼 Car photo or fallback
            CircleAvatar(
              radius: expanded ? 36 : 28,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
              backgroundColor: colorScheme.primary.withOpacity(0.2),
              child: photoUrl == null
                  ? Icon(Icons.directions_car, size: expanded ? 32 : 24)
                  : null,
            ),
            const SizedBox(width: 16),

            // ℹ️ Car info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: expanded ? 20 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(plate, style: TextStyle(color: Colors.grey[700])),
                  if (expanded) ...[
                    const SizedBox(height: 4),
                    Text("Model: $model"),
                    Text("Color: $color"),
                  ],
                ],
              ),
            ),

            // ➕ Future action area
            if (expanded)
              IconButton(
                icon: const Icon(Icons.more_vert),
                color: colorScheme.primary,
                onPressed: () {
                  // 🔧 Hook into menu or options here
                  print("⚙️ Actions for carId: $carId");
                },
              ),
          ],
        ),
      ),
    );
  }
}
