# Script para corrigir imports de asset_module_base
$projectPath = "c:\Users\Administrator\To de Olho MDM System\Painel MDM\Painel-Unificado\lib"
$oldImport = "package:painel_windowns/data/models/asset_module_base.dart"
$newImport = "package:painel_windowns/data/models/asset_module_base_model.dart"

Write-Host "Atualizando imports de asset_module_base..."
Write-Host "De: $oldImport"
Write-Host "Para: $newImport"
Write-Host ""

$dartFiles = Get-ChildItem -Path $projectPath -Filter "*.dart" -Recurse
$filesChanged = 0
$totalReplacements = 0

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    if ($content -match [regex]::Escape($oldImport)) {
        $newContent = $content -replace [regex]::Escape($oldImport), $newImport
        $matches = ([regex]::Matches($content, [regex]::Escape($oldImport))).Count
        
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
        
        $filesChanged++
        $totalReplacements += $matches
        
        Write-Host "OK $($file.Name): $matches substituicoes"
    }
}

Write-Host ""
Write-Host "Resumo:"
Write-Host "  Arquivos modificados: $filesChanged"
Write-Host "  Total de substituicoes: $totalReplacements"
Write-Host ""
Write-Host "Concluido!"
