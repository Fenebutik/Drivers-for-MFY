# Настройка консоли
$Host.UI.RawUI.WindowTitle = "Установщик драйвера"
Clear-Host

# Основной цикл меню
while ($true) {
    # Отрисовка меню
    Write-Host "================================" -ForegroundColor Green
    Write-Host "    Драйвера для принтеров" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "     1. Kyocera TWAIN Driver" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "     0. Выход" -ForegroundColor Gray
    Write-Host ""
    Write-Host "================================" -ForegroundColor Green
    Write-Host ""

    # Запрос выбора
    $choice = Read-Host "Выберите"

    # Обработка выбора
    switch ($choice) {
        '0' {
            Write-Host "Выход." -ForegroundColor Cyan
            exit
        }
        '1' {
            # --- КОНФИГУРИРУЕМАЯ ЧАСТЬ: Настройки для Kyocera ---
            $DriverName = "Kyocera TWAIN Driver"
            # ССЫЛКА 1: Укажи прямую ссылку на скачивание .exe файла
            $DownloadUrl = "https://cdn.jsdelivr.net/gh/Fenebutik/Drivers-for-MFY@main/Kyocera%20TWAIN%20Driver_2.1.2822_1.4rc9.exe"
            # ИМЯ ФАЙЛА: Как он сохранится локально (можно оставить как в ссылке)
            $LocalFileName = "Kyocera_TWAIN_Driver_2.1.2822_1.4rc9.exe"
            # ПАПКА: Где сохранить (временная папка текущего пользователя)
            $DownloadPath = Join-Path -Path $env:TEMP -ChildPath $LocalFileName
            # --- Конец конфигурируемой части ---

            Write-Host "`n[Инфо] Выбран: $DriverName" -ForegroundColor Yellow
            Write-Host "[Инфо] Начинаю загрузку..." -ForegroundColor Gray

            try {
                # Скачивание файла
                Invoke-WebRequest -Uri $DownloadUrl -OutFile $DownloadPath -UseBasicParsing
                
                Write-Host "[Успех] Файл загружен в: $DownloadPath" -ForegroundColor Green
                Write-Host "Давай установи меня!" -ForegroundColor Yellow
                
                # Запуск установщика
                Start-Process -FilePath $DownloadPath -Wait
                
                Write-Host "[Инфо] Установка завершена (или была прервана пользователем)." -ForegroundColor Gray
            }
            catch {
                Write-Host "[Ошибка] Не удалось загрузить или запустить файл." -ForegroundColor Red
                Write-Host "[Детали] $($_.Exception.Message)" -ForegroundColor Red
            }

            Write-Host "`nНажмите любую клавишу, чтобы вернуться в меню..." -ForegroundColor Gray
            [Console]::ReadKey($true) | Out-Null
        }
        default {
            Write-Host "`nАААААА НИЧЕГО НЕТ!" -ForegroundColor Red
            Write-Host ""
            Write-Host "Нажмите любую клавишу, чтобы продолжить..." -ForegroundColor Gray
            [Console]::ReadKey($true) | Out-Null
        }
    }
}













