import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/profile_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/responsive_scaffold.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _regController;
  late TextEditingController _collegeController;
  late TextEditingController _branchController;
  late TextEditingController _cgpaController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  late TextEditingController _skillInputController;

  String _preferredRole = "Software Developer";
  int _semester = 8;
  List<String> _skillsList = [];

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _regController = TextEditingController();
    _collegeController = TextEditingController();
    _branchController = TextEditingController();
    _cgpaController = TextEditingController();
    _linkedinController = TextEditingController();
    _githubController = TextEditingController();
    _skillInputController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _regController.dispose();
    _collegeController.dispose();
    _branchController.dispose();
    _cgpaController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _initFormValues(StudentProfile profile) {
    if (_initialized) return;
    _nameController.text = profile.fullName;
    _phoneController.text = profile.phoneNumber;
    _regController.text = profile.registerNumber;
    _collegeController.text = profile.collegeName;
    _branchController.text = profile.branch;
    _cgpaController.text = profile.cgpa > 0 ? profile.cgpa.toString() : "";
    _linkedinController.text = profile.linkedinUrl;
    _githubController.text = profile.githubUrl;
    _preferredRole = profile.preferredRole;
    _semester = profile.semester;
    _skillsList = List<String>.from(profile.skills);
    _initialized = true;
  }

  void _addSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isNotEmpty && !_skillsList.contains(skill)) {
      setState(() {
        _skillsList.add(skill);
        _skillInputController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skillsList.remove(skill);
    });
  }

  void _selectProfileImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        final name = result.files.single.name;
        if (bytes != null) {
          ref.read(profileProvider.notifier).uploadProfileImage(
            bytes: bytes,
            fileName: name,
          );
        } else {
          throw Exception("Could not read image file bytes.");
        }
      } else {
        final path = result.files.single.path;
        final name = result.files.single.name;
        if (path != null) {
          final file = File(path);
          ref.read(profileProvider.notifier).uploadProfileImage(
            file: file,
            fileName: name,
          );
        } else {
          throw Exception("Could not retrieve image file path.");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to select image: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _saveProfile(StudentProfile currentProfile) async {
    if (_formKey.currentState!.validate()) {
      final cgpaValue = double.tryParse(_cgpaController.text) ?? 0.0;
      
      final updated = currentProfile.copyWith(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        registerNumber: _regController.text.trim(),
        collegeName: _collegeController.text.trim(),
        branch: _branchController.text.trim(),
        cgpa: cgpaValue,
        semester: _semester,
        preferredRole: _preferredRole,
        linkedinUrl: _linkedinController.text.trim(),
        githubUrl: _githubController.text.trim(),
        skills: _skillsList,
      );

      await ref.read(profileProvider.notifier).updateProfile(updated);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile details saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    if (profile != null) {
      _initFormValues(profile);
    }

    final jobRoles = [
      "Software Developer",
      "Flutter Developer",
      "Backend Developer",
      "Full Stack Developer",
      "Data Analyst"
    ];

    return ResponsiveScaffold(
      title: "Student Profile",
      body: profileState.isLoading || profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Avatar Block
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    backgroundImage: profile.profileImageUrl.isNotEmpty
                                        ? NetworkImage(profile.profileImageUrl)
                                        : null,
                                    child: profile.profileImageUrl.isEmpty
                                        ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: _selectProfileImage,
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        child: const Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                profile.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty ? "Enter your full name" : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty ? "Enter phone number" : null,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      "Academic Details",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _regController,
                      decoration: const InputDecoration(
                        labelText: "Register Number",
                        prefixIcon: Icon(Icons.numbers_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty ? "Enter college register number" : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _collegeController,
                      decoration: const InputDecoration(
                        labelText: "College Name",
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty ? "Enter college name" : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _branchController,
                            decoration: const InputDecoration(
                              labelText: "Branch",
                              prefixIcon: Icon(Icons.class_outlined),
                            ),
                            validator: (value) => value == null || value.isEmpty ? "Required" : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _cgpaController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: "CGPA",
                              prefixIcon: Icon(Icons.grade_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Required";
                              final cgpa = double.tryParse(value);
                              if (cgpa == null || cgpa < 0 || cgpa > 10) return "0.0 - 10.0";
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      value: _semester,
                      decoration: const InputDecoration(
                        labelText: "Current Semester",
                        prefixIcon: Icon(Icons.calendar_view_week_outlined),
                      ),
                      items: List.generate(8, (i) => i + 1).map((sem) {
                        return DropdownMenuItem<int>(
                          value: sem,
                          child: Text("Semester $sem"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _semester = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    Text(
                      "Target Placement Preferences",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _preferredRole,
                      decoration: const InputDecoration(
                        labelText: "Preferred Job Role",
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                      items: jobRoles.map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _preferredRole = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    Text(
                      "Skills & Portfolio Links",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _skillInputController,
                            decoration: const InputDecoration(
                              labelText: "Add Skill tag",
                              prefixIcon: Icon(Icons.bolt_outlined),
                            ),
                            onFieldSubmitted: (v) => _addSkill(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.add_circle, size: 40, color: Theme.of(context).colorScheme.primary),
                          onPressed: _addSkill,
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _skillsList.map((skill) {
                        return Chip(
                          label: Text(skill),
                          onDeleted: () => _removeSkill(skill),
                          deleteIconColor: Colors.redAccent,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          labelStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _linkedinController,
                      decoration: const InputDecoration(
                        labelText: "LinkedIn Profile URL",
                        prefixIcon: Icon(Icons.link_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _githubController,
                      decoration: const InputDecoration(
                        labelText: "GitHub Profile URL",
                        prefixIcon: Icon(Icons.code_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () => _saveProfile(profile),
                      child: const Text("SAVE CHANGES"),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}
