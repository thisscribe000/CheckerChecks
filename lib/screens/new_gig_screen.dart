import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';
import 'build_checklist_screen.dart';

class NewGigScreen extends StatefulWidget {
  const NewGigScreen({super.key});

  @override
  State<NewGigScreen> createState() => _NewGigScreenState();
}

class _NewGigScreenState extends State<NewGigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  String _selectedType = 'Photography';
  String _selectedSize = 'Medium';
  String _selectedLocation = 'Indoor';
  DateTime? _selectedDate;

  static const _types = [
    {'name': 'Photography', 'icon': Icons.photo_camera_outlined},
    {'name': 'Video', 'icon': Icons.videocam_outlined},
    {'name': 'Audio', 'icon': Icons.mic_none_outlined},
    {'name': 'Livestream', 'icon': Icons.wifi_tethering_outlined},
    {'name': 'Event', 'icon': Icons.event_outlined},
    {'name': 'Other', 'icon': Icons.work_outline},
  ];

  static const _sizes = ['Small', 'Medium', 'Large'];
  static const _locations = ['Indoor', 'Outdoor', 'Both'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: StitchTheme.primary,
            onPrimary: StitchTheme.onPrimary,
            surface: StitchTheme.surfaceContainerLowest,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String get _dateLabel {
    if (_selectedDate == null) return 'Select date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    if (d == today) return 'Today';
    if (d == today.add(const Duration(days: 1))) return 'Tomorrow';
    return DateFormat('EEE, d MMM yyyy').format(_selectedDate!);
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<AppProvider>(context, listen: false);
    final dateStr = _selectedDate != null
        ? DateFormat('EEE d MMM').format(_selectedDate!)
        : 'Upcoming';
    final newGig = provider.createGig(
      name: _nameCtrl.text.trim(),
      type: _selectedType,
      size: _selectedSize,
      location: _selectedLocation,
      date: dateStr,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => BuildChecklistScreen(gig: newGig)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Gig')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What are you preparing for?',
                  style: StitchTheme.headlineLg(context)),
              const SizedBox(height: 4),
              Text('Set the parameters of your next project.',
                  style: StitchTheme.bodyLg(context)),
              const SizedBox(height: 28),

              // ── Gig name ────────────────────────────────────────────────
              Text('GIG NAME', style: StitchTheme.labelCaps(context)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                style: StitchTheme.bodyLg(context)
                    .copyWith(color: StitchTheme.primary),
                textCapitalization: TextCapitalization.words,
                decoration: _inputDec('e.g. Wedding Shoot'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a gig name' : null,
              ),
              const SizedBox(height: 24),

              // ── Gig type ────────────────────────────────────────────────
              Text('GIG TYPE', style: StitchTheme.labelCaps(context)),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.3,
                ),
                itemCount: _types.length,
                itemBuilder: (_, i) {
                  final t = _types[i] as Map<String, dynamic>;
                  final name = t['name'] as String;
                  final selected = _selectedType == name;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = name),
                    child: Container(
                      decoration: selected
                          ? StitchTheme.cardDecorationActive
                          : StitchTheme.cardDecoration,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(t['icon'] as IconData,
                              size: 22,
                              color: selected
                                  ? StitchTheme.primary
                                  : StitchTheme.onSurfaceVariant),
                          const SizedBox(height: 5),
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            style: StitchTheme.labelCaps(context).copyWith(
                              color: selected
                                  ? StitchTheme.primary
                                  : StitchTheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── Date ────────────────────────────────────────────────────
              Text('DATE', style: StitchTheme.labelCaps(context)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: StitchTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _selectedDate != null
                          ? StitchTheme.primary
                          : StitchTheme.outlineVariant,
                      width: _selectedDate != null ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: _selectedDate != null
                            ? StitchTheme.primary
                            : StitchTheme.outline,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _dateLabel,
                        style: StitchTheme.bodyLg(context).copyWith(
                          color: _selectedDate != null
                              ? StitchTheme.primary
                              : StitchTheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Size ────────────────────────────────────────────────────
              Text('SIZE', style: StitchTheme.labelCaps(context)),
              const SizedBox(height: 8),
              Row(
                children: _sizes.map((s) {
                  final selected = _selectedSize == s;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSize = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: selected
                              ? BoxDecoration(
                                  color: StitchTheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                )
                              : StitchTheme.cardDecoration,
                          child: Text(
                            s,
                            textAlign: TextAlign.center,
                            style: StitchTheme.labelCaps(context).copyWith(
                              color: selected
                                  ? StitchTheme.onPrimary
                                  : StitchTheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Location ────────────────────────────────────────────────
              Text('LOCATION', style: StitchTheme.labelCaps(context)),
              const SizedBox(height: 8),
              Row(
                children: _locations.map((loc) {
                  final selected = _selectedLocation == loc;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedLocation = loc),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: selected
                              ? BoxDecoration(
                                  color: StitchTheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                )
                              : StitchTheme.cardDecoration,
                          child: Text(
                            loc,
                            textAlign: TextAlign.center,
                            style: StitchTheme.labelCaps(context).copyWith(
                              color: selected
                                  ? StitchTheme.onPrimary
                                  : StitchTheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),

              // ── CTA ─────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StitchTheme.primary,
                    foregroundColor: StitchTheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(
                    'Continue',
                    style: StitchTheme.headlineMd(context)
                        .copyWith(color: StitchTheme.onPrimary, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: StitchTheme.outline),
        filled: true,
        fillColor: StitchTheme.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StitchTheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide:
              const BorderSide(color: StitchTheme.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StitchTheme.outlineVariant),
        ),
      );
}
