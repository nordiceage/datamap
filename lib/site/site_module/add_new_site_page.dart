import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Added import for secure storage

import 'package:treemate/controllers/sites_controller.dart';
import 'package:treemate/models/base_site_model.dart';
import 'package:treemate/models/site_model.dart';
import 'package:treemate/models/simple_site_model.dart';

class AddNewSitePage extends StatefulWidget {
  const AddNewSitePage({super.key});

  @override
  _AddNewSitePageState createState() => _AddNewSitePageState();
}

class _AddNewSitePageState extends State<AddNewSitePage> {
  List<SiteModel> defaultSites = [];
  bool isLoading = true;
  final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage(); // Initialize secure storage
  late final String apiUrl;

  @override
  void initState() {
    super.initState();
    fetchDefaultSites();
    apiUrl = '${dotenv.env['API_BASE_URL'] ?? "http://localhost:6555"}/api/v1';
  }

  Future<void> fetchDefaultSites() async {
    final sitesController = SitesController();
    await sitesController.init();
    List<SiteModel> sites = await sitesController.getDefaultPlantSites();
    setState(() {
      defaultSites = sites;
      isLoading = false;
    });
  }

  Future<void> addSite(BaseSiteModel site) async {
    String url = '$apiUrl/sites/addSiteForUser';
    String token;

    try {
      token = await _getAccessToken(); // Retrieve the user's access token
    } catch (e) {
      print('Error retrieving access token: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'multipart/form-data', // Do not set this manually for multipart requests
    };

    String siteName = site.siteName;
    String siteType =
        (site is SiteModel) ? site.siteType.toUpperCase() : 'OUTDOOR';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    request.fields['siteName'] = siteName;
    request.fields['siteType'] = siteType;

    if (site is SiteModel && site.siteImage.isNotEmpty) {
      // Download the image from the URL and attach it as a file
      try {
        var imageResponse = await http.get(Uri.parse(site.siteImage));
        if (imageResponse.statusCode == 200) {
          request.files.add(
            http.MultipartFile.fromBytes('image', imageResponse.bodyBytes,
                filename: 'site_image.png'),
          );
        } else {
          print('Failed to download image: ${imageResponse.statusCode}');
        }
      } catch (e) {
        print('Error downloading image: $e');
      }
    }

    try {
      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      print('Response status: ${response.statusCode}');
      print('Response body: ${responseBody.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Site "$siteName" added successfully')),
        );
        Navigator.pop(context, true); // Indicate that a site was added
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add site: ${responseBody.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print('Exception: $e');
    }
  }

  Future<String> _getAccessToken() async {
    String? token = await _secureStorage.read(key: 'accessToken');
    if (token == null || token.isEmpty) {
      print('Error: Access token not found or is empty.');
      throw Exception('Access token not found. Please log in again.');
    } else {
      print('[DEBUG] Access Token retrieved successfully: $token');
    }
    return token;
  }

  void showCreateSiteDialog({String? initialSiteName}) {
    showDialog(
      context: context,
      builder: (context) {
        return CreateSiteDialog(
          initialSiteName: initialSiteName,
          onSave: (String siteName, String siteType, File? imageFile) async {
            String url = '$apiUrl/sites/addSiteForUser';
            String token;

            try {
              token =
                  await _getAccessToken(); // Retrieve the user's access token
            } catch (e) {
              print('Error retrieving access token: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
              return;
            }

            Map<String, String> headers = {
              'Authorization': 'Bearer $token',
              // 'Content-Type': 'multipart/form-data', // Do not set this manually for multipart requests
            };

            var request = http.MultipartRequest('POST', Uri.parse(url));
            request.headers.addAll(headers);
            request.fields['siteName'] = siteName;
            request.fields['siteType'] = siteType.toUpperCase();

            if (imageFile != null) {
              request.files.add(
                await http.MultipartFile.fromPath('image', imageFile.path),
              );
            }

            try {
              var response = await request.send();
              var responseBody = await http.Response.fromStream(response);

              print('Response status: ${response.statusCode}');
              print('Response body: ${responseBody.body}');

              if (response.statusCode == 201) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Site "$siteName" added successfully')),
                );
                Navigator.pop(
                    context, true); // Close the dialog and indicate site added
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Failed to add site: ${responseBody.body}')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
              print('Exception: $e');
            }
          },
        );
      },
    );
  }

