# PixelPlayer for iOS 🎵

Плеер в стиле **Google Pixel (Material You / Material 3 Expressive)** и **Liquid Glass (Жидкое стекло)** для iPhone (iOS), с автоматической сборкой `.ipa` через GitHub Actions.

## Особенности
- 🌊 **Волнистый ползунок воспроизведения (Squiggly Waveform)** в стиле Google Pixel / Android 13+.
- 🪟 **Тема Liquid Glass (Жидкое стекло)** с размытием фона и закруглёнными матовыми плашками.
- 📱 **Тема Google Pixel** с оригинальной геометрией кнопок (сквирклы) и палитрой Material You.
- 🎧 **Воспроизведение в фоне (Background Audio)**: музыка продолжает играть при заблокированном экране iPhone.
- 📂 **Оффлайн и локальные файлы**: импорт музыки из приложения «Файлы» (iCloud Drive / локальное хранилище iPhone). Поддержка MP3, FLAC, WAV, M4A, AAC, OGG.
- 🎚️ **10-полосный эквалайзер**, усиление баса (Bass Boost) и реверберация.
- 📳 **Тактильный отклик (iOS Haptics)** при взаимодействии с элементами управления.

## Сборка .ipa через GitHub Actions
1. Создайте новый репозиторий на GitHub.
2. Загрузите файлы этого проекта в репозиторий:
   ```bash
   git init
   git add .
   git commit -m "Initial commit for PixelPlayer iOS"
   git branch -M main
   git remote add origin https://github.com/ВАШ_ЛОГИН/PixelPlayer-iOS.git
   git push -u origin main
   ```
3. Перейдите во вкладку **Actions** в репозитории на GitHub.
4. Выберите workflow **Build iOS IPA (PixelPlayer)** -> нажмите **Run workflow**.
5. Через 3–4 минуты сборка завершится. В блоке **Artifacts** скачайте **`PixelPlayer-iOS-IPA`** (файл `PixelPlayer.ipa`).

## Установка IPA на iPhone
Готовый `.ipa` можно установить на любой iPhone без компьютера и без платного аккаунта разработчика:
- **Scarlet** (прямо через Safari на iPhone);
- **AltStore / SideStore** (бесплатная подпись через Apple ID);
- **Sideloadly** (установка через ПК/ноутбук);
- **TrollStore** (для поддерживаемых версий iOS).
