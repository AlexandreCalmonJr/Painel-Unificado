import 'package:flutter/material.dart'; // Necessário para o DateTimeRange

class AssetSearchFilter {

  AssetSearchFilter({
    required this.query,
    this.status,
    this.unit,
    this.sector,
    this.dateRange,
  });
  final String query;
  final String? status;
  final String? unit;
  final String? sector;
  final DateTimeRange? dateRange;
}