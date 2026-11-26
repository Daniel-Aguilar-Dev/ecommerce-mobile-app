class ProductoParamsPublic {
  const ProductoParamsPublic({
    this.query,
    this.categoria,
  });

  final String? query;
  final int? categoria;

  String getUrlParams() {
    final params = <String, String>{
      if (query != null && query!.isNotEmpty) 'query': query!,
      if (categoria != null) 'categoria': '$categoria',
    };

    if (params.isEmpty) return '';
    return '?${Uri(queryParameters: params).query}';
  }

  ProductoParamsPublic copyWith({
    String? query,
    int? categoria,
  }) {
    return ProductoParamsPublic(
      query: query ?? this.query,
      categoria: categoria ?? this.categoria,
    );
  }

  bool get isEmpty =>
    (query == null || query!.isEmpty) &&
    categoria == null;

  bool get isNotEmpty => !isEmpty;
}