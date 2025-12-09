# Настройка консоли
$Host.UI.RawUI.WindowTitle = "Установщик драйверов принтеров"
Clear-Host

# Структура данных: Производитель -> Список моделей
# ВНИМАНИЕ: "Особые" драйверы теперь внутри Kyocera
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

# Функции псевдографики для меню
function Write-MenuHeader {
    param([string]$Title)
    $fullTitle = "  $Title  "
    $line = '═' * ($Host.UI.RawUI.WindowSize.Width - 4)
    Write-Host "╔$($line)╗" -ForegroundColor DarkCyan
    Write-Host "║" -NoNewline -ForegroundColor DarkCyan
    Write-Host "$fullTitle" -NoNewline -ForegroundColor Cyan
    Write-Host "$(' ' * ($line.Length - $fullTitle.Length))║" -ForegroundColor DarkCyan
    Write-Host "╚$($line)╝" -ForegroundColor DarkCyan
    Write-Host ""
}

function Write-VendorBlock {
    param([string]$VendorName)
    # Фиксированная ширина для всех заголовков (можно изменить)
    $fixedWidth = 20
    $paddedName = "  $VendorName  ".PadRight($fixedWidth, ' ')
    $line = '─' * $fixedWidth
    Write-Host "  ┌$($line)┐" -ForegroundColor DarkYellow
    Write-Host "  │$($paddedName)│" -ForegroundColor Yellow
    Write-Host "  └$($line)┘" -ForegroundColor DarkYellow
}

function Write-PrinterItem {
    param([int]$Number, [string]$Vendor, [string]$Model)
    Write-Host ("    {0,2}" -f $Number) -NoNewline -ForegroundColor Green
    Write-Host " │ " -NoNewline -ForegroundColor Gray
    Write-Host "$Vendor $Model" -ForegroundColor White
}

# Список ВСЕХ пунктов меню в порядке их отображения.
# ВАЖНО: Теперь особые драйверы (пункты 1 и 2) внутри Kyocera
$AllMenuItems = @()

# Собираем ВСЕ пункты из структурированного списка в плоский массив
$itemCounter = 1 # Начинаем нумерацию с 1
foreach ($vendor in $PrintersByVendor.Keys) {
    foreach ($model in $PrintersByVendor[$vendor]) {
        # Определяем Action на основе текста модели
        $action = 'NEW_PRINTER'
        if ($model -eq "TWAIN Driver (драйвер для сканирования)") {
            $action = '1'
        }
        elseif ($model -eq "Ecosys P2040DN (браузер)") {
            $action = '2'
        }
        
        $AllMenuItems += @{
            DisplayText = "$vendor $model"
            Action = $action
            Vendor = $vendor
            Model = $model
        }
        $itemCounter++
    }
}

# ==================== ГЛАВНЫЙ ЦИКЛ МЕНЮ ====================
while ($true) {
    Clear-Host
    Write-MenuHeader -Title "УСТАНОВЩИК ДРАЙВЕРОВ ПРИНТЕРОВ"

    # Вывод всех принтеров, сгруппированных по производителям
    $currentIndex = 0
    foreach ($vendor in $PrintersByVendor.Keys) {
        Write-VendorBlock -VendorName $vendor
        $vendorModels = $PrintersByVendor[$vendor]
        foreach ($model in $vendorModels) {
            Write-PrinterItem -Number ($currentIndex + 1) -Vendor $vendor -Model $model
            $currentIndex++
        }
        Write-Host ""
    }

    # Вывод пункта "Выход"
    Write-Host "  ════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ("    {0,2}" -f 0) -NoNewline -ForegroundColor Green
    Write-Host " │ " -NoNewline -ForegroundColor Gray
    Write-Host "Выход" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ════════════════════════════════" -ForegroundColor DarkCyan

    # Запрос выбора
    $choice = Read-Host "`n  Введите номер пункта"

    # ========== ПАСХАЛКА ==========
    if ($choice -eq '1488') {
        Write-Host "`n"
        Write-Host "   ╔════════════════════════════════╗" -ForegroundColor Red
        Write-Host "   ║          ПАСХАЛКО             ║" -ForegroundColor Red
        Write-Host "   ╚════════════════════════════════╝" -ForegroundColor Red
        Write-Host "`nНажмите любую клавишу, чтобы вернуться в меню..." -ForegroundColor Gray
        [Console]::ReadKey($true) | Out-Null
        continue # Возвращаемся в начало цикла (показываем меню снова)
    }

    # Обработка выбора
    switch ($choice) {
        '0' {
            Write-Host "`n[Инфо] Выход." -ForegroundColor Cyan
            exit
        }
        { [int]$_ -ge 1 -and [int]$_ -le $AllMenuItems.Count } {
            $selectedItem = $AllMenuItems[[int]$choice - 1]
            Write-Host "`n[Инфо] Выбрано: $($selectedItem.DisplayText)" -ForegroundColor Yellow
            Write-Host ""

            # ВАЖНО: Здесь старое ядро логики. Action определяется автоматически
            switch ($selectedItem.Action) {
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
        default {
            Write-Host "`n[Ошибка] Неверный выбор: $choice" -ForegroundColor Red
            Write-Host "Нажмите любую клавишу, чтобы продолжить..." -ForegroundColor Gray
            [Console]::ReadKey($true) | Out-Null
        }
    }
}
