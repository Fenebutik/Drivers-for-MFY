# Настройка консоли
$Host.UI.RawUI.WindowTitle = "Установщик драйверов принтеров"
Clear-Host

# ==================== ДАННЫЕ И ВИЗУАЛЬНЫЕ ФУНКЦИИ ====================
# Структура данных: Производитель -> Список моделей (убраны дубликаты)
$PrintersByVendor = [ordered]@{
    "Kyocera" = @(
        "Ecosys P2040DN",
        "Ecosys M2135dn",
        "Ecosys M3040dn",
        "Ecosys M2040dn",
        "MA2000"
    )
    "Brother" = @(
        "MFC-L2700DNR"
    )
    "HP" = @(
        "Laser MFP 136a",
        "LaserJet Pro MFP M125ra",
        "Laser MFP 137fnw",
        "LaserJet M236sdw"
    )
}

# Функции псевдографики для стильного меню
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
    $header = "  $VendorName  "
    Write-Host "  ┌$('─' * ($header.Length))┐" -ForegroundColor DarkYellow
    Write-Host "  │$header│" -ForegroundColor Yellow
    Write-Host "  └$('─' * ($header.Length))┘" -ForegroundColor DarkYellow
}

function Write-PrinterItem {
    param([int]$Number, [string]$Vendor, [string]$Model)
    $text = "$Vendor $Model"
    Write-Host ("    {0,2}" -f $Number) -NoNewline -ForegroundColor Green
    Write-Host " │ " -NoNewline -ForegroundColor Gray
    Write-Host $text -ForegroundColor White
}

# ==================== СОЗДАНИЕ ПЛОСКОГО СПИСКА ВСЕХ ПУНКТОВ ====================
# Список ВСЕХ пунктов меню в порядке их отображения.
# Первые два пункта — наши "особые" драйвера, которые уже были.
$AllMenuItems = @(
    # ПУНКТ 1: Существующий специальный драйвер Kyocera TWAIN
    @{
        DisplayText = "Kyocera TWAIN Driver";
        Action = '1' # Это триггер для switch в старой логике
    }
    # ПУНКТ 2: Существующий специальный драйвер для открытия в браузере
    @{
        DisplayText = "Kyocera Ecosys P2040DN (браузер)";
        Action = '2' # Это триггер для switch в старой логике
    }
)

# Добавляем ВСЕ принтеры из структурированного списка в плоский массив
$itemCounter = $AllMenuItems.Count + 1
foreach ($vendor in $PrintersByVendor.Keys) {
    foreach ($model in $PrintersByVendor[$vendor]) {
        $fullName = "$vendor $model"
        $AllMenuItems += @{
            DisplayText = $fullName;
            Action = 'NEW_PRINTER' # Маркер для новых пунктов (пока без своей логики)
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

    # Вывод наших двух первых "особых" пунктов
    Write-Host "  ┌───────────────────────┐" -ForegroundColor DarkMagenta
    Write-Host "  │   Специальные драйверы   │" -ForegroundColor Magenta
    Write-Host "  └───────────────────────┘" -ForegroundColor DarkMagenta
    for ($i = 0; $i -lt 2; $i++) {
        Write-Host ("    {0,2}" -f ($i + 1)) -NoNewline -ForegroundColor Green
        Write-Host " │ " -NoNewline -ForegroundColor Gray
        Write-Host $AllMenuItems[$i].DisplayText -ForegroundColor White
    }
    Write-Host ""

    # Вывод всех принтеров, сгруппированных по производителям
    $currentIndex = 2 # Начинаем с третьего пункта в общем списке
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
    Write-Host "  ════════════════════════════" -ForegroundColor DarkGray
    Write-Host ("    {0,2}" -f 0) -NoNewline -ForegroundColor Green
    Write-Host " │ " -NoNewline -ForegroundColor Gray
    Write-Host "Выход" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ════════════════════════════" -ForegroundColor DarkCyan

    # Запрос выбора
    $choice = Read-Host "`n  Введите номер пункта"

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

            # ВАЖНО: Здесь мы используем старое ядро логики.
            # Если Action = '1' или '2', выполняем старые проверенные блоки кода.
            # Если Action = 'NEW_PRINTER', пока просто сообщаем, что функция в разработке.
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
                    # --- СТАРЫЙ ПРОВЕРЕННЫЙ БЛОК ДЛЯ ПУНКТА '2' (Яндекс.Диск в браузере) ---
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
                    # --- ЗАГЛУШКА ДЛЯ НОВЫХ ПРИНТЕРОВ (логику добавите позже) ---
                    Write-Host "[Инфо] Функция установки для этого принтера в разработке." -ForegroundColor Yellow
                    Write-Host "      Чтобы добавить драйвер, обновите хэш-таблицу `$DriverUrls`" -ForegroundColor Gray
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
