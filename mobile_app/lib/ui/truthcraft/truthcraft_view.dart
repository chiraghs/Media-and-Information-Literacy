import 'package:flutter/material.dart';
import '../widgets/accessible_button.dart';
import '../widgets/scalable_text.dart';

class TruthCraftView extends StatefulWidget {
  const TruthCraftView({Key? key}) : super(key: key);

  @override
  State<TruthCraftView> createState() => _TruthCraftViewState();
}

class _TruthCraftViewState extends State<TruthCraftView> {
  String _currentStep = 'intro';
  int _score = 0;
  String _feedback = "";

  void _chooseAction(String action) {
    setState(() {
      if (_currentStep == 'intro') {
        if (action == 'verify') {
          _currentStep = 'deepfake_puzzle';
          _score += 10;
        } else {
          _currentStep = 'rash_post';
        }
      } else if (_currentStep == 'deepfake_puzzle') {
        if (action == 'B') {
          _score += 25;
          _feedback = "Correct! Profile B has multiple visual glitches typical of generative AI headshots. You've earned 25 points.";
        } else {
          _feedback = "Incorrect. Profile B had structural distortions. You still proceed to gather data.";
        }
        _currentStep = 'exif_puzzle';
      } else if (_currentStep == 'exif_puzzle') {
        if (action == 'photoshop') {
          _score += 25;
          _feedback = "Correct! The photo timestamp is from 2024 (2 years old) and contains edit metadata signatures.";
        } else {
          _feedback = "Incorrect. The metadata stamp confirms this was an edited file from 2024.";
        }
        _currentStep = 'conclusion';
      }
    });
  }

  void _reset() {
    setState(() {
      _currentStep = 'intro';
      _score = 0;
      _feedback = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: ScalableText("TruthCraft Disinformation Sandbox", style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ScalableText("Active Score: $_score PTS", style: theme.textTheme.titleLarge),
                ScalableText("Step: ${_getStepName()}", style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _getProgressValue(),
              backgroundColor: theme.colorScheme.outline,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),

            // Content Panel
            Expanded(
              child: Card(
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_feedback.isNotEmpty) ...[
                        Icon(Icons.check_circle_outline, color: theme.colorScheme.secondary, size: 40),
                        const SizedBox(height: 8),
                        ScalableText(
                          _feedback,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),
                      ],
                      _buildStepContent(theme),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepName() {
    switch (_currentStep) {
      case 'intro': return "1/3 Investigation";
      case 'deepfake_puzzle': return "2/3 Deepfake Spotter";
      case 'exif_puzzle': return "3/3 Metadata Forensic";
      case 'rash_post': return "Investigation Failed";
      case 'conclusion': return "Completed";
      default: return "";
    }
  }

  double _getProgressValue() {
    switch (_currentStep) {
      case 'intro': return 0.2;
      case 'deepfake_puzzle': return 0.5;
      case 'exif_puzzle': return 0.8;
      case 'conclusion': return 1.0;
      default: return 0.0;
    }
  }

  Widget _buildStepContent(ThemeData theme) {
    if (_currentStep == 'intro') {
      return Column(
        children: [
          ScalableText(
            "Maya, a student journalist, receives a message containing a video of the college director apparently canceling tech scholarships. What should she do?",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          AccessibleButton(
            label: "Share video immediately",
            isPrimary: false,
            onPressed: () => _chooseAction('share'),
          ),
          const SizedBox(height: 8),
          AccessibleButton(
            label: "Stop and verify credentials",
            onPressed: () => _chooseAction('verify'),
          ),
        ],
      );
    } else if (_currentStep == 'rash_post') {
      return Column(
        children: [
          ScalableText(
            "You posted it immediately. The video turned out to be a deepfake. Your credibility as a student editor is ruined.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          AccessibleButton(
            label: "Restart Sandbox",
            onPressed: _reset,
          ),
        ],
      );
    } else if (_currentStep == 'deepfake_puzzle') {
      return Column(
        children: [
          ScalableText(
            "Analyze the sender's profile picture. Which picture contains AI-generated details?",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AccessibleButton(
                label: "Profile A (Regular)",
                isPrimary: false,
                onPressed: () => _chooseAction('A'),
              ),
              const SizedBox(width: 12),
              AccessibleButton(
                label: "Profile B (AI Artifacts)",
                onPressed: () => _chooseAction('B'),
              ),
            ],
          ),
        ],
      );
    } else if (_currentStep == 'exif_puzzle') {
      return Column(
        children: [
          ScalableText(
            "Audit the EXIF metadata of the attached protest image. You find a modification date from 2024 and Photoshop headers.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          AccessibleButton(
            label: "Ignore timestamp, post image",
            isPrimary: false,
            onPressed: () => _chooseAction('ignore'),
          ),
          const SizedBox(height: 8),
          AccessibleButton(
            label: "Flag Photoshop edits",
            onPressed: () => _chooseAction('photoshop'),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          ScalableText(
            "Congratulations! You successfully isolated the deepfake profile and verified the metadata, preserving student trust. Final score: $_score PTS.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          AccessibleButton(
            label: "Earn Certificate & Restart",
            onPressed: _reset,
          ),
        ],
      );
    }
  }
}
