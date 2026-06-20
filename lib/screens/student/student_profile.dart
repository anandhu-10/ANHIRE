import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/profile_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_drawer.dart';

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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      ref.read(profileProvider.notifier).uploadProfileImage(file);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
      ),
      drawer: const AppDrawer(),
      body: profileState.isLoading || profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
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
                                backgroundColor: Colors.blue.shade100,
                                backgroundImage: profile.profileImageUrl.isNotEmpty
                                    ? NetworkImage(profile.profileImageUrl)
                                    : null,
                                child: profile.profileImageUrl.isEmpty
                                    ? const Icon(Icons.person, size: 50, color: Color(0xFF2563EB))
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _selectProfileImage,
                                  child: const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Color(0xFF2563EB),
                                    child: Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.email,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Personal Information",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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

                    const Text(
                      "Academic Details",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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

                    const Text(
                      "Target Placement Preferences",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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

                    const Text(
                      "Skills & Portfolio Links",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 12),

                    // Skill Inputs
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
                          icon: const Icon(Icons.add_circle, size: 40, color: Color(0xFF2563EB)),
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
                          backgroundColor: Colors.blue.shade50,
                          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
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
    );
  }
}
