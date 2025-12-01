import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CaseRepository {
  static const String _storageKey = 'saved_cases';

  Future<List<Map<String, dynamic>>> getCases() async {
    final prefs = await SharedPreferences.getInstance();
    final String? casesJson = prefs.getString(_storageKey);
    if (casesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(casesJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> saveCase(Map<String, dynamic> newCase) async {
    final cases = await getCases();

    // Check if case already exists (update it)
    final index = cases.indexWhere((c) => c['id'] == newCase['id']);
    if (index != -1) {
      cases[index] = newCase;
    } else {
      cases.add(newCase);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(cases));
  }

  Future<void> deleteCase(int id) async {
    final cases = await getCases();
    cases.removeWhere((c) => c['id'] == id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(cases));
  }
}
