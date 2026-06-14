import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String baseUrl = 'http://127.0.0.1:8000/api';
  static String? _token;

  static String? get token => _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 400) {
      final data = decoded as Map<String, dynamic>;
      throw ApiException(
        message: _extractErrorMessage(data),
        statusCode: response.statusCode,
        errors: data['errors'] as Map<String, dynamic>?,
      );
    }

    return decoded as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 400) {
      final data = decoded as Map<String, dynamic>;
      throw ApiException(
        message: _extractErrorMessage(data),
        statusCode: response.statusCode,
      );
    }

    return decoded as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getList(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 400) {
      if (decoded is Map) {
        throw ApiException(
          message: _extractErrorMessage(decoded as Map<String, dynamic>),
          statusCode: response.statusCode,
        );
      }
      throw ApiException(message: 'Request failed', statusCode: response.statusCode);
    }

    return decoded as List<dynamic>;
  }

  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw ApiException(
        message: _extractErrorMessage(decoded),
        statusCode: response.statusCode,
        errors: decoded['errors'] as Map<String, dynamic>?,
      );
    }

    return decoded;
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw ApiException(
        message: _extractErrorMessage(decoded),
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  static String _extractErrorMessage(Map<String, dynamic> data) {
    if (data.containsKey('message')) return data['message'] as String;

    final errors = data['errors'];
    if (errors is Map) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }

    return 'Something went wrong';
  }

  // ─── Auth ──────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await post('/register', {
      'name': name,
      'email': email,
      'password': password,
    });

    if (data['token'] != null) {
      await _saveToken(data['token'] as String);
    }

    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await post('/login', {
      'email': email,
      'password': password,
    });

    if (data['token'] != null) {
      await _saveToken(data['token'] as String);
    }

    return data;
  }

  static Future<void> logout() async {
    await post('/logout', {});
    await clearToken();
  }

  static Future<Map<String, dynamic>> getUser() async {
    return get('/user');
  }

  static bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return path;
  }

  // ─── Categories ────────────────────────────────────────────

  static Future<List<dynamic>> getCategories() async {
    return getList('/categories');
  }

  static Future<Map<String, dynamic>> getCategory(int id) async {
    return get('/categories/$id');
  }

  // ─── Products ──────────────────────────────────────────────

  static Future<Map<String, dynamic>> getProducts({
    int? categoryId,
    String? search,
    int page = 1,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;

    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return get('/products?$query');
  }

  static Future<Map<String, dynamic>> getProduct(int id) async {
    return get('/products/$id');
  }

  // ─── Cart ──────────────────────────────────────────────────

  static Future<List<dynamic>> getCart() async {
    return getList('/cart');
  }

  static Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int quantity,
  }) async {
    return post('/cart', {'product_id': productId, 'quantity': quantity});
  }

  static Future<Map<String, dynamic>> updateCartItem(
    int cartItemId,
    int quantity,
  ) async {
    return patch('/cart/$cartItemId', {'quantity': quantity});
  }

  static Future<Map<String, dynamic>> removeFromCart(int cartItemId) async {
    return delete('/cart/$cartItemId');
  }

  // ─── Orders ────────────────────────────────────────────────

  static Future<List<dynamic>> getOrders() async {
    return getList('/orders');
  }

  static Future<Map<String, dynamic>> placeOrder() async {
    return post('/orders', {});
  }

  static Future<Map<String, dynamic>> getOrder(int id) async {
    return get('/orders/$id');
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;
}
