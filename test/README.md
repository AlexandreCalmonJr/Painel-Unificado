# Guia de Testes - Painel Administrativo

Este documento descreve como executar os testes criados para o painel administrativo.

## 📋 Estrutura de Testes

```
test/
├── admin/
│   ├── tabs/
│   │   ├── admin_users_tab_test.dart
│   │   ├── admin_locations_tab_test.dart
│   │   ├── admin_modules_tab_test.dart
│   │   └── admin_apk_manager_tab_test.dart
│   └── admin_dashboard_integration_test.dart
└── services/
    ├── location_service_test.dart
    ├── device_service_test.dart
    └── auth_service_test.dart (já existente)
```

## 🧪 Tipos de Testes

### Widget Tests
Testam componentes individuais da UI:
- **admin_users_tab_test.dart** - Testa a aba de utilizadores
- **admin_locations_tab_test.dart** - Testa a aba de localizações (com sub-abas)
- **admin_modules_tab_test.dart** - Testa a aba de módulos
- **admin_apk_manager_tab_test.dart** - Testa o gestor de APKs

### Integration Tests
Testam fluxos completos:
- **admin_dashboard_integration_test.dart** - Testa navegação entre abas

### Service Tests
Testam serviços e lógica de negócio:
- **location_service_test.dart** - Testa operações CRUD de localizações
- **device_service_test.dart** - Testa operações com unidades e BSSIDs

## 🚀 Como Executar os Testes

### Executar todos os testes
```bash
flutter test
```

### Executar testes de um arquivo específico
```bash
flutter test test/admin/tabs/admin_users_tab_test.dart
```

### Executar testes de uma pasta
```bash
flutter test test/admin/
```

### Executar com cobertura de código
```bash
flutter test --coverage
```

### Ver relatório de cobertura (HTML)
```bash
# Instalar lcov (se necessário)
# Windows: choco install lcov
# Mac: brew install lcov
# Linux: sudo apt-get install lcov

# Gerar relatório HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir no navegador
start coverage/html/index.html  # Windows
open coverage/html/index.html   # Mac
xdg-open coverage/html/index.html  # Linux
```

## 📦 Dependências Necessárias

Adicione ao `pubspec.yaml` na seção `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  test: ^1.24.0
```

## 🔧 Gerar Mocks

Antes de executar os testes, gere os mocks necessários:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## ✅ Cobertura de Testes

### Admin Users Tab
- ✅ Exibição de loading
- ✅ Campo de busca
- ✅ Botão criar utilizador
- ✅ Filtro de busca
- ✅ Tratamento de erros

### Admin Locations Tab
- ✅ TabBar com 2 abas
- ✅ Navegação entre abas
- ✅ Aba Localizações (busca, criar, ações)
- ✅ Aba Unidades (estatísticas, busca, gerenciar BSSIDs)
- ✅ Tratamento de erros

### Admin Modules Tab
- ✅ Exibição de loading
- ✅ Campo de busca
- ✅ Botão criar módulo
- ✅ Cards de módulos
- ✅ Botões de editar/excluir
- ✅ Tratamento de erros

### Admin APK Manager Tab
- ✅ Cards de estatísticas
- ✅ Campo de busca
- ✅ Botão upload APK
- ✅ Cards de APKs
- ✅ Status badges
- ✅ Botões de ação (download, info, delete)

### Admin Dashboard Integration
- ✅ Exibição do dashboard
- ✅ Menu lateral
- ✅ Navegação entre todas as abas
- ✅ Toggle da sidebar
- ✅ Navegação de volta
- ✅ Integração com tema

### Services
- ✅ LocationService CRUD operations
- ✅ DeviceService units e BSSIDs
- ✅ Tratamento de erros HTTP
- ✅ Tratamento de erros de rede

## ⚠️ Notas Importantes

### Testes de Serviços Comentados

Os testes em `location_service_test.dart` e `device_service_test.dart` estão **comentados** porque os serviços precisam ser modificados para aceitar um `http.Client` mockado.

**Para ativar esses testes**, modifique os serviços para aceitar um cliente opcional:

```dart
class LocationService {
  static Future<List<Location>> fetchLocationsWithDeviceData(
    String token, {
    http.Client? client,  // Adicionar parâmetro opcional
  }) async {
    final httpClient = client ?? http.Client();  // Usar mock ou cliente real
    // ... resto do código
  }
}
```

## 🎯 Próximos Passos

1. **Descomentar testes de serviços** após modificar LocationService e DeviceService
2. **Adicionar testes para widgets auxiliares** (LocationDialog, ModuleDialog)
3. **Aumentar cobertura** para atingir 80%+
4. **Adicionar testes E2E** com `integration_test`

## 📊 Executar Testes em CI/CD

Exemplo de configuração para GitHub Actions:

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter pub run build_runner build
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
```
