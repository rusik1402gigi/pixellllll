# PixelPlayer for iOS 🎵

Нативный порт современного музыкального плеера **PixelPlayer** (Android Material 3 Expressive) для **iPhone и iPad**, написанный на **Swift 5 / SwiftUI**.

---

## 🌟 Ключевые возможности

* **Фирменный дизайн Material 3 Expressive:**
  * **Волновой слайдер (`WavyProgressSlider`):** динамическая синусоидальная волна в прогресс-баре во время воспроизведения, плавно затухающая при паузе или перемотке.
  * **Динамическая тема (Dynamic Theme):** интеллектуальный анализатор палитры (`ColorExtractor`), подстраивающий фоновые градиенты, карточки и акцентные цвета под обложку текущего альбома.
  * **Анимации и тактильный отклик (Haptic Feedback):** выразительный отклик при скраббинге, паузе и переключении режимов.
* **Синхронизированные караоке-тексты (LRCLIB):**
  * Автоматический поиск и загрузка синхронизированных текстов через открытый API [LRCLIB](https://lrclib.net/).
  * Плавный автоскроллинг активной строки в такт музыке.
  * Возможность нажать на любую строчку текста для мгновенной перемотки песни.
* **Полноценный аудио-движок iOS (AVFoundation & MediaPlayer):**
  * Фоновое воспроизведение (работает при заблокированном экране и при сворачивании).
  * Интеграция с экраном блокировки, Dynamic Island и Control Center (`MPNowPlayingInfoCenter`, `MPRemoteCommandCenter`).
  * Поддержка AirPlay (трансляция на HomePod, Apple TV, внешние колонки).
  * Поддержка форматов: **FLAC, MP3, M4A, ALAC, WAV, AAC**.
* **Удобное управление локальной музыкой:**
  * **Поддержка приложения «Файлы» (Files app):** встроенный импорт треков.
  * **Общий доступ через iTunes / Finder (`UIFileSharingEnabled`):** можно подключить iPhone кабелем к компьютеру (Windows или Mac) и просто перетащить папку с музыкой в папку PixelPlayer.

---

## 🚀 Как получить `.ipa` файл и установить на iPhone

Так как компиляция нативного iOS-кода в файл `.ipa` требует среды Apple SDK (macOS), в репозиторий уже встроен **готовый автоматический робот сборки (GitHub Actions)**. Он бесплатно компилирует проект на Mac-серверах GitHub и отдает готовый `.ipa` файл!

### Шаг 1: Загрузка проекта на ваш GitHub

1. Откройте терминал в папке `PixelPlayer-iOS`:
   ```bash
   cd PixelPlayer-iOS
   git init
   git add .
   git commit -m "Initial commit of PixelPlayer iOS"
   ```
2. Создайте новый пустой репозиторий на [GitHub](https://github.com/new) (например, `PixelPlayer-iOS`).
3. Привяжите и отправьте код:
   ```bash
   git remote add origin https://github.com/ВАШ_НИК/PixelPlayer-iOS.git
   git branch -M main
   git push -u origin main
   ```

### Шаг 2: Скачивание готового `.ipa`

1. Зайдите во вкладку **Actions** в вашем репозитории на GitHub.
2. Вы увидите запущенный воркфлоу **"Build PixelPlayer iOS IPA"**.
3. Дождитесь окончания сборки (обычно занимает 1–2 минуты).
4. Внизу страницы сборки в блоке **Artifacts** скачайте архив **`PixelPlayer-iOS-IPA.zip`**.
5. Распакуйте его — внутри будет готовый файл **`PixelPlayer.ipa`**!

---

## 📲 Как установить `.ipa` на iPhone

Вы можете установить полученный `.ipa` любым привычным способом сайдлоадинга:

1. **Sideloadly (Windows / Mac) — Самый простой способ:**
   * Скачайте [Sideloadly](https://sideloadly.io/).
   * Подключите iPhone к ПК по проводу.
   * Перетащите файл `PixelPlayer.ipa` в окно Sideloadly, введите ваш Apple ID и нажмите **Start**.
2. **AltStore:**
   * Откройте AltStore на телефоне, нажмите `+` и выберите `PixelPlayer.ipa`.
3. **TrollStore:**
   * Если у вас iOS с поддержкой TrollStore, просто откройте `.ipa` через TrollStore для вечной установки без переподписания.
4. **Scarlet / Esign:**
   * Установка напрямую с устройства при наличии рабочего сертификата.

---

## 📂 Структура проекта

```text
PixelPlayer-iOS/
├── .github/workflows/
│   └── build-ipa.yml              # Автосборка .ipa на macOS-раннере GitHub
├── PixelPlayer.xcodeproj/          # Проект Xcode
│   └── project.pbxproj
└── PixelPlayer/
    ├── App/
    │   └── PixelPlayerApp.swift    # Точка входа в приложение
    ├── Models/
    │   ├── Track.swift             # Модель трека и метаданных
    │   └── LyricLine.swift         # Модель строки караоке-текста
    ├── Services/
    │   ├── AudioPlayerManager.swift# AVPlayer, очереди, фоновое воспроизведение
    │   ├── ColorExtractor.swift    # Генерация Material You палитры из обложки
    │   ├── LrcLyricsService.swift  # Загрузка и парсинг текстов с LRCLIB
    │   └── MusicLibraryManager.swift# Сканирование файлов и чтение ID3-тегов
    ├── Views/
    │   ├── Common/
    │   │   └── DocumentPicker.swift# Импорт аудиофайлов из приложения «Файлы»
    │   ├── Library/
    │   │   └── LibraryView.swift   # Экран медиатеки (Песни, Альбомы, Артисты)
    │   ├── Lyrics/
    │   │   └── LyricsSheetView.swift# Караоке-экран синхронизированных текстов
    │   ├── Main/
    │   │   └── MainTabView.swift   # Главная навигация и Dock мини-плеера
    │   ├── Player/
    │   │   ├── FullPlayerView.swift# Основной полноэкранный плеер
    │   │   ├── MiniPlayerView.swift# Компактный плавающий плеер
    │   │   └── WavyProgressSlider.swift # Фирменный волнистый ползунок
    │   ├── Queue/
    │   │   └── QueueSheetView.swift# Очередь треков с перемешиванием
    │   └── Settings/
    │       └── SettingsView.swift  # Настройки тем, тактильности и кэша
    └── Resources/
        ├── Assets.xcassets         # Иконки и системные цвета
        └── Info.plist              # Разрешения аудио-сессии и файлового доступа
```
