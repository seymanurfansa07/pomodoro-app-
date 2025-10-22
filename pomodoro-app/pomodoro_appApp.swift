//
//  pomodoro_appApp.swift
//  pomodoro-app
//
//  Created by şeyma nur fansa on 15.10.2025.
//

import SwiftUI

@main
struct pomodoro_appApp: App {
    @StateObject private var settingsStore = SettingsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsStore)
                .onAppear {
                    // ÖNEMLİ: delegate burada atanıyor, foreground'da banner için şart
                    NotificationManager.shared.configure()
                    NotificationManager.shared.requestAuthorization()
                }
        }
    }
}
