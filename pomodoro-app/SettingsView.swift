//
//  SettingsView.swift
//  pomodoro-app
//
//  Created by şeyma nur fansa on 21.10.2025.
//

import SwiftUI
import Foundation
import Combine

// MARK: - Ayar Modeli
struct PomodoroSettings: Codable, Equatable {
    var focusMinutes: Int       = 25
    var shortBreakMinutes: Int  = 5
    var longBreakMinutes: Int   = 15
    var sessionsBeforeLong: Int = 4
    var soundEnabled: Bool      = true
    var notificationsEnabled: Bool = true
    var autoStartNext: Bool     = false

    // UI kısıtları
    static let focusRange       = 5...120
    static let shortBreakRange  = 1...30
    static let longBreakRange   = 5...60
    static let sessionsRange    = 2...8
}

// MARK: - Kalıcı Saklama (UserDefaults)
final class SettingsStore: ObservableObject {
    @Published var value: PomodoroSettings {
        didSet { save() }
    }

    private let key = "PomodoroSettings.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(PomodoroSettings.self, from: data) {
            value = decoded
        } else {
            value = PomodoroSettings()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func resetToDefaults() {
        value = PomodoroSettings()
    }
}

// MARK: - SwiftUI Ayarlar Ekranı
struct SettingsView: View {
    @ObservedObject var store: SettingsStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                // Süre Ayarları
                Section(header: Text("Süreler (dakika)")) {
                    Stepper("Odak: \(store.value.focusMinutes)",
                            value: $store.value.focusMinutes,
                            in: PomodoroSettings.focusRange)
                    Stepper("Kısa mola: \(store.value.shortBreakMinutes)",
                            value: $store.value.shortBreakMinutes,
                            in: PomodoroSettings.shortBreakRange)
                    Stepper("Uzun mola: \(store.value.longBreakMinutes)",
                            value: $store.value.longBreakMinutes,
                            in: PomodoroSettings.longBreakRange)
                    Stepper("Uzun moladan önce seans: \(store.value.sessionsBeforeLong)",
                            value: $store.value.sessionsBeforeLong,
                            in: PomodoroSettings.sessionsRange)
                }

                // Tercihler
                Section(header: Text("Tercihler")) {
                    Toggle("Sesi aç", isOn: $store.value.soundEnabled)
                    Toggle("Bildirimler", isOn: $store.value.notificationsEnabled)
                        .onChange(of: store.value.notificationsEnabled) { enabled in
                            if enabled {
                                NotificationManager.shared.requestAuthorization()
                            }
                        }
                    Toggle("Sonraki seansı otomatik başlat", isOn: $store.value.autoStartNext)
                }

                // Test Bildirimi / Sıfırla
                Section(footer: Text("Bildirim izni gerekirse burada tekrar isteyebilirsin.")) {
                    Button("Bildirim izni iste") {
                        NotificationManager.shared.requestAuthorization()
                    }
                    Button("Test bildirimi gönder") {
                        NotificationManager.shared.schedulePomodoroEnd(
                            after: 3,
                            title: "Test Bildirimi",
                            body: "Pomodoro bildirim sistemi çalışıyor 🎯"
                        )
                    }
                    Button(role: .destructive) {
                        store.resetToDefaults()
                    } label: {
                        Text("Varsayılanlara dön")
                    }
                }
            }
            .navigationTitle("Ayarlar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Bitti") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView(store: SettingsStore())
}

