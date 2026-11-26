enum Orden { nombre_asc, nombre_desc }

class ProductoParams {
  const ProductoParams({
    this.stockBajo,
    this.stockCero,
    this.soloDescontinuados,
    this.soloVigentes,
    this.query,
    this.orden,
    this.marca,
    this.categoria,
  });

  final bool? stockBajo;
  final bool? stockCero;
  final bool? soloDescontinuados;
  final bool? soloVigentes;
  final String? query;
  final Orden? orden;
  final String? marca;
  final int? categoria;

  String getUrlParams() {
    final params = <String, String>{
      if (stockBajo != null) 'stockBajo': '$stockBajo',
      if (stockCero != null) 'stockCero': '$stockCero',
      if (soloDescontinuados != null) 'solo_descontinuados': '$soloDescontinuados',
      if (soloVigentes != null) 'solo_vigentes': '$soloVigentes',
      if (query != null && query!.isNotEmpty) 'query': query!,
      if (orden != null) 'orden': orden!.name,
      if (marca != null && marca!.isNotEmpty) 'marca': marca!,
      if (categoria != null) 'categoria': '$categoria',
    };

    if (params.isEmpty) return '';
    return '?${Uri(queryParameters: params).query}';
  }

  bool get isEmpty =>
      stockBajo == null &&
          stockCero == null &&
          soloDescontinuados == null &&
          soloVigentes == null &&
          (query == null || query!.isEmpty) &&
          orden == null &&
          (marca == null || marca!.isEmpty) &&
          categoria == null;

  bool get isNotEmpty => !isEmpty;

  ProductoParams copyWith({
    bool? stockBajo,
    bool? stockCero,
    bool? soloDescontinuados,
    bool? soloVigentes,
    String? query,
    Orden? orden,
    String? marca,
    int? categoria,
  }) {
    return ProductoParams(
      stockBajo: stockBajo ?? this.stockBajo,
      stockCero: stockCero ?? this.stockCero,
      soloDescontinuados: soloDescontinuados ?? this.soloDescontinuados,
      soloVigentes: soloVigentes ?? this.soloVigentes,
      query: query ?? this.query,
      orden: orden ?? this.orden,
      marca: marca ?? this.marca,
      categoria: categoria ?? this.categoria,
    );
  }
}