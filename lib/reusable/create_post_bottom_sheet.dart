import 'package:flutter/material.dart';
import '../base/app_colors.dart';
import '../reusable/cc_buttons.dart';
import '../reusable/cc_text_fields.dart';

class CreatePostBottomSheet extends StatefulWidget {
  const CreatePostBottomSheet({super.key});

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final _contentController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _handlePost() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() => _isPosting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Create Post',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CCTextField(
            controller: _contentController,
            hint: "What's happening on campus?",
            maxLines: 5,
            minLines: 3,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.image_outlined, color: AppColors.primary),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.poll_outlined, color: AppColors.primary),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CCPrimaryButton(
            label: 'Post',
            onPressed: _handlePost,
            isLoading: _isPosting,
          ),
        ],
      ),
    );
  }
}
