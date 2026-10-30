class AuditableEntity {
  const AuditableEntity({
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy
  });

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? createdBy;
  final int? updatedBy;
}