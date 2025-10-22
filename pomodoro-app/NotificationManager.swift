//
//  NotificationManager.swift
//  Pomodoro
//
//  Tek dosyada: izin, planlama, iptal, delegate
//

import Foundation
import UserNotifications
import UIKit

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private override init() { super.init() }

    // Uygulama açılırken bir kez çağır: delegate atansın
    func configure() {
        UNUserNotificationCenter.current().delegate = self
    }

    // İzin iste (isteğe bağlı completion)
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, err in
            if let err = err { print("Notif auth error:", err) }
            completion?(granted)
        }
    }

    // Şu andan X saniye sonra yerel bildirim planla
    @discardableResult
    func schedulePomodoroEnd(
        after seconds: TimeInterval,
        title: String,
        body: String,
        soundOn: Bool = true,
        id: String = UUID().uuidString
    ) -> String {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        if soundOn { content.sound = .default }

        // minimum 1 sn
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { err in
            if let err = err { print("Schedule error:", err) }
        }
        return id
    }

    // Belirli tarihte planlamak istersen (opsiyonel yardımcı)
    @discardableResult
    func scheduleAt(date: Date, title: String, body: String, soundOn: Bool = true, id: String = UUID().uuidString) -> String {
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        if soundOn { content.sound = .default }
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        return id
    }

    // Bekleyen bütün bildirimleri sil
    func clearPending() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // Belirli id’leri iptal et
    func cancel(ids: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // Kullanıcı izni reddettiyse sistem Ayarları’nı aç
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // Uygulama açıkken de banner + ses göster
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
