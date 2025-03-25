import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CarInfoForm extends StatefulWidget {
  final void Function({
  required String name,
  required String plate,
  required String model,
  required String color,
  File? image,
  }) onSubmit;

  const CarInfoForm({super.key, required this.onSubmit});

  @override
  State<CarInfoForm> createState() => _CarInfoFormState();
}

class _CarInfoFormState extends State<CarInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();

  File? _selectedImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true) {
      widget.onSubmit(
        name: _nameController.text.trim(),
        plate: _plateController.text.trim(),
        model: _modelController.text.trim(),
        color: _colorController.text.trim(),
        image: _selectedImage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text("Enter Car Information", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Car Name'),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _plateController,
              decoration: const InputDecoration(labelText: 'License Plate'),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(labelText: 'Color'),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                child: _selectedImage == null ? const Icon(Icons.camera_alt) : null,
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: const Text("Save Car"),
            ),
          ],
        ),
      ),
    );
  }
}
