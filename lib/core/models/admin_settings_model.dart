import 'package:cloud_firestore/cloud_firestore.dart';

/// Global admin settings stored as a single document: `admin_settings/global`.
class AdminSettingsModel {
  final Map<String, bool> aiModelsEnabled;
  final int dailyMessageLimit;
  final int maxMessageLength;
  final String systemPrompt;
  final String defaultModel;
  final bool attachmentsEnabled;
  final bool maintenanceMode;

  AdminSettingsModel({
    Map<String, bool>? aiModelsEnabled,
    this.dailyMessageLimit = 50,
    this.maxMessageLength = 2000,
    this.systemPrompt = 'أنت مساعد أكاديمي ذكي، أجب بدقة ووضوح.',
    this.defaultModel = 'deepseek',
    this.attachmentsEnabled = true,
    this.maintenanceMode = false,
  }) : aiModelsEnabled = aiModelsEnabled ??
            {
              'deepseek': true,
              'gemini': true,
              'claude': true,
              'gpt': true,
            };

  factory AdminSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AdminSettingsModel(
      aiModelsEnabled: Map<String, bool>.from(data['aiModelsEnabled'] ?? {}),
      dailyMessageLimit: data['dailyMessageLimit'] ?? 50,
      maxMessageLength: data['maxMessageLength'] ?? 2000,
      systemPrompt: data['systemPrompt'] ??
          'أنت مساعد أكاديمي ذكي، أجب بدقة ووضوح.',
      defaultModel: data['defaultModel'] ?? 'deepseek',
      attachmentsEnabled: data['attachmentsEnabled'] ?? true,
      maintenanceMode: data['maintenanceMode'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'aiModelsEnabled': aiModelsEnabled,
      'dailyMessageLimit': dailyMessageLimit,
      'maxMessageLength': maxMessageLength,
      'systemPrompt': systemPrompt,
      'defaultModel': defaultModel,
      'attachmentsEnabled': attachmentsEnabled,
      'maintenanceMode': maintenanceMode,
    };
  }

  AdminSettingsModel copyWith({
    Map<String, bool>? aiModelsEnabled,
    int? dailyMessageLimit,
    int? maxMessageLength,
    String? systemPrompt,
    String? defaultModel,
    bool? attachmentsEnabled,
    bool? maintenanceMode,
  }) {
    return AdminSettingsModel(
      aiModelsEnabled: aiModelsEnabled ?? this.aiModelsEnabled,
      dailyMessageLimit: dailyMessageLimit ?? this.dailyMessageLimit,
      maxMessageLength: maxMessageLength ?? this.maxMessageLength,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      defaultModel: defaultModel ?? this.defaultModel,
      attachmentsEnabled: attachmentsEnabled ?? this.attachmentsEnabled,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
    );
  }
}
