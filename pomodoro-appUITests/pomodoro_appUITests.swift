import XCTest

final class PomodoroAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeScreenShowsFocusTitle() throws {
        let app = XCUIApplication()
        app.launch()

        // Ekranda "Odaklanma Zamanı" yazısını görüyor muyuz?
        XCTAssertTrue(app.staticTexts["Odaklanma Zamanı"].exists)
    }

    func testStartButtonExistsAndCanBeTapped() throws {
        let app = XCUIApplication()
        app.launch()

        // "Başlat" butonuna ulaş ve tıkla
        let startButton = app.buttons["Başlat"]
        XCTAssertTrue(startButton.exists, "Başlat butonu görünür olmalı")

        startButton.tap()
        // Burada ekstra assert koymak istersen koyabilirsin
        // Örn: state değiştiğinde çıkan başka bir text varsa onu kontrol edebilirsin
    }
}

