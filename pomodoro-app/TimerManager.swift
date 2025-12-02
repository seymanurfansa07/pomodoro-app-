import Foundation
import Combine

class TimerManager: ObservableObject {

    // Timer'ın durumları
    enum TimerState {
        case idle
        case running
        case paused
        case finished
    }

    // UI'nın gözlemlediği değişkenler
    @Published var remainingTime: TimeInterval
    @Published var state: TimerState = .idle

    // İç ayarlar
    private var timer: Timer?
    private let workDuration: TimeInterval
    private let breakDuration: TimeInterval
    private var isWorkSession: Bool = true

    // Varsayılan: 25 dk çalışma, 5 dk mola
    init(workDurationMinutes: Int = 25,
         breakDurationMinutes: Int = 5) {

        self.workDuration = TimeInterval(workDurationMinutes * 60)
        self.breakDuration = TimeInterval(breakDurationMinutes * 60)
        self.remainingTime = self.workDuration        // başlangıçta 25 dk
    }

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

    /// Timer'ı başlat
    private func startTimer() {
        state = .running
        timer?.invalidate()

        // Her 1 saniyede bir tick çalışacak
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    /// Her saniyede çağrılır
    private func tick() {
        guard remainingTime > 0 else {
            timer?.invalidate()
            timer = nil
            state = .finished
            return
        }
        remainingTime -= 1
    }

    /// Timer'ı duraklat
    func pause() {
        guard state == .running else { return }
        timer?.invalidate()
        timer = nil
        state = .paused
    }

    /// Duraklatılmış timer'ı devam ettir
    func resume() {
        guard state == .paused else { return }
        startTimer()
    }

    /// Timer'ı sıfırla (bulunduğu oturuma göre süreyi başa al)
    func reset() {
        timer?.invalidate()
        timer = nil
        remainingTime = isWorkSession ? workDuration : breakDuration
        state = .idle
    }

    deinit {
        timer?.invalidate()
    }
}

