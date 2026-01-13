// Um novo helper class para a faixa de IP

class IpRange {

  IpRange({required this.start, required this.end});

  factory IpRange.fromJson(Map<String, dynamic> json) {
    return IpRange(
      start: json['start'] as String? ?? '0.0.0.0',
      end: json['end'] as String? ?? '0.0.0.0',
    );
  }
  final String start;
  final String end;

  Map<String, dynamic> toJson() {
    return {'start': start, 'end': end};
  }
}

/// Representa uma Unidade com UMA OU MAIS faixas de IP.
class Unit {

  Unit({required this.name, required this.ipRanges, this.id});

  factory Unit.fromJson(Map<String, dynamic> json) {
    // Lê o array 'ip_ranges' do JSON
    var rangesList = <IpRange>[];
    if (json['ip_ranges'] != null && json['ip_ranges'] is List) {
      rangesList =
          (json['ip_ranges'] as List)
              .map((i) => IpRange.fromJson(Map<String, dynamic>.from(i as Map)))
              .toList();
    }
    // Fallback para o formato antigo, se o servidor ainda não foi atualizado
    else if (json['ip_range_start'] != null) {
      rangesList.add(
        IpRange(
          start: json['ip_range_start'] as String,
          end: json['ip_range_end'] as String,
        ),
      );
    }

    return Unit(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? 'Unidade Inválida',
      ipRanges: rangesList,
    );
  }
  final String? id;
  final String name;
  final List<IpRange> ipRanges;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      // Envia o array de faixas
      'ip_ranges': ipRanges.map((i) => i.toJson()).toList(),
    };
  }
}

// ❌ REMOVIDO: Getters inválidos que tentavam acessar 'json' fora do escopo
// String? get sector => json['sector'] as String?;
// String? get floor => json['floor'] as String?;

// ❌ REMOVIDO: Extension inválida sem propósito claro
// extension on JsonCodec {
//   dynamic operator [](String other) => null;
// }
