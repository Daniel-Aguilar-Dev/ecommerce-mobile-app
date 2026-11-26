class AuditableEntity {
  const AuditableEntity({
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy
  });

  final String? createdAt;
  final String? updatedAt;
  final int? createdBy;
  final int? updatedBy;
}