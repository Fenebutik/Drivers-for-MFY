# Настройка консоли
$Host.UI.RawUI.WindowTitle = "Установщик драйверов принтеров"
Clear-Host

# Исправляем кодировку для корректного отображения символов
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Структура данных: Производитель -> Список моделей
$PrintersByVendor = [ordered]@{
    "Kyocera" = @(
        "TWAIN Driver (драйвер для сканирования)"  # Пункт 1 (старый '1')
        "Ecosys P2040DN (браузер)"                 # Пункт 2 (старый '2')
        "Ecosys P2040DN"
        "Ecosys M2135dn"
        "Ecosys M3040dn"
        "Ecosys M2040dn"
        "MA2000"
    )
    "Brother" = @(
        "MFC-L2700DNR"
    )
    "HP" = @(
        "Laser MFP 136a"
        "LaserJet Pro MFP M125ra"
        "Laser MFP 137fnw"
        "LaserJet M236sdw"
    )
}

# Функции псевдографики для меню (ИСПРАВЛЕНЫ)
function Write-MenuHeader {
    param([string]$Title)
    $fullTitle = "  $Title  "
    # Используем фиксированную ширину для стабильности
    $width = 50
    $line = '═' * $width
    Write-Host "╔$($line)╗" -ForegroundColor DarkCyan
    Write-Host "║" -NoNewline -ForegroundColor DarkCyan
    $padding = [Math]::Max(0, ($width - $fullTitle.Length))
    $leftPad = [Math]::Floor($padding / 2)
    $rightPad = $padding - $leftPad
    Write-Host ("{0}{1}{2}" -f (' ' * $leftPad), $fullTitle, (' ' * $rightPad)) -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor DarkCyan
    Write-Host "╚$($line)╝" -ForegroundColor DarkCyan
    Write-Host ""
}

function Write-VendorBlock {
    param([int]$Number, [string]$VendorName)
    # ФИКСИРОВАННАЯ ширина для всех блоков
    $fixedWidth = 30
    $displayText = " $VendorName "
    $line = '─' * ($fixedWidth - 2)  # -2 для угловых символов
    
    # Корректное выравнивание номера и названия
    Write-Host "  ┌$($line)┐" -ForegroundColor DarkYellow
    Write-Host ("  │ {0,2} {1}" -f $Number, $VendorName.PadRight($fixedWidth - 7, ' ')) -NoNewline -ForegroundColor Yellow
    Write-Host "│" -ForegroundColor DarkYellow
    Write-Host "  └$($line)┘" -ForegroundColor DarkYellow
}

function Write-PrinterItem {
    param([int]$Number, [string]$Model)
    Write-Host ("    {0,2}" -f $Number) -NoNewline -ForegroundColor Green
    Write-Host " │ " -NoNewline -ForegroundColor Gray
    Write-Host $Model -ForegroundColor White
}

# Функция для отображения меню выбора производителя
function Show-VendorMenu {
    Clear-Host
    Write-MenuHeader -Title "УСТАНОВЩИК ДРАЙВЕРОВ ПРИНТЕРОВ"
    
    Write-Host "  ╔══════════════════════════════════════╗" -ForegroundColor DarkMagenta
    Write-Host "  ║   ВЫБЕРИТЕ ПРОИЗВОДИТЕЛЯ           ║" -ForegroundColor Magenta
    Write-Host "  ╚══════════════════════════════════════╝" -ForegroundColor DarkMagenta
    Write-Host ""
    
    $vendorNumber = 1
    foreach ($vendor in $PrintersByVendor.Keys) {
        Write-VendorBlock -Number $vendorNumber -VendorName $vendor
        $vendorNumber++
    }
    
    Write-Host ""
    Write-Host "  ═══════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ("    {0,2}" -f 0) -NoNewline -ForegroundColor Green
    Write-Host " │ " -NoNewline -ForegroundColor Gray
    Write-Host "Выход" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ═══════════════════════════════════════" -ForegroundColor DarkCyan
    
    $choice = Read-Host "`n  Введите номер производителя"
    
    # ========== ПАСХАЛКА ==========
    if ($choice -eq '1488') {
        Write-Host "`n"
        Write-Host "   ╔════════════════════════════════╗" -ForegroundColor Red
        Write-Host "   ║          ПАСХАЛКО             ║" -ForegroundColor Red
        Write-Host "   ╚════════════════════════════════╝" -ForegroundColor Red
        Write-Host "`nНажмите любую клавишу, чтобы продолжить..." -ForegroundColor Gray
        [Console]::ReadKey($true) | Out-Null
        return 'back'
    }
    
    return $choice
}

# Функция для отображения меню выбора модели
function Show-ModelMenu {
    param([string]$SelectedVendor)
    
    Clear-Host
    Write-MenuHeader -Title "УСТАНОВЩИК ДРАЙВЕРОВ ПРИНТЕРОВ"
    
    Write-Host "  ╔══════════════════════════════════════╗" -ForegroundColor DarkMagenta
    Write-Host ("  ║   ПРОИЗВОДИТЕЛЬ: {0,-18}   ║" -f $SelectedVendor) -ForegroundColor Magenta
    Write-Host "  ╚══════════════════════════════════════╝" -ForegroundColor DarkMagenta
    Write-Host ""
    
    $models = $PrintersByVendor[$SelectedVendor]
    $modelNumber = 1
    
    foreach ($model in $models) {
        Write-PrinterItem -Number $modelNumber -Model $model
        $modelNumber++
    }
    
    Write-Host ""
    Write-Host "  ═══════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ("    {0,2}" -f 0) -NoNewline -ForegroundColor Green
    Write-Host " │ " -NoNewline -ForegroundColor Gray
    Write-Host "Назад" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ═══════════════════════════════════════" -ForegroundColor DarkCyan
    
    $choice = Read-Host "`n  Введите номер модели"
    return $choice
}

