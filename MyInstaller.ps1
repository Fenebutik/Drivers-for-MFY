# Настройка консоли
$Host.UI.RawUI.WindowTitle = "Установщик драйверов принтеров"
Clear-Host

# Оптимизация производительности
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Установка правильной кодировки
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Структура данных: Производитель - Список моделей
$PrintersByVendor = [ordered]@{
    "Kyocera" = @(
        "TWAIN Driver (драйвер для сканирования)"  
        "Ecosys P2040DN (браузер)"                 
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

# Хэш-таблица с прямыми ссылками для скачивания
$DriverUrls = @{
    "Kyocera" = @{
        "TWAIN Driver (драйвер для сканирования)" = "https://github.com/Fenebutik/Drivers-for-MFY/raw/refs/heads/main/KyoceraTWAINDriver2.1.2822_1.4rc9.exe"
    }

    "Brother" = @{
    }

    "HP" = @{
    }
}

# Хэш-таблица с именами файлов для сохранения
$DriverFilenames = @{
    "Kyocera" = @{
        "TWAIN Driver (драйвер для сканирования)" = "Kyocera_TWAIN_Driver_2.1.2822_1.4rc9.exe"
    }
    "Brother" = @{
    }
    "HP" = @{
    }
}

# Простые ASCII функции для меню
function Write-MenuHeader {
    param([string]$Title)
    $width = 50
    $line = '=' * $width
    $padding = [Math]::Max(0, ($width - $Title.Length - 2)) / 2
    $leftPad = [Math]::Floor($padding)
    $rightPad = $width - $Title.Length - 2 - $leftPad
    
    Write-Host "+$($line)+" -ForegroundColor DarkCyan
    Write-Host "|" -NoNewline -ForegroundColor DarkCyan
    Write-Host ("{0}{1}{2}" -f (' ' * $leftPad), $Title, (' ' * $rightPad)) -NoNewline -ForegroundColor Cyan
    Write-Host "|" -ForegroundColor DarkCyan
    Write-Host "+$($line)+" -ForegroundColor DarkCyan
    Write-Host ""
}

function Write-VendorBlock {
    param([int]$Number, [string]$VendorName)
    $fixedWidth = 30
    $content = " $Number. $VendorName "
    
    # Выравниваем по центру
    $padding = $fixedWidth - $content.Length
    $leftPad = [Math]::Floor($padding / 2)
    $rightPad = $padding - $leftPad
    
    $topLine = '+' + ('-' * ($fixedWidth - 2)) + '+'
    $middleLine = '|' + (' ' * $leftPad) + $content + (' ' * $rightPad) + '|'
    $bottomLine = '+' + ('-' * ($fixedWidth - 2)) + '+'
    
    Write-Host "  $topLine" -ForegroundColor DarkYellow
    Write-Host "  $middleLine" -ForegroundColor Yellow
    Write-Host "  $bottomLine" -ForegroundColor DarkYellow
}

function Write-PrinterItem {
    param([int]$Number, [string]$Model)
    Write-Host ("    {0,2}" -f $Number) -NoNewline -ForegroundColor Green
    Write-Host " | " -NoNewline -ForegroundColor Gray
    Write-Host $Model -ForegroundColor White
}

# Функция для проверки интернет-соединения
function Test-InternetConnection {
    try {
        $test = Test-NetConnection -ComputerName "github.com" -Port 443 -InformationLevel Quiet
        return $test
    }
    catch {
        return $false
    }
}

# Функция для ускоренной загрузки и установки
function Install-PrinterDriver {
    param(
        [string]$Vendor,
        [string]$Model,
        [string]$DownloadUrl,
        [string]$Filename
    )
    
    $DownloadPath = Join-Path -Path $env:TEMP -ChildPath $Filename
    
    Write-Host "[Инфо] Начинаю загрузку: $Vendor $Model" -ForegroundColor Cyan
    Write-Host "[Инфо] Источник: $DownloadUrl" -ForegroundColor Gray
    
    try {
        # Проверяем интернет-соединение
        if (-not (Test-InternetConnection)) {
            Write-Host "[Ошибка] Отсутствует интернет-соединение!" -ForegroundColor Red
            Write-Host "[Инфо] Проверьте подключение к сети и повторите попытку." -ForegroundColor Yellow
            return
        }
        
        # Проверяем, не скачан ли уже файл
        if (Test-Path $DownloadPath) {
            Write-Host "[Инфо] Файл уже существует локально." -ForegroundColor Green
            Write-Host "[Вопрос] Использовать существующий файл? (Y/N)" -ForegroundColor Cyan -NoNewline
            $useExisting = Read-Host
            
            if ($useExisting -in @('Y', 'y', 'Д', 'д')) {
                Write-Host "[Инфо] Использую существующий файл." -ForegroundColor Gray
            }
            else {
                # Удаляем и скачиваем заново
                Remove-Item -Path $DownloadPath -Force -ErrorAction SilentlyContinue
            }
        }
        
        # Засекаем время загрузки
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        # Загрузка файла
        if (-not (Test-Path $DownloadPath)) {
            Write-Host "[Инфо] Загрузка..." -ForegroundColor Gray
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $DownloadPath -UseBasicParsing
        }
        
        $stopwatch.Stop()
        
        if (Test-Path $DownloadPath) {
            $fileSize = (Get-Item $DownloadPath).Length / 1MB
            $downloadSpeed = $fileSize / $stopwatch.Elapsed.TotalSeconds
            
            Write-Host "[Успех] Файл загружен за $($stopwatch.Elapsed.ToString('mm\:ss'))" -ForegroundColor Green
            Write-Host "[Инфо] Размер: $($fileSize.ToString('F2')) MB | Скорость: $($downloadSpeed.ToString('F2')) MB/сек" -ForegroundColor Gray
            Write-Host "[Инфо] Путь: $DownloadPath" -ForegroundColor Gray
            
            # Проверяем тип файла и запускаем установку
            $ext = [System.IO.Path]::GetExtension($DownloadPath).ToLower()
            
            Write-Host "`n[Инфо] Запускаю установку..." -ForegroundColor Yellow
            
            switch ($ext) {
                '.exe' {
                    Start-Process -FilePath $DownloadPath -Wait
                }
                '.msi' {
                    Start-Process "msiexec.exe" -ArgumentList "/i `"$DownloadPath`" /quiet /norestart" -Wait
                }
                default {
                    Start-Process -FilePath $DownloadPath -Wait
                }
            }
            
            Write-Host "[Инфо] Установка завершена." -ForegroundColor Green
            
            # Предлагаем удалить временный файл
            Write-Host "`n[Вопрос] Удалить временный файл? (Y/N)" -ForegroundColor Cyan -NoNewline
            $deleteChoice = Read-Host
            
            if ($deleteChoice -in @('Y', 'y', 'Д', 'д', 'Yes', 'yes')) {
                Remove-Item -Path $DownloadPath -Force -ErrorAction SilentlyContinue
                Write-Host "[Инфо] Временный файл удален." -ForegroundColor Gray
            }
        }
        else {
            Write-Host "[Ошибка] Не удалось загрузить файл." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "[Ошибка] Не удалось загрузить или установить драйвер." -ForegroundColor Red
        Write-Host "[Детали] $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        $ProgressPreference = 'Continue'
    }
}

# Функция для отображения меню выбора производителя
function Show-VendorMenu {
    Clear-Host
    Write-MenuHeader -Title "УСТАНОВЩИК ДРАЙВЕРОВ ПРИНТЕРОВ"
    
    Write-Host "  +--------------------------------------+" -ForegroundColor DarkMagenta
    Write-Host "  |   ВЫБЕРИТЕ ПРОИЗВОДИТЕЛЯ             |" -ForegroundColor Magenta
    Write-Host "  +--------------------------------------+" -ForegroundColor DarkMagenta
    Write-Host ""
    
    $vendorNumber = 1
    foreach ($vendor in $PrintersByVendor.Keys) {
        Write-VendorBlock -Number $vendorNumber -VendorName $vendor
        $vendorNumber++
    }
    
    Write-Host ""
    Write-Host "  =======================================" -ForegroundColor DarkGray
    Write-Host ("    {0,2}" -f 0) -NoNewline -ForegroundColor Green
    Write-Host " | " -NoNewline -ForegroundColor Gray
    Write-Host "Выход" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  =======================================" -ForegroundColor DarkCyan
    
    $choice = Read-Host "`n  Введите номер производителя"
    
    # ========== ПАСХАЛКА ==========
    if ($choice -eq '1488') {
        Write-Host "`n"
        Write-Host "   +--------------------------------+" -ForegroundColor Red
        Write-Host "   |          ПАСХАЛКО              |" -ForegroundColor Red
        Write-Host "   +--------------------------------+" -ForegroundColor Red
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
    
    Write-Host "  +--------------------------------------+" -ForegroundColor DarkMagenta
    Write-Host ("  |   ПРОИЗВОДИТЕЛЬ: {0,-18}           |" -f $SelectedVendor) -ForegroundColor Magenta
    Write-Host "  +--------------------------------------+" -ForegroundColor DarkMagenta
    Write-Host ""
    
    $models = $PrintersByVendor[$SelectedVendor]
    $modelNumber = 1
    
    foreach ($model in $models) {
        Write-PrinterItem -Number $modelNumber -Model $model
        $modelNumber++
    }
    
    Write-Host ""
    Write-Host "  =======================================" -ForegroundColor DarkGray
    Write-Host ("    {0,2}" -f 0) -NoNewline -ForegroundColor Green
    Write-Host " | " -NoNewline -ForegroundColor Gray
    Write-Host "Назад" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  =======================================" -ForegroundColor DarkCyan
    
    $choice = Read-Host "`n  Введите номер модели"
    return $choice
}

# Функция для получения action по выбранной модели (для обратной совместимости)
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
            
            # Проверяем, есть ли прямая ссылка для этой модели
            if ($DriverUrls[$currentVendor] -and $DriverUrls[$currentVendor][$selectedModel]) {
                $downloadUrl = $DriverUrls[$currentVendor][$selectedModel]
                $filename = $DriverFilenames[$currentVendor][$selectedModel]
                
                # Устанавливаем драйвер
                Install-PrinterDriver -Vendor $currentVendor -Model $selectedModel -DownloadUrl $downloadUrl -Filename $filename
            }
            else {
                # Используем старую логику для особых случаев
                $action = Get-ActionForModel -Vendor $currentVendor -Model $selectedModel
                
                switch ($action) {
                    '1' {
                        # Kyocera TWAIN Driver
                        Install-PrinterDriver -Vendor $currentVendor -Model $selectedModel `
                            -DownloadUrl "https://github.com/Fenebutik/Drivers-for-MFY/raw/refs/heads/main/KyoceraTWAINDriver2.1.2822_1.4rc9.exe" `
                            -Filename "Kyocera_TWAIN_Driver_2.1.2822_1.4rc9.exe"
                    }
                    '2' {
                        # Яндекс.Диск ссылка
                        $DownloadPageUrl = "https://disk.yandex.ru/d/YFavU20LUBodgA"
                        Write-Host "[Инфо] Открываю страницу загрузки в браузере..." -ForegroundColor Gray
                        try {
                            Start-Process "msedge.exe" -ArgumentList $DownloadPageUrl -ErrorAction Stop
                            Write-Host "[Успех] Страница открыта. Скачайте файл вручную." -ForegroundColor Green
                        }
                        catch {
                            Start-Process $DownloadPageUrl
                        }
                    }
                    default {
                        Write-Host "[Инфо] Для этой модели пока нет автоматической установки." -ForegroundColor Yellow
                        Write-Host "      Свяжитесь с администратором для добавления драйвера." -ForegroundColor Gray
                    }
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
