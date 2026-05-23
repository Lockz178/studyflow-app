import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_contact.dart';
import '../validators/feedback_validator.dart';

class HelpFeedbackScreen extends StatefulWidget {
  const HelpFeedbackScreen({super.key});

  @override
  State<HelpFeedbackScreen> createState() => _HelpFeedbackScreenState();
}

class _HelpFeedbackScreenState extends State<HelpFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  static String _encodeQuery(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  Future<void> _openMailto(String body) async {
    final uri = Uri.parse(
      'mailto:$kSupportEmail?${_encodeQuery({'subject': '[StudyFlow] Feedback', 'body': body})}',
    );

    setState(() => _sending = true);
    try {
      final launched = await launchUrl(uri);
      if (!mounted) return;
      if (!launched) {
        await Clipboard.setData(const ClipboardData(text: kSupportEmail));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open mail app. Email copied to clipboard.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        await Clipboard.setData(const ClipboardData(text: kSupportEmail));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Open any email app and write to the address copied to clipboard.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _submitFeedback() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _openMailto(_messageController.text.trim());
  }

  Future<void> _openRepo() async {
    final uri = Uri.parse(kRepoWebUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SelectableText(kRepoWebUrl),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _copyEmail() async {
    await Clipboard.setData(const ClipboardData(text: kSupportEmail));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email copied'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final surfaceSoft = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF161F36)
        : const Color(0xFFF8FAFC);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Help & Feedback',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              'Quick answers, shortcuts, and a way to send feedback.',
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            _SectionTitle(text: 'Getting started', color: textPrimary),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surfaceSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bullet(
                    text:
                        'Dashboard: calendar, deadlines, and a snapshot of progress.',
                    secondary: textSecondary,
                  ),
                  _Bullet(
                    text:
                        'Study Planner: tap + New plan for topic, subject, and days.',
                    secondary: textSecondary,
                  ),
                  _Bullet(
                    text:
                        'Tips library (drawer): scroll for more study tips (pagination).',
                    secondary: textSecondary,
                  ),
                  _Bullet(
                    text:
                        'Settings: theme (device / light / dark) and reminders toggle.',
                    secondary: textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _SectionTitle(text: 'FAQ', color: textPrimary),
            const SizedBox(height: 10),
            _FaqTile(
              question: 'What do "Suggested focus" and "Most urgent" mean?',
              answer:
                  'Suggested focus is simply your first active plan - a sensible default for "what should I open next?". '
                  'Most urgent looks at active plans only and picks the one with the lowest progress bar, '
                  'to highlight where you may be falling behind.',
            ),
            _FaqTile(
              question: 'Where is my data stored?',
              answer:
                  'Seed subjects, tips, and deadlines come from the bundled JSON asset. '
                  'Study plans you create live in memory while the app runs (they reset when the app process is killed). '
                  'Favourites and settings use SharedPreferences on this device.',
            ),
            _FaqTile(
              question: 'How do Premium templates work?',
              answer:
                  'Template cards are gated behind Premium - tap upgrade on the planner to see the flow. '
                  'Your free plans still work fully with + New plan.',
            ),
            const SizedBox(height: 22),
            _SectionTitle(text: 'Contact', color: textPrimary),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surfaceSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    kSupportEmail,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _copyEmail,
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copy email'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _openRepo,
                        icon: const Icon(Icons.code_rounded, size: 18),
                        label: const Text('Open GitHub'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _SectionTitle(text: 'Send feedback', color: textPrimary),
            const SizedBox(height: 8),
            Text(
              'Describe a bug or idea (validation runs before your mail app opens).',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
              minLines: 5,
              maxLines: 12,
              decoration: InputDecoration(
                hintText: 'What happened? What did you expect?',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              validator: (value) => validateFeedbackMessage(value ?? ''),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _sending ? null : _submitFeedback,
              icon: const Icon(Icons.send_rounded),
              label: Text(_sending ? 'Opening...' : 'Send with email app'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionTitle({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  final Color secondary;

  const _Bullet({required this.text, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF8B5CF6)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(height: 1.45, color: secondary)),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0F162A)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: TextStyle(
                  height: 1.45,
                  color: textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
