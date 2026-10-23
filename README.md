# NavWidget - Floating Navigation Widget

Floating widget for Android that displays Google Maps (and other navigation apps) turn-by-turn navigation info on top of other apps.

## Features

- **Floating Widget** — draggable navigation card overlay
- **Notification Parsing** — reads navigation info from Google Maps notifications
- **Multi-App Support** — Google Maps, Waze, Mapbox, MapQuest
- **Persistent Position** — widget position is saved between sessions
- **Auto-Hide** — option to hide when inside Maps app

## Requirements

- Android 8.0+ (API 26+)
- Google Maps (or supported navigation app)

## Permissions Needed

1. **Notification Access** — to read navigation notifications
2. **Display Over Other Apps** — for the floating widget
3. **Usage Access** (optional) — to detect when Maps is in foreground
4. **Wake Lock** — keeps the widget running in background

## Setup

1. Open the app
2. Grant **Notification Access** (tap "Enable Notifications" → find "Nav Widget")
3. Grant **Overlay Permission** (tap "Enable Overlay" → allow)
4. Tap **Start Widget**
5. Open Google Maps and start navigation
6. The floating card will appear with navigation info

## Build

Open the project in **Android Studio** and build normally:
```
Build → Build Bundle(s) / APK(s) → Build APK(s)
```

Requires:
- Android Studio Hedgehog or later
- Android SDK 34
- Gradle 8.2+

## Project Structure

```
app/src/main/
├── java/com/navwidget/
│   ├── model/NavigationInfo.kt        # Navigation data model
│   ├── receiver/UsageStatsReceiver.kt # Usage stats broadcast receiver
│   ├── service/
│   │   ├── FloatingWidgetService.kt   # Foreground service + floating view
│   │   └── NotificationParserService.kt # Notification listener service
│   └── ui/MainActivity.kt            # Main activity / settings screen
└── res/
    ├── layout/
    │   ├── activity_main.xml          # Main screen layout
    │   └── layout_floating_card.xml   # Floating card layout
    └── drawable/                       # Icons and card background
```

## License

MIT