# Функция для получения action по выбранной модели
function Get-ActionForModel {
    param([string]$Vendor, [string]$Model)
    
    if ($Vendor -eq "Kyocera") {
        if ($Model -eq "TWAIN Driver (драйвер для сканирования)") {
            return '1'
        }
        elseif ($Model -eq "Ecosys P2040DN (браузер)") {
            return '2'
        }
    }
    
    return 'NEW_PRINTER'
}

# ==================== ГЛАВНЫЙ ЦИКЛ МЕНЮ ====================
$currentVendor = $null

while ($true) {
    # Если производитель не выбран, показываем меню производителей
    if (-not $currentVendor) {
        $choice = Show-VendorMenu
        
        if ($choice -eq 'back') {
            continue
        }
        elseif ($choice -eq '0') {
            Write-Host "`n[Инфо] Выход." -ForegroundColor Cyan
            exit
        }
        elseif ([int]$choice -ge 1 -and [int]$choice -le $PrintersByVendor.Count) {
            $vendorIndex = [int]$choice - 1
            $vendorNames = @($PrintersByVendor.Keys)
            $currentVendor = $vendorNames[$vendorIndex]
            continue
        }
        else {
            Write-Host "`n[Ошибка] Неверный выбор: $choice" -ForegroundColor Red
            Write-Host "Нажмите любую клавишу, чтобы продолжить..." -ForegroundColor Gray
            [Console]::ReadKey($true) | Out-Null
            continue
        }
    }
    else {
        # Показываем меню моделей выбранного производителя
        $choice = Show-ModelMenu -SelectedVendor $currentVendor
        
        if ($choice -eq '0') {
            $currentVendor = $null
            continue
        }
        
        $models = $PrintersByVendor[$currentVendor]
        if ([int]$choice -ge 1 -and [int]$choice -le $models.Count) {
            $modelIndex = [int]$choice - 1
            $selectedModel = $models[$modelIndex]
            
            Write-Host "`n[Инфо] Выбрано: $currentVendor $selectedModel" -ForegroundColor Yellow
            Write-Host ""
            
            # Определяем action для выбранной модели
            $action = Get-ActionForModel -Vendor $currentVendor -Model $selectedModel
            
            # ВАЖНО: Здесь старое ядро логики
            switch ($action) {
                '1' {
                    # --- СТАРЫЙ ПРОВЕРЕННЫЙ БЛОК ДЛЯ ПУНКТА '1' (Kyocera TWAIN) ---
                    $DriverName = "Kyocera TWAIN Driver"
                    $DownloadUrl = "https://github.com/Fenebutik/Drivers-for-MFY/raw/refs/heads/main/KyoceraTWAINDriver2.1.2822_1.4rc9.exe"
                    $LocalFileName = "Kyocera_TWAIN_Driver_2.1.2822_1.4rc9.exe"
                    $DownloadPath = Join-Path -Path $env:TEMP -ChildPath $LocalFileName

                    Write-Host "[Инфо] Начинаю загрузку..." -ForegroundColor Gray
                    try {
                        Invoke-WebRequest -Uri $DownloadUrl -OutFile $DownloadPath -UseBasicParsing
                        Write-Host "[Успех] Файл загружен в: $DownloadPath" -ForegroundColor Green
                        Write-Host "Давай установи меня!" -ForegroundColor Yellow
                        Start-Process -FilePath $DownloadPath -Wait
                        Write-Host "[Инфо] Установка завершена." -ForegroundColor Gray
                    }
                    catch {
                        Write-Host "[Ошибка] Не удалось загрузить или запустить файл." -ForegroundColor Red
                        Write-Host "[Детали] $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
                '2' {
                    # --- СТАРЫЙ БЛОК ДЛЯ ПУНКТА '2' (Яндекс.Диск в браузере) ---
                    $DriverName = "KyoceraEcosysP2040DN"
                    $DownloadPageUrl = "https://disk.yandex.ru/d/YFavU20LUBodgA"

                    Write-Host "[Инфо] Открываю страницу загрузки в браузере..." -ForegroundColor Gray
                    try {
                        Start-Process "msedge.exe" -ArgumentList $DownloadPageUrl -ErrorAction Stop
                        Write-Host "[Успех] Страница открыта. Скачайте файл вручную." -ForegroundColor Green
                    }
                    catch {
                        Write-Host "[Предупреждение] Пробую браузер по умолчанию..." -ForegroundColor Yellow
                        Start-Process $DownloadPageUrl
                    }
                }
                'NEW_PRINTER' {
                    # --- ЗАГЛУШКА ДЛЯ НОВЫХ ПРИНТЕРОВ ---
                    Write-Host "[Инфо] Функция установки для этого принтера в разработке." -ForegroundColor Yellow
                    Write-Host "      Чтобы добавить драйвер, обновите хэш-таблицу DriverUrls" -ForegroundColor Gray
                }
            }
            Write-Host "`nНажмите любую клавишу, чтобы вернуться в меню..." -ForegroundColor Gray
            [Console]::ReadKey($true) | Out-Null
        }
        else {
            Write-Host "`n[Ошибка] Неверный выбор: $choice" -ForegroundColor Red
            Write-Host "Нажмите любую клавишу, чтобы продолжить..." -ForegroundColor Gray
            [Console]::ReadKey($true) | Out-Null
        }
    }
}
