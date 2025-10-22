import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/utils/constants.dart';

DateTime? parseLastSeen(dynamic lastSeen) {
  if (lastSeen is String) {
    return DateTime.tryParse(lastSeen)?.toLocal();
  }
  return null;
}

bool isDeviceOnline(DateTime? seenTime, {Duration tolerance = kOnlineTolerance}) {
  if (seenTime == null) return false;
  final now = DateTime.now();
  final difference = now.difference(seenTime).abs();
  return difference <= tolerance;
}

String formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return 'N/D';
  return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

int ipToInt(String ip) {
  final parts = ip.split('.').map(int.parse).toList();
  return (parts[0] << 24) + (parts[1] << 16) + (parts[2] << 8) + parts[3];
}

bool isValidIp(String ip) {
  final regex = RegExp(
    r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );
  return regex.hasMatch(ip);
}

// --- FUNÇÃO ATUALIZADA ---
/// Encontra o nome da Unidade correspondente a um dado endereço IP.
String? getUnitFromIp(String? ipAddress, List<Unit> units) {
  if (ipAddress == null || ipAddress == 'N/A' || !isValidIp(ipAddress)) {
    return null;
  }
  final ipInt = ipToInt(ipAddress);

  // Itera sobre cada unidade
  for (final unit in units) {
    // Itera sobre CADA FAIXA de IP (IpRange) dentro da unidade
    for (final range in unit.ipRanges) {
      if (isValidIp(range.start) && isValidIp(range.end)) {
        final startInt = ipToInt(range.start);
        final endInt = ipToInt(range.end);
        if (ipInt >= startInt && ipInt <= endInt) {
          return unit.name; // Retorna a unidade
        }
      }
    }
  }
  return null;
}
// --- FIM DA ATUALIZAÇÃO ---

/// Formata uma data/hora para exibição
String formatDateTimeDetailed(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
}

/// Analisa uma string de data e retorna um DateTime
DateTime parseLastSeenString(String lastSeenStr) {
  try {
    return DateTime.parse(lastSeenStr).toLocal();
  } catch (e) {
    return DateTime.now();
  }
}

/// Retorna a cor baseada no status
Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'online':
      return Colors.green;
    case 'offline':
      return Colors.red;
    case 'maintenance':
    case 'com erro':
    case 'warning':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

/// Formata bytes para formato legível (KB, MB, GB)
String formatBytes(int bytes, {int decimals = 2}) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  var i = (bytes.bitLength - 1) ~/ 10;
  return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
}

/// Calcula o tempo decorrido desde uma data
String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'há ${difference.inSeconds} segundos';
  } else if (difference.inMinutes < 60) {
    return 'há ${difference.inMinutes} minutos';
  } else if (difference.inHours < 24) {
    return 'há ${difference.inHours} horas';
  } else if (difference.inDays < 7) {
    return 'há ${difference.inDays} dias';
  } else {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
} // <-- ERRO DE SINTAXE CORRIGIDO AQUI