  void showComingSoonMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming Soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a New Site'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Return without adding a site
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryTitle('Default Sites'),
                    _buildSiteGrid(defaultSites, isDefaultCategory: true),
                    const SizedBox(height: 16.0),
                    _buildCategoryTitle('Other Sites'),
                    _buildSiteGrid(
                      [
                        SimpleSiteModel(siteName: 'Garden'),
                        SimpleSiteModel(siteName: 'Front Yard'),
                        SimpleSiteModel(siteName: 'Back Yard'),
                        SimpleSiteModel(siteName: 'Vegetable Garden Bed'),
                        SimpleSiteModel(siteName: 'Open Terrace'),
                        SimpleSiteModel(siteName: 'Open Balcony'),
                      ],
                      isDefaultCategory: false,
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Show the create site dialog
                          showCreateSiteDialog();
                        },
                        child: const Text(
                          'Create New Site',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSiteGrid(List<BaseSiteModel> sites,
      {required bool isDefaultCategory}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sites.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final site = sites[index];
        return GestureDetector(
          onTap: () {
            if (isDefaultCategory && site is SiteModel) {
              addSite(site);
            } else if (site is SimpleSiteModel) {
              showCreateSiteDialog(initialSiteName: site.siteName);
            } else {
              showComingSoonMessage();
            }
          },
          child: Column(
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8.0),
                  image: site is SiteModel && site.siteImage.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(site.siteImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: site is SiteModel && site.siteImage.isNotEmpty
                    ? null
                    : Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.green[300],
                      ),
              ),
              const SizedBox(height: 8.0),
              Text(
                site.siteName,
                style: const TextStyle(
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class CreateSiteDialog extends StatefulWidget {
  final Function(String siteName, String siteType, File? imageFile) onSave;
  final String? initialSiteName;

  const CreateSiteDialog(
      {super.key, required this.onSave, this.initialSiteName});

  @override
  _CreateSiteDialogState createState() => _CreateSiteDialogState();
}

class _CreateSiteDialogState extends State<CreateSiteDialog> {
  final _formKey = GlobalKey<FormState>();
  String _siteName = '';
  String _siteType = 'Indoor'; // Default selection
  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _siteName = widget.initialSiteName ?? '';
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isFormValid() {
    return _siteName.isNotEmpty && _siteType.isNotEmpty && _imageFile != null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Site'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _siteName,
                decoration: const InputDecoration(labelText: 'Site Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter site name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _siteName = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Site Type'),
              ListTile(
                title: const Text('Indoor'),
                leading: Radio<String>(
                  value: 'Indoor',
                  groupValue: _siteType,
                  onChanged: (value) {
                    setState(() {
                      _siteType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Outdoor'),
                leading: Radio<String>(
                  value: 'Outdoor',
                  groupValue: _siteType,
                  onChanged: (value) {
                    setState(() {
                      _siteType = value!;
                    });
                  },
                ),
              ),
              // ListTile(
              //   title: Text('Part Indoor/Outdoor'),
              //   leading: Radio<String>(
              //     value: 'IndoorOutdoor',
              //     groupValue: _siteType,
              //     onChanged: (value) {
              //       setState(() {
              //         _siteType = value!;
              //       });
              //     },
              //   ),
              // ),
              const SizedBox(height: 16.0),
              _imageFile == null
                  ? const Text('No image selected.')
                  : Image.file(_imageFile!),
              ElevatedButton(
                onPressed: _showImageSourceActionSheet,
                child: const Text('Pick Image'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_isSaving || !_isFormValid())
              ? null
              : () async {
                  setState(() {
                    _isSaving = true;
                  });
                  // try {
                  //   await widget.onSave(
                  //       _siteName, _siteType.toUpperCase(), _imageFile);
                  // } catch (e) {
                  //   print('Error in onSave: $e');
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(content: Text('Error: $e')),
                  //   );
                  // }
                  try {
                    print('Attempting to save custom site:');
                    print('Site Name: $_siteName');
                    print('Site Type: $_siteType');
                    print('Image File: ${_imageFile?.path}');

                    // Validate inputs before sending
                    if (_siteName.isEmpty) {
                      throw Exception('Site name cannot be empty');
                    }
                    if (_siteType.isEmpty) {
                      throw Exception('Site type must be selected');
                    }
                    if (_imageFile == null) {
                      throw Exception('An image must be selected');
                    }

                    await widget.onSave(
                        _siteName, _siteType.toUpperCase(), _imageFile);
                  } catch (e) {
                    print('Error in custom site creation: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create site: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    setState(() {
                      _isSaving = false;
                    });
                  }
                },
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}
