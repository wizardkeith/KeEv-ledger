import '../../../core/result.dart';

enum VoiceRecognitionStatus { idle, listening, processing }

final class VoiceTranscript {
  const VoiceTranscript(this.text, {required this.isFinal});

  final String text;
  final bool isFinal;
}

typedef VoiceTranscriptCallback = void Function(VoiceTranscript transcript);
typedef VoiceStatusCallback = void Function(VoiceRecognitionStatus status);
typedef VoiceErrorCallback = void Function(FailureCode failure);

/// Package-neutral boundary for foreground, user-initiated speech recognition.
abstract interface class VoiceRecognizer {
  Future<Result<String>> start({
    required String uiLocaleTag,
    required VoiceTranscriptCallback onTranscript,
    required VoiceStatusCallback onStatus,
    required VoiceErrorCallback onError,
  });

  Future<void> stop();
  Future<void> cancel();
}

enum VoiceDraftField { amount, kind, category, note }

/// Guards a Quick Add draft from stale sessions and late callback overwrites.
final class VoiceDraftOwnership {
  int _generation = 0;
  final Set<VoiceDraftField> _userOwned = {};

  int beginSession() => ++_generation;

  void markUserEdited(VoiceDraftField field) => _userOwned.add(field);

  bool mayApply(int session, VoiceDraftField field) =>
      session == _generation && !_userOwned.contains(field);

  void cancelSession() => ++_generation;

  bool isCurrent(int session) => session == _generation;
}
