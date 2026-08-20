import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/core/providers/settings_provider.dart';
import 'package:dashboard/core/models/admin_settings_model.dart';

class _C {
  static const primary = Color(0xFF6C5CE7);
  static const success = Color(0xFF00E676);
  static const warning = Color(0xFFFFAB00);
  static const card = Color(0xFF1E1E36);
  static const border = Color(0xFF2A2A45);
  static const textPrimary = Color(0xFFF0F0F5);
  static const textSecondary = Color(0xFF9A9ABF);
  static const textMuted = Color(0xFF6B6B8D);
  static const surface = Color(0xFF1A1A2E);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AdminSettingsModel _draft;
  late TextEditingController _systemPromptC;
  late TextEditingController _dailyLimitC;
  late TextEditingController _maxLengthC;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SettingsProvider>();
    provider.fetchSettings().then((_) {
      if (mounted) _syncDraft(provider.settings);
    });
    _draft = provider.settings;
    _systemPromptC = TextEditingController(text: _draft.systemPrompt);
    _dailyLimitC = TextEditingController(text: '${_draft.dailyMessageLimit}');
    _maxLengthC = TextEditingController(text: '${_draft.maxMessageLength}');
  }

  void _syncDraft(AdminSettingsModel settings) {
    setState(() {
      _draft = settings;
      _systemPromptC.text = settings.systemPrompt;
      _dailyLimitC.text = '${settings.dailyMessageLimit}';
      _maxLengthC.text = '${settings.maxMessageLength}';
    });
  }

  @override
  void dispose() {
    _systemPromptC.dispose();
    _dailyLimitC.dispose();
    _maxLengthC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = _draft.copyWith(
      systemPrompt: _systemPromptC.text.trim(),
      dailyMessageLimit: int.tryParse(_dailyLimitC.text) ?? 50,
      maxMessageLength: int.tryParse(_maxLengthC.text) ?? 2000,
    );

    await context.read<SettingsProvider>().saveSettings(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ الإعدادات بنجاح ✓'),
          backgroundColor: _C.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: _C.primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── AI Models ──
          _SectionCard(
            title: 'نماذج الذكاء الاصطناعي',
            icon: Icons.smart_toy_rounded,
            children: [
              const Text('اختر النماذج المفعّلة للطلاب:', style: TextStyle(color: _C.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: ['deepseek', 'gemini', 'claude', 'gpt'].map((model) {
                  final isEnabled = _draft.aiModelsEnabled[model] ?? false;
                  final color = _modelColor(model);
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        final updated = Map<String, bool>.from(_draft.aiModelsEnabled);
                        updated[model] = !isEnabled;
                        _draft = _draft.copyWith(aiModelsEnabled: updated);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: isEnabled ? color.withValues(alpha: 0.15) : const Color(0xFF252542),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isEnabled ? color.withValues(alpha: 0.5) : _C.border, width: isEnabled ? 2 : 1),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(isEnabled ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: isEnabled ? color : _C.textMuted),
                        const SizedBox(width: 8),
                        Text(model.toUpperCase(), style: TextStyle(color: isEnabled ? color : _C.textMuted, fontWeight: FontWeight.bold, fontSize: 14)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(children: [
                const Text('النموذج الافتراضي:', style: TextStyle(color: _C.textSecondary, fontSize: 13)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _draft.defaultModel,
                  dropdownColor: _C.surface,
                  items: ['deepseek', 'gemini', 'claude', 'gpt']
                      .where((m) => _draft.aiModelsEnabled[m] == true)
                      .map((m) => DropdownMenuItem(value: m, child: Text(m.toUpperCase())))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _draft = _draft.copyWith(defaultModel: v));
                  },
                ),
              ]),
            ],
          ),
          const SizedBox(height: 24),

          // ── Chat Controls ──
          _SectionCard(
            title: 'إعدادات الشات بوت',
            icon: Icons.chat_bubble_outline,
            children: [
              TextFormField(controller: _systemPromptC, decoration: const InputDecoration(labelText: 'System Prompt'), maxLines: 3),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TextFormField(controller: _dailyLimitC, decoration: const InputDecoration(labelText: 'حد الرسائل اليومي'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _maxLengthC, decoration: const InputDecoration(labelText: 'الحد الأقصى لطول الرسالة'), keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('تفعيل المرفقات'),
                subtitle: const Text('السماح للطلاب بإرسال ملفات وصور في الشات', style: TextStyle(fontSize: 12)),
                value: _draft.attachmentsEnabled,
                activeThumbColor: _C.primary,
                onChanged: (v) => setState(() => _draft = _draft.copyWith(attachmentsEnabled: v)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Maintenance Mode ──
          _SectionCard(
            title: 'وضع الصيانة',
            icon: Icons.build_circle_outlined,
            children: [
              SwitchListTile(
                title: const Text('تفعيل وضع الصيانة'),
                subtitle: const Text('عند التفعيل، سيظهر للطلاب إشعار بأن التطبيق تحت الصيانة', style: TextStyle(fontSize: 12)),
                value: _draft.maintenanceMode,
                activeThumbColor: _C.warning,
                onChanged: (v) => setState(() => _draft = _draft.copyWith(maintenanceMode: v)),
              ),
              if (_draft.maintenanceMode)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _C.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.warning.withValues(alpha: 0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.warning_amber_rounded, color: _C.warning, size: 20),
                    SizedBox(width: 8),
                    Text('⚠️ وضع الصيانة مُفعّل حالياً', style: TextStyle(color: _C.warning, fontWeight: FontWeight.w600)),
                  ]),
                ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Save Button ──
          SizedBox(
            width: double.infinity,
            height: 50,
            child: provider.isSaving
                ? const Center(child: CircularProgressIndicator(color: _C.primary))
                : ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ الإعدادات', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  ),
          ),
        ],
      ),
    );
  }

  Color _modelColor(String model) {
    switch (model) {
      case 'deepseek': return const Color(0xFF00CEFF);
      case 'gemini': return const Color(0xFF4285F4);
      case 'claude': return const Color(0xFFD97706);
      case 'gpt': return const Color(0xFF10A37F);
      default: return _C.textMuted;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title; final IconData icon; final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _C.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: _C.primary, size: 22),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _C.textPrimary)),
          ]),
          const Divider(height: 28, color: _C.border),
          ...children,
        ],
      ),
    );
  }
}
