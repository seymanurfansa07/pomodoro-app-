import Foundation
import Combine

class TimerManager: ObservableObject {
    // Timer’ın durumları
    enum TimerState {
        case idle
        case running
        case paused
        case finished
    }

    // Yayınlanan değişkenler (UI bunları gözlemler)
    @Published var remainingTime: TimeInterval = 25 * 60  // 25 dakika varsayılan
    @Published var state: TimerState = .idle

    private var timer: Timer?
    private var workDuration: TimeInterval = 25 * 60   // 25 dakika
    private var breakDuration: TimeInterval = 5 * 60   // 5 dakika
    private var isWorkSession: Bool = true

    // MARK: - Timer Kontrolleri

    /// Çalışma süresini başlat
    func startWork() {
        isWorkSession = true
        remainingTime = workDuration
        startTimer()
    }

    /// Mola süresini başlat
    func startBreak() {
        isWorkSession = false
        remainingTime = breakDuration
        startTimer()
    }

    /// Timer’ı başlat
    private func startTimer() {
        state = .running
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.tick()
        }
    }

    /// Her saniyede çağrılan fonksiyon
    private func tick() {
        guard remainingTime > 0 else {
            timer?.invalidate()
            timer = nil
            state = .finished
            return
        }
        remainingTime -= 1
    }

    /// Timer’ı duraklat
    func pause() {
        guard state == .running else { return }
        timer?.invalidate()
        timer = nil
        state = .paused
    }

    /// Timer’ı yeniden başlat (kaldığı yerden devam)
    func resume() {
        guard state == .paused else { return }
        startTimer()
    }

    /// Timer’ı sıfırla
    func reset() {
        timer?.invalidate()
        timer = nil
        remainingTime = isWorkSession ? workDuration : breakDuration
        state = .idle
    }
}
