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
      title: "My Profile",
      body: profileState.isLoading || profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Title Section
                        Text(
                          "Profile Settings",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Update your personal info, academic details, and career preferences to customize your preparation.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Snapshot Profile Section (Avatar & ID Card)
                        _buildSnapshotSection(context, profile),
                        const SizedBox(height: 28),

                        // Personal Information Section
                        _buildSectionHeader(context, "Personal Information"),
                        const SizedBox(height: 16),
                        _buildResponsiveRow(
                          context,
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: "Full Name",
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (value) => value == null || value.isEmpty ? "Enter your full name" : null,
                          ),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: "Phone Number",
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (value) => value == null || value.isEmpty ? "Enter phone number" : null,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Academic Details Section
                        _buildSectionHeader(context, "Academic Details"),
                        const SizedBox(height: 16),
                        _buildResponsiveRow(
                          context,
                          TextFormField(
                            controller: _regController,
                            decoration: const InputDecoration(
                              labelText: "Register Number",
                              prefixIcon: Icon(Icons.numbers_outlined),
                            ),
                            validator: (value) => value == null || value.isEmpty ? "Enter college register number" : null,
                          ),
                          TextFormField(
                            controller: _collegeController,
                            decoration: const InputDecoration(
                              labelText: "College Name",
                              prefixIcon: Icon(Icons.school_outlined),
                            ),
                            validator: (value) => value == null || value.isEmpty ? "Enter college name" : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildResponsiveThreeRow(
                          context,
                          TextFormField(
                            controller: _branchController,
                            decoration: const InputDecoration(
                              labelText: "Branch / Stream",
                              prefixIcon: Icon(Icons.class_outlined),
                            ),
                            validator: (value) => value == null || value.isEmpty ? "Required" : null,
                          ),
                          TextFormField(
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
                          DropdownButtonFormField<int>(
                            value: _semester,
                            decoration: const InputDecoration(
                              labelText: "Semester",
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
                        ),
                        const SizedBox(height: 12),

                        // Career & Skills Section
                        _buildSectionHeader(context, "Career & Skills"),
                        const SizedBox(height: 16),
                        _buildResponsiveRow(
                          context,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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
                                    icon: Icon(Icons.add_circle, size: 44, color: Theme.of(context).colorScheme.primary),
                                    onPressed: _addSkill,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  )
                                ],
                              ),
                              if (_skillsList.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _skillsList.map((skill) {
                                    return Chip(
                                      label: Text(skill),
                                      onDeleted: () => _removeSkill(skill),
                                      deleteIconColor: Colors.redAccent,
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                      labelStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
                                      side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Social Links Section
                        _buildSectionHeader(context, "Social & Portfolio Links"),
                        const SizedBox(height: 16),
                        _buildResponsiveRow(
                          context,
                          TextFormField(
                            controller: _linkedinController,
                            decoration: const InputDecoration(
                              labelText: "LinkedIn Profile URL",
                              prefixIcon: Icon(Icons.link_outlined),
                            ),
                          ),
                          TextFormField(
                            controller: _githubController,
                            decoration: const InputDecoration(
                              labelText: "GitHub Profile URL",
                              prefixIcon: Icon(Icons.code_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Save Button (Premium Design)
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size(double.infinity, 54),
                            ),
                            onPressed: () => _saveProfile(profile),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(),
                                const Text(
                                  "SAVE CHANGES",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveRow(BuildContext context, Widget child1, Widget child2) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;
    if (isCompact) {
      return Column(
        children: [
          child1,
          const SizedBox(height: 16),
          child2,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child1),
          const SizedBox(width: 16),
          Expanded(child: child2),
        ],
      );
    }
  }

  Widget _buildResponsiveThreeRow(BuildContext context, Widget child1, Widget child2, Widget child3) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;
    if (isCompact) {
      return Column(
        children: [
          child1,
          const SizedBox(height: 16),
          child2,
          const SizedBox(height: 16),
          child3,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: child1),
          const SizedBox(width: 16),
          Expanded(child: child2),
          const SizedBox(width: 16),
          Expanded(child: child3),
        ],
      );
    }
  }

  Widget _buildSnapshotSection(BuildContext context, StudentProfile profile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 650;
    
    if (isCompact) {
      return Column(
        children: [
          _buildAvatarBlock(context, profile),
          const SizedBox(height: 20),
          _buildIdCard(context, profile),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: _buildAvatarBlock(context, profile)),
          const SizedBox(width: 24),
          Expanded(flex: 5, child: _buildIdCard(context, profile)),
        ],
      );
    }
  }

  Widget _buildAvatarBlock(BuildContext context, StudentProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  backgroundImage: profile.profileImageUrl.isNotEmpty
                      ? NetworkImage(profile.profileImageUrl)
                      : null,
                  child: profile.profileImageUrl.isEmpty
                      ? Icon(Icons.person, size: 46, color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _selectProfileImage,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            profile.fullName.isNotEmpty ? profile.fullName : "Your Name",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(120, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _selectProfileImage,
            icon: const Icon(Icons.photo_library_outlined, size: 14),
            label: const Text("Edit Photo", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildIdCard(BuildContext context, StudentProfile profile) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background decorative glow shapes
          Positioned(
            right: -30,
            top: -30,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.06),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "ANHIRE STUDENT PROFILE CARD",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF34D399).withOpacity(0.4), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34D399),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "ACTIVE",
                            style: TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Middle Profile / Info Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName.isNotEmpty ? profile.fullName.toUpperCase() : "STUDENT NAME",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.registerNumber.isNotEmpty ? profile.registerNumber : "REG: N/A",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.branch.isNotEmpty ? profile.branch : "BRANCH: N/A",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Glassmorphic CGPA Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile.cgpa > 0 ? profile.cgpa.toStringAsFixed(2) : "0.0",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "CGPA",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

