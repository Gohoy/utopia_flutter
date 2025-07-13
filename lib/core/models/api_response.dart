class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int? code;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.code,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'code': code,
    };
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int perPage;
  final bool hasNext;
  final bool hasPrev;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final itemsJson = json['items'] as List? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    
    return PaginatedResponse(
      items: itemsJson.map((item) => fromJsonT(item)).toList(),
      total: pagination['total'] ?? 0,
      page: pagination['page'] ?? 1,
      perPage: pagination['per_page'] ?? 20,
      hasNext: pagination['has_next'] ?? false,
      hasPrev: pagination['has_prev'] ?? false,
    );
  }
} 