import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Import for Uint8List

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

import 'package:treemate/controllers/user_controller.dart';
import '../providers/user_provider.dart';

// BottomSheetUploadProfilePhotoWidget class
class BottomSheetUploadProfilePhotoWidget extends StatelessWidget {
  final Function(File) onImagePicked;
  final ImagePicker _picker = ImagePicker();

  BottomSheetUploadProfilePhotoWidget({super.key, required this.onImagePicked});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profile Picture', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Symbols.delete),
                iconSize: 24,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOptionButton(
                context,
                icon: Symbols.photo_camera,
                label: 'Camera',
                onTap: () => _pickImage(context, ImageSource.camera),
              ),
              _buildOptionButton(
                context,
                icon: Symbols.image,
                label: 'Gallery',
                onTap: () => _pickImage(context, ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Method to build custom option buttons
Widget _buildOptionButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 77,
          height: 77,
          decoration: const BoxDecoration(
            color: Color(0xFFDEF0E3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Open Sans',
          ),
        ),
      ],
    ),
  );
}

// EditProfileModel class
class EditProfileModel {
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;

  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}

// EditProfileWidget class
class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  late EditProfileModel _model;
  bool _isProfileChanged = false;
  late UserProvider userProvider;
  late var currentUser;
  String _initialName = '';
  String? _base64Image; // Store the base64 image string
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    currentUser = userProvider.currentUser;
    _initialName = currentUser.fullName;
    _base64Image = currentUser.profileImage; // Assuming this contains base64 string
    _model = EditProfileModel()
      ..textController = TextEditingController(text: _initialName)
      ..textFieldFocusNode = FocusNode();

    _model.textController!.addListener(_checkIfProfileChanged);
  }

  @override
  void dispose() {
    _model.textController!.removeListener(_checkIfProfileChanged);
    _model.dispose();
    super.dispose();
  }

  void _checkIfProfileChanged() {
    setState(() {
      bool isNameChanged = _model.textController!.text != _initialName;
      bool isImageChanged = _imageFile != null;
      _isProfileChanged = isNameChanged || isImageChanged;
    });
  }

  void _updateProfile() async {
    // Convert image file to base64 if required
    String? base64Image;
    if (_imageFile != null) {
      base64Image = base64Encode(await _imageFile!.readAsBytes());
    }
    UserController userController = UserController();
    await userController.init(context);
    bool success = await userController.updateUserDetails(
        context, _model.textController!.text, base64Image);
    if (success) {
      setState(() {
        _isProfileChanged = false;
        _initialName = _model.textController!.text;
        _base64Image = base64Image; // Update base64 image string
        if (_imageFile != null) {
          // Optionally, you can also keep the path if needed
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Try again!")));
    }
  }

  Future<void> _pickImage() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetUploadProfilePhotoWidget(
        onImagePicked: (File pickedImage) {
          setState(() {
            _imageFile = pickedImage;
            _checkIfProfileChanged();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (_base64Image != null && _base64Image!.isNotEmpty) {
      imageBytes = base64Decode(_base64Image!); // Decode base64 string
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: const Color(0xFFEEF1EF),
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: Text(
            'Edit Profile',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (imageBytes != null
                        ? MemoryImage(imageBytes) // Use MemoryImage to display
                        : const AssetImage('assets/image/Layer1.png')),
                radius: 50,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2B9348),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Symbols.photo_camera, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _model.textController,
                focusNode: _model.textFieldFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Profile Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isProfileChanged ? _updateProfile : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor:
                      _isProfileChanged ? const Color(0xFF2B9348) : Colors.grey,
                ),
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
