import XCTest
@testable import pomodoro_app   // Proje adın farklıysa burayı Xcode’daki ada göre düzelt

final class TimerManagerTests: XCTestCase {

    /// Testlerde TimerManager yaratmak için küçük yardımcı fonksiyon
    private func makeManager() -> TimerManager {
        return TimerManager(workDurationMinutes: 25,
                            breakDurationMinutes: 5)
    }

    // 1) Uygulama ilk açıldığında varsayılan durum testi
    func testInitialState_isIdleWithDefaultWorkTime() {
        let manager = makeManager()

        XCTAssertEqual(manager.state, .idle,
                       "Başlangıçta durum idle olmalı")
        XCTAssertEqual(manager.remainingTime, 25 * 60,
                       "Başlangıç süresi 25 dakika (1500 saniye) olmalı")
    }

    // 2) startWork çağrılınca çalışma süresi başlamalı
    func testStartWork_setsRunningAndWorkDuration() {
        let manager = makeManager()

        manager.startWork()

        XCTAssertEqual(manager.state, .running,
                       "startWork çağrılınca durum running olmalı")
        XCTAssertEqual(manager.remainingTime, 25 * 60,
                       "Çalışma süresi 25 dakika olarak ayarlanmalı")
    }

    // 3) startBreak çağrılınca mola süresi başlamalı
    func testStartBreak_setsRunningAndBreakDuration() {
        let manager = makeManager()

        manager.startBreak()

        XCTAssertEqual(manager.state, .running,
                       "startBreak çağrılınca durum running olmalı")
        XCTAssertEqual(manager.remainingTime, 5 * 60,
                       "Mola süresi 5 dakika olmalı")
    }

    // 4) reset çağrılınca bulunduğu oturum süresine dönmeli ve idle olmalı
    func testReset_restoresCurrentSessionAndIdleState() {
        let manager = makeManager()

        manager.startWork()   // önce çalışma başlat
        manager.reset()       // sonra sıfırla

        XCTAssertEqual(manager.state, .idle,
                       "reset’ten sonra durum tekrar idle olmalı")
        XCTAssertEqual(manager.remainingTime, 25 * 60,
                       "Süre tekrar 25 dakikaya dönmeli")
    }

    // 5) pause / resume state değişimini doğru yapmalı
    func testPauseAndResume_changesStateCorrectly() {
        let manager = makeManager()

        manager.startWork()
        manager.pause()

        XCTAssertEqual(manager.state, .paused,
                       "pause sonrasında durum paused olmalı")

        manager.resume()

        XCTAssertEqual(manager.state, .running,
                       "resume sonrasında durum yeniden running olmalı")
    }
}




