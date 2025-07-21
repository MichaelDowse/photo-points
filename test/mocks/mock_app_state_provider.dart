import 'package:photopoints/providers/app_state_provider.dart';
import 'package:photopoints/models/photo_point.dart';

class MockAppStateProvider extends AppStateProvider {
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void setPhotoPoints(List<PhotoPoint> photoPoints) {
    _photoPoints = photoPoints;
    notifyListeners();
  }

  void setPermissions(Map<String, bool> permissions) {
    _permissions = permissions;
    notifyListeners();
  }

  // Access private fields for testing
  bool _isLoading = false;
  String? _error;
  List<PhotoPoint> _photoPoints = [];
  Map<String, bool> _permissions = {};

  @override
  List<PhotoPoint> get photoPoints => _photoPoints;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;
  
  @override
  Map<String, bool> get permissions => _permissions;

  @override
  void clearError() {
    _error = null;
    notifyListeners();
  }
}