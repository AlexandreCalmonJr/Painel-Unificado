// Um novo helper class para a faixa de IP
class IpRange {
  final String start;
  final String end;

  IpRange({required this.start, required this.end});

  factory IpRange.fromJson(Map<String, dynamic> json) {
    return IpRange(
      start: json['start'] as String? ?? '0.0.0.0',
      end: json['end'] as String? ?? '0.0.0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }
}

/// Representa uma Unidade com UMA OU MAIS faixas de IP.
class Unit {
  final String? id;
  final String name;
  // SUBSTITUÍDO: ipRangeStart e ipRangeEnd
  // NOVO:
  final List<IpRange> ipRanges;

  Unit({
    this.id,
    required this.name,
    required this.ipRanges,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    // Lê o array 'ip_ranges' do JSON
    var rangesList = <IpRange>[];
    if (json['ip_ranges'] != null && json['ip_ranges'] is List) {
      rangesList = (json['ip_ranges'] as List)
          .map((i) => IpRange.fromJson(i))
          .toList();
    }
    
    // Fallback para o formato antigo, se o servidor ainda não foi atualizado
    else if (json['ip_range_start'] != null) {
       rangesList.add(IpRange(
         start: json['ip_range_start'], 
         end: json['ip_range_end']
       ));
    }

    return Unit(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? 'Unidade Inválida',
      ipRanges: rangesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      // Envia o array de faixas
      'ip_ranges': ipRanges.map((i) => i.toJson()).toList(),
    };
  }
}