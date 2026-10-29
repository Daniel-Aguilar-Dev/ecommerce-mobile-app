class AuditableEntity {
  const AuditableEntity({
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy
  });

  final DateTime createdAt;
  final DateTime updatedAt;
  final int createdBy;
  final int updatedBy;
}