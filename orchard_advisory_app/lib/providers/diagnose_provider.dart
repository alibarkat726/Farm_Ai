import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/diagnosis_result.dart';
import '../services/api_service.dart';

class DiagnoseProvider extends ChangeNotifier {
  DiagnoseProvider(this._api);

  final ApiService _api;

  static const List<String> cropOptions = ['apricot', 'apple', 'cherry'];
  static const List<String> monthOptions = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String cropType = 'apricot';
  String month = monthOptions[DateTime.now().month - 1];
  String symptomDescription = '';
  XFile? imageFile;
  Uint8List? imageBytes;
  bool isSubmitting = false;
  String? formError;
  String? submitError;

  void setCropType(String value) {
    cropType = value;
    notifyListeners();
  }

  void setMonth(String value) {
    month = value;
    notifyListeners();
  }

  void setSymptomDescription(String value) {
    symptomDescription = value;
    if (formError != null) {
      formError = null;
    }
    notifyListeners();
  }

  Future<void> setImage(XFile? file) async {
    imageFile = file;
    imageBytes = file == null ? null : await file.readAsBytes();
    formError = null;
    notifyListeners();
  }

  void clearImage() {
    imageFile = null;
    imageBytes = null;
    notifyListeners();
  }

  void resetForm() {
    cropType = 'apricot';
    month = monthOptions[DateTime.now().month - 1];
    symptomDescription = '';
    imageFile = null;
    imageBytes = null;
    formError = null;
    submitError = null;
    isSubmitting = false;
    notifyListeners();
  }

  bool _validate() {
    final hasText = symptomDescription.trim().isNotEmpty;
    final hasImage = imageFile != null && imageBytes != null;
    if (!hasText && !hasImage) {
      formError =
          'Add a symptom description or attach a photo before getting a diagnosis.';
      notifyListeners();
      return false;
    }
    formError = null;
    return true;
  }

  Future<DiagnosisResult?> submit() async {
    if (isSubmitting) return null;
    if (!_validate()) return null;

    isSubmitting = true;
    submitError = null;
    notifyListeners();

    try {
      final DiagnosisResult result;
      if (imageFile != null && imageBytes != null) {
        result = await _api.diagnoseImage(
          cropType: cropType,
          month: month,
          symptomDescription: symptomDescription.trim().isEmpty
              ? null
              : symptomDescription.trim(),
          imageBytes: imageBytes!,
          filename: imageFile!.name,
        );
      } else {
        result = await _api.diagnoseText(
          cropType: cropType,
          month: month,
          symptomDescription: symptomDescription.trim(),
        );
      }
      return result;
    } on ApiException catch (e) {
      submitError = e.message;
      return null;
    } catch (_) {
      submitError = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
