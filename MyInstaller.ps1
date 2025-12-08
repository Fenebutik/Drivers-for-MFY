# MyInstaller.ps1 - Основной скрипт с меню
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    Моя утилита загрузки" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Функция для загрузки файла
function Download-File {
    param([string]$url, [string]$output)
    try {
        Write-Host "Загружаем: $url" -ForegroundColor Yellow
        Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
        Write-Host "Файл сохранен: $output" -ForegroundColor Green
    } catch {
        Write-Host "Ошибка загрузки: $_" -ForegroundColor Red
    }
}

# Главное меню
while ($true) {
    Write-Host "`nВыберите действие:" -ForegroundColor White
    Write-Host "    1) Скачать программу А"
    Write-Host "    2) Скачать набор скриптов Б"
    Write-Host "    3) Показать справку"
    Write-Host "    0) Выход`n"

    $choice = Read-Host "Ваш выбор (0-3)"

    switch ($choice) {
        '1' {
            Download-File -url "https://example.com/program.zip" -output "$env:USERPROFILE\Downloads\program.zip"
        }
        '2' {
            Download-File -url "https://example.com/scripts.tar.gz" -output "$env:USERPROFILE\Downloads\scripts.tar.gz"
        }
        '3' {
            Write-Host "Справка: этот инструмент загружает необходимые файлы."
        }
        '0' {
            Write-Host "Выход." -ForegroundColor Cyan
            exit
        }
        default {
            Write-Host "Неверный выбор." -ForegroundColor Red
        }
    }
}