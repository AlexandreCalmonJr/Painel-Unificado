# Guia de Migração para Widgets Base

## 📋 Resumo

Este guia explica como migrar código existente para usar os novos widgets base reutilizáveis.

---

## 🔄 Padrões de Migração

### 1. Substituir StatusChip

**Antes**:
```dart
Widget _buildStatusChip(String status) {
  Color color;
  IconData icon;
  
  switch (status.toLowerCase()) {
    case 'online':
      color = Colors.green;
      icon = Icons.check_circle;
      break;
    case 'offline':
      color = Colors.grey;
      icon = Icons.cancel;
      break;
    // ...
  }
  
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: color),
        Text(status),
      ],
    ),
  );
}
```

**Depois**:
```dart
import 'package:painel_windowns/widgets/common/index.dart';

StatusChip(status: device.status, type: StatusType.device)
```

---

### 2. Substituir BatteryIcon

**Antes**:
```dart
IconData getBatteryIcon(num? batteryLevel) {
  if (batteryLevel == null) return Icons.battery_unknown;
  if (batteryLevel >= 80) return Icons.battery_full;
  if (batteryLevel >= 60) return Icons.battery_6_bar;
  // ...
}

Icon(getBatteryIcon(device.batteryLevel), color: getColor())
```

**Depois**:
```dart
BatteryIcon(batteryLevel: device.batteryLevel, showPercentage: true)
```

---

### 3. Substituir Tabelas de Dados

**Antes** (managed_devices_card.dart - 420 linhas):
```dart
class ManagedDevicesCard extends StatefulWidget {
  // Lógica de paginação
  // Construção manual de DataTable
  // Células customizadas
  // Menu de ações
  // ...
}
```

**Depois** (managed_devices_card_v2.dart - ~130 linhas):
```dart
BaseDataTable<Device>(
  items: devices,
  columns: [
    DataTableColumn(label: 'Nome', builder: (d) => TableCell(...)),
    DataTableColumn(label: 'Status', builder: (d) => StatusChip(...)),
  ],
  actions: [
    TableAction(icon: Icons.edit, label: 'Editar', onTap: ...),
  ],
  showPagination: true,
)
```

**Redução**: 420 → 130 linhas (-69%)

---

### 4. Substituir Menus de Comando

**Antes** (command_controls.dart - 325 linhas):
```dart
class CommandControls extends StatelessWidget {
  // Múltiplos diálogos customizados
  // Lógica de confirmação repetida
  // Menu manual com PopupMenuButton
  // ...
}
```

**Depois** (command_controls_v2.dart - ~160 linhas):
```dart
BaseCommandMenu<Device>(
  item: device,
  actions: [
    CommandAction(
      label: 'Bloquear',
      icon: Icons.lock,
      onTap: _lockDevice,
      requiresConfirmation: true,
    ),
  ],
)
```

**Redução**: 325 → 160 linhas (-51%)

---

### 5. Substituir Diálogos

**Antes**:
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirmar'),
    content: Text('Deseja continuar?'),
    actions: [
      TextButton(...),
      ElevatedButton(...),
    ],
  ),
);
```

**Depois**:
```dart
final confirmed = await BaseDialog.confirm(
  context: context,
  title: 'Confirmar',
  message: 'Deseja continuar?',
);
```

---

### 6. Substituir StatCard

**Antes** (devices/widgets/stat_card.dart - 49 linhas):
```dart
class StatCard extends StatelessWidget {
  // Implementação customizada
}
```

**Depois** (1 linha):
```dart
export 'package:painel_windowns/widgets/common/stat_card.dart';
```

---

## 📁 Arquivos Criados (Versões V2)

### Prontos para Uso
1. ✅ `devices/widgets/stat_card.dart` - Migrado (export)
2. ✅ `devices/widgets/managed_devices_card_v2.dart` - Nova versão
3. ✅ `devices/widgets/command_controls_v2.dart` - Nova versão

### Para Migrar (Próximos)
- `modules/widgets/generic_managed_assets_card.dart`
- `modules/widgets/asset_command_controls.dart`
- `totem/widgets/managed_devices_card.dart`
- 22 tabs (usar BaseTabView quando criado)

---

## 🚀 Como Migrar Gradualmente

### Opção 1: Substituição Direta
Renomear arquivo antigo e usar versão V2:
```bash
mv managed_devices_card.dart managed_devices_card_old.dart
mv managed_devices_card_v2.dart managed_devices_card.dart
```

### Opção 2: Coexistência
Manter ambas versões e migrar gradualmente:
```dart
// Use a versão antiga
import 'managed_devices_card.dart';

// Ou use a nova versão
import 'managed_devices_card_v2.dart';
```

### Opção 3: Export Direto
Para widgets simples como StatCard:
```dart
// Substitua todo o conteúdo por:
export 'package:painel_windowns/widgets/common/stat_card.dart';
```

---

## 📊 Impacto da Migração

| Arquivo | Antes | Depois | Redução |
|---------|-------|--------|---------|
| stat_card.dart | 49 | 1 | -98% |
| managed_devices_card.dart | 420 | 130 | -69% |
| command_controls.dart | 325 | 160 | -51% |
| **Total** | **794** | **291** | **-63%** |

---

## ✅ Checklist de Migração

- [x] stat_card.dart
- [x] managed_devices_card_v2.dart (criado)
- [x] command_controls_v2.dart (criado)
- [ ] Substituir _buildStatusChip (7 arquivos)
- [ ] Substituir getBatteryIcon (1 arquivo)
- [ ] Migrar generic_managed_assets_card.dart
- [ ] Migrar asset_command_controls.dart
- [ ] Migrar totem/managed_devices_card.dart
- [ ] Migrar tabs (22 arquivos)

---

**Migração em progresso - Continue usando versões V2!**
