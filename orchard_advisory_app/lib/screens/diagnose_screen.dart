import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/diagnose_provider.dart';
import '../theme.dart';
import 'result_screen.dart';

class DiagnoseScreen extends StatefulWidget {
  const DiagnoseScreen({super.key});

  @override
  State<DiagnoseScreen> createState() => _DiagnoseScreenState();
}

class _DiagnoseScreenState extends State<DiagnoseScreen> {
  final _symptomController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    // Camera is unreliable on web/desktop browsers — prefer gallery there.
    if (kIsWeb && source == ImageSource.camera) {
      source = ImageSource.gallery;
    }
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      await context.read<DiagnoseProvider>().setImage(picked);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open the camera or gallery. On web, use Choose from Gallery.',
          ),
        ),
      );
    }
  }

  Future<void> _submit() async {
    final provider = context.read<DiagnoseProvider>();
    final result = await provider.submit();
    if (!mounted) return;
    if (result == null) {
      if (provider.submitError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.submitError!)),
        );
      }
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
    if (!mounted) return;
    // Form may have been cleared via "New Diagnosis".
    if (provider.symptomDescription.isEmpty && _symptomController.text.isNotEmpty) {
      _symptomController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiagnoseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orchard Advisory'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              'What is wrong with your tree?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Describe symptoms or add a photo of the leaf, fruit, or branch.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: OrchardColors.muted,
                  ),
            ),
            const SizedBox(height: 24),
            Text('Crop type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey('crop-${provider.cropType}'),
              initialValue: provider.cropType,
              items: DiagnoseProvider.cropOptions
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c[0].toUpperCase() + c.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: provider.isSubmitting
                  ? null
                  : (v) {
                      if (v != null) provider.setCropType(v);
                    },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.eco_outlined),
              ),
            ),
            const SizedBox(height: 18),
            Text('Month', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey('month-${provider.month}'),
              initialValue: provider.month,
              items: DiagnoseProvider.monthOptions
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: provider.isSubmitting
                  ? null
                  : (v) {
                      if (v != null) provider.setMonth(v);
                    },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.calendar_month_outlined),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Describe what you\'re seeing',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _symptomController,
              enabled: !provider.isSubmitting,
              minLines: 4,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              onChanged: provider.setSymptomDescription,
              decoration: const InputDecoration(
                hintText:
                    'Example: Leaves have small brown-purple spots after rainy weather…',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Icon(Icons.spa_outlined),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Photo (optional)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (provider.imageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.memory(
                    provider.imageBytes!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: provider.isSubmitting
                          ? null
                          : () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(kIsWeb ? 'Change photo' : 'Retake / change'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: provider.isSubmitting ? null : provider.clearImage,
                      icon: const Icon(Icons.close),
                      label: const Text('Remove'),
                    ),
                  ),
                ],
              ),
            ] else
              Row(
                children: [
                  if (!kIsWeb) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: provider.isSubmitting
                            ? null
                            : () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 22),
                        label: const Text('Take Photo'),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: provider.isSubmitting
                          ? null
                          : () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined, size: 22),
                      label: Text(kIsWeb ? 'Upload Photo' : 'Gallery'),
                    ),
                  ),
                ],
              ),
            if (provider.formError != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: OrchardColors.urgencyHigh.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: OrchardColors.urgencyHigh.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: OrchardColors.urgencyHigh),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.formError!,
                        style: const TextStyle(
                          color: OrchardColors.urgencyHigh,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: provider.isSubmitting ? null : _submit,
              child: provider.isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.health_and_safety_outlined),
                        SizedBox(width: 10),
                        Text('Get Diagnosis'),
                      ],
                    ),
            ),
            if (provider.isSubmitting) ...[
              const SizedBox(height: 12),
              Text(
                'Analyzing symptoms — this can take a few seconds…',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
