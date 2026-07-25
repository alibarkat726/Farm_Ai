import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/diagnosis_result.dart';
import '../providers/diagnose_provider.dart';
import '../theme.dart';
import '../widgets/badges.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final DiagnosisResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Row(
              children: [
                Text('Urgency', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                UrgencyBadge(urgency: result.urgency, large: true),
              ],
            ),
            if (result.consultExtensionOffice) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OrchardColors.calloutBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: OrchardColors.calloutBorder),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.support_agent, color: OrchardColors.apricot, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Consider consulting your local agriculture extension office',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: OrchardColors.ink,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Likely Causes',
              icon: Icons.biotech_outlined,
            ),
            const SizedBox(height: 12),
            if (result.likelyCauses.isEmpty)
              const Text('No clear match found in the knowledge base.')
            else
              ...result.likelyCauses.map(
                (cause) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cause.commonName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ConfidenceBadge(confidence: cause.confidence),
                          const SizedBox(height: 10),
                          Text(
                            cause.reasoning,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const SectionHeader(
              title: 'Recommended Action',
              icon: Icons.lightbulb_outline,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OrchardColors.leafGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: OrchardColors.leafGreen.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                result.recommendedAction,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Treatment Steps',
              icon: Icons.checklist_rtl,
            ),
            const SizedBox(height: 12),
            if (result.treatmentSteps.isEmpty)
              const Text('No treatment steps returned.')
            else
              ...List.generate(result.treatmentSteps.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: OrchardColors.leafGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          result.treatmentSteps[index],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 28),
            Text(
              result.disclaimer,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DiagnoseProvider>().resetForm();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('New Diagnosis'),
            ),
          ],
        ),
      ),
    );
  }
}
