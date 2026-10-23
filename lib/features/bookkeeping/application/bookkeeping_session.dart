import '../../../core/local_id.dart';
import '../../../core/result.dart';
import 'bookkeeping_service.dart';
import '../../planning/application/planning_service.dart';
import '../../reports/application/reporting_service.dart';
import '../../receipts/application/receipt_service.dart';
import '../../voice/application/voice_recognition.dart';

/// Presentation-facing local session, wired to real SQLite at app composition.
abstract interface class BookkeepingSession {
  BookkeepingService get service;
  PlanningService get planning;
  ReportingService get reporting;
  ReceiptService get receipts;
  VoiceRecognizer get voice;
  Future<Result<LocalId>> profile();
}
