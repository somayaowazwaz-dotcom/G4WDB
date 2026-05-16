import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/survival_supply.dart';

class SurvivalAgent extends ChangeNotifier {
  List<SurvivalSupply> _supplies = [];
  int _householdSize = 1;
  bool _isInitialized = false;

  List<SurvivalSupply> get supplies => _supplies;
  int get householdSize => _householdSize;
  bool get isInitialized => _isInitialized;

  SurvivalAgent() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _householdSize = prefs.getInt('survival_household_size') ?? 1;
    
    final suppliesJson = prefs.getString('survival_supplies');
    if (suppliesJson != null) {
      final List<dynamic> decoded = jsonDecode(suppliesJson);
      _supplies = decoded.map((item) => SurvivalSupply.fromMap(item)).toList();
    } else {
      // Default baseline supplies
      _supplies = [
        SurvivalSupply(
          id: '1',
          name: 'Water',
          totalAmount: 21.0,
          dailyUsage: 3.0,
          unit: 'L',
          category: 'Essential',
        ),
        SurvivalSupply(
          id: '2',
          name: 'Food',
          totalAmount: 15400.0,
          dailyUsage: 2200.0,
          unit: 'kcal',
          category: 'Essential',
        ),
      ];
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('survival_household_size', _householdSize);
    final suppliesJson = jsonEncode(_supplies.map((s) => s.toMap()).toList());
    await prefs.setString('survival_supplies', suppliesJson);
  }

  void setHouseholdSize(int size) {
    if (size < 1) return;
    _householdSize = size;
    _saveData();
    notifyListeners();
  }

  void addSupply(SurvivalSupply supply) {
    _supplies.add(supply);
    _saveData();
    notifyListeners();
  }

  void updateSupply(SurvivalSupply updatedSupply) {
    final index = _supplies.indexWhere((s) => s.id == updatedSupply.id);
    if (index != -1) {
      _supplies[index] = updatedSupply;
      _saveData();
      notifyListeners();
    }
  }

  void deleteSupply(String id) {
    _supplies.removeWhere((s) => s.id == id);
    _saveData();
    notifyListeners();
  }

  double getDailyTotal(String supplyName) {
    final supply = _supplies.firstWhere((s) => s.name == supplyName, 
        orElse: () => SurvivalSupply(id: '', name: '', totalAmount: 0, dailyUsage: 0, unit: '', category: ''));
    return supply.dailyUsage * _householdSize;
  }

  void deductDailyUsage() {
    _supplies = _supplies.map((s) {
      final dailyTotal = s.dailyUsage * _householdSize;
      final newAmount = (s.totalAmount - dailyTotal).clamp(0.0, double.infinity);
      return s.copyWith(totalAmount: newAmount);
    }).toList();
    _saveData();
    notifyListeners();
  }
}

final survivalAgentProvider = ChangeNotifierProvider((ref) {
  return SurvivalAgent();
});
