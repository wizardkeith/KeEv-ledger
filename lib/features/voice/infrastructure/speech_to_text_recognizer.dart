import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/result.dart';
import '../application/voice_recognition.dart';

final class SpeechToTextRecognizer implements VoiceRecognizer {
  SpeechToTextRecognizer({SpeechToText? speech})
    : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  VoiceStatusCallback? _status;
  VoiceErrorCallback? _error;
  bool _initialized = false;
  int _generation = 0;

  @override
  Future<Result<String>> start({
    required String uiLocaleTag,
    required VoiceTranscriptCallback onTranscript,
    required VoiceStatusCallback onStatus,
    required VoiceErrorCallback onError,
  }) async {
    final generation = ++_generation;
    _status = onStatus;
    _error = onError;
    try {
      if (!_initialized) {
        final ready = await _speech.initialize(
          onStatus: _handleStatus,
          onError: _handleError,
          options: [SpeechToText.androidNoBluetooth],
        );
        if (!ready) {
          final permitted = await _speech.hasPermission;
          return Failure(
            permitted
                ? FailureCode.speechUnavailable
                : FailureCode.speechPermissionDenied,
          );
        }
        _initialized = true;
      }
      final locales = await _speech.locales();
      final locale = SpeechLocaleResolver.resolve(
        uiLocaleTag,
        locales.map((item) => item.localeId),
      );
      if (locale == null) {
        return const Failure(FailureCode.speechLocaleUnavailable);
      }
      await _speech.listen(
        onResult: (result) {
          if (generation == _generation) {
            onTranscript(
              VoiceTranscript(
                result.recognizedWords,
                isFinal: result.finalResult,
              ),
            );
          }
        },
        listenOptions: SpeechListenOptions(
          localeId: locale,
          partialResults: true,
          cancelOnError: true,
          onDevice: false,
          listenMode: ListenMode.confirmation,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 4),
        ),
      );
      onStatus(VoiceRecognitionStatus.listening);
      return Success(locale);
    } catch (_) {
      return const Failure(FailureCode.speechRecognitionFailed);
    }
  }

  void _handleStatus(String status) {
    _status?.call(switch (status) {
      SpeechToText.listeningStatus => VoiceRecognitionStatus.listening,
      SpeechToText.doneStatus => VoiceRecognitionStatus.processing,
      _ => VoiceRecognitionStatus.idle,
    });
  }

  void _handleError(SpeechRecognitionError error) {
    final message = error.errorMsg.toLowerCase();
    _error?.call(
      message.contains('permission')
          ? FailureCode.speechPermissionDenied
          : message.contains('language')
          ? FailureCode.speechLocaleUnavailable
          : FailureCode.speechRecognitionFailed,
    );
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  Future<void> cancel() {
    _generation++;
    return _speech.cancel();
  }
}

final class SpeechLocaleResolver {
  const SpeechLocaleResolver._();

  static String? resolve(String uiLocaleTag, Iterable<String> available) {
    final locales = available.toList(growable: false);
    final tag = _normalize(uiLocaleTag);
    if (tag == 'zh_HK') {
      return _first(locales, const ['yue_HK', 'zh_HK']);
    }
    if (tag == 'zh_CN') return _first(locales, const ['zh_CN']);
    if (tag == 'ja' || tag == 'ja_JP') {
      return _first(locales, const ['ja_JP', 'ja']);
    }
    if (tag == 'th' || tag == 'th_TH') {
      return _first(locales, const ['th_TH', 'th']);
    }
    if (tag == 'en' || tag.startsWith('en_')) {
      final exact = _first(locales, [tag, 'en_US', 'en_GB']);
      return exact ??
          locales.cast<String?>().firstWhere(
            (locale) => _normalize(locale!).startsWith('en_'),
            orElse: () => null,
          );
    }
    return null;
  }

  static String? _first(List<String> available, List<String> preferences) {
    for (final preferred in preferences) {
      for (final locale in available) {
        if (_normalize(locale) == preferred) return locale;
      }
    }
    return null;
  }

  static String _normalize(String value) => value.replaceAll('-', '_');
}
