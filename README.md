# JustWater

JustWater — iOS-приложение для отслеживания количества выпитой воды за день.

Приложение помогает поставить дневную цель, быстро добавлять выпитую воду, смотреть историю и отслеживать, в какие дни цель была достигнута.

## English Summary

JustWater is an iOS app for tracking daily water intake.

The app helps users set a daily hydration goal, quickly log water and other drinks, review hydration history, configure reminders, and track goal completion over time.

## App Store

JustWater доступен в App Store:

[Скачать JustWater](https://apps.apple.com/app/justwater-hydration-tracker/id6775974283)

JustWater is available on the App Store:

[Download JustWater](https://apps.apple.com/app/justwater-hydration-tracker/id6775974283)

## Скриншоты

<p align="center">
  <img src="Screenshots/homeDark.jpg" width="220" />
  <img src="Screenshots/homeLight.jpg" width="220" />
  <img src="Screenshots/addDark.jpg" width="220" />
</p>

<p align="center">
  <img src="Screenshots/historyDayLight.jpg" width="220" />
  <img src="Screenshots/addHistoryLight.jpg" width="220" />
  <img src="Screenshots/historyDark.jpg" width="220" />
</p>

<p align="center">
  <img src="Screenshots/historyLight.jpg" width="220" />
  <img src="Screenshots/settingDark.jpg" width="220" />
  <img src="Screenshots/lastStepLight.jpg" width="220" />
</p>

## Что есть в приложении

- добавление воды быстрыми кнопками;
- добавление записи вручную;
- выбор типа напитка;
- расчёт дневной цели;
- изменение дневной цели;
- история за день, неделю, месяц и год;
- статистика по достигнутым целям;
- текущая серия дней;
- undo для добавления и удаления записей;
- локальные напоминания о воде;
- настройки темы;
- настройка haptics;
- onboarding при первом запуске;
- локализация на русский и английский языки.

## Стек

- Swift 6
- SwiftUI
- SwiftData
- Observation
- UserNotifications
- Charts
- OSLog
- XCTest

## Архитектура

- SwiftUI + MVVM
- Feature-first структура
- Dependency Injection через AppFactory
- SwiftData persistence layer
- Unit/integration tests for core business logic

## Requirements

- iOS 17+
- Xcode 26+
- SwiftData

## Note

JustWater предназначен для общего отслеживания привычки пить воду и не является медицинской рекомендацией.
