import 'package:flutter/material.dart';
import '../widgets/scalable_text.dart';

class InitiativeInfoView extends StatelessWidget {
  const InitiativeInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final papers = [
      {
        'title': 'Civic Media Ecologies',
        'citation': 'Nichols & LeBlanc (2021)',
        'description': 'Critiques representational literacy in favor of ecological mapping, examining platform layers (The Stack) and digital extraction. Backs our metadata and network tracking tools.',
        'icon': Icons.public,
      },
      {
        'title': 'Cross-Cultural Prebunking',
        'citation': 'Roozenbeek, van der Linden & Nygren (2020)',
        'description': 'A study of 5,061 participants proving that active gameplay interventions boost psychological immunity against fake news across diverse languages. Backs our TruthCraft layout.',
        'icon': Icons.language,
      },
      {
        'title': 'Lateral Reading & Heuristics',
        'citation': 'Wineburg & McGrew (2019)',
        'description': 'Demonstrates that expert fact-checkers evaluate unfamiliar sources by opening new tabs to cross-reference claims (lateral reading) rather than analyzing visual design elements.',
        'icon': Icons.search,
      },
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: ScalableText("Initiative Info & Research Library", style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.background,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: papers.length,
        itemBuilder: (context, index) {
          final paper = papers[index];
          return Card(
            color: theme.colorScheme.surface,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    paper['icon'] as IconData,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScalableText(
                          paper['title'] as String,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        ScalableText(
                          paper['citation'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ScalableText(
                          paper['description'] as String,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
