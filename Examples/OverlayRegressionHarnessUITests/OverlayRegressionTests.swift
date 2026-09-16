import XCTest

final class OverlayRegressionTests: XCTestCase {
    private var app: XCUIApplication!
    private let pickerChoices = [
        "Photo Library",
        "Take Photo",
        "Take Photo or Video",
        "Browse",
        "Photos"
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app = XCUIApplication()
        app.launch()
    }

    func testLocalFixtureAttachmentTapPresentsPicker() {
        app.buttons["harness.attachment"].tap()
        XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: 20))
        XCTAssertTrue(
            app.staticTexts["LOCAL FIXTURE READY"].waitForExistence(timeout: 5),
            "The harness did not load its inline local fixture"
        )

        let ask = app.buttons["Ask us a question"]
        if ask.waitForExistence(timeout: 8) {
            ask.tap()
        }

        let attach = app.buttons["Attach image"]
        XCTAssertTrue(attach.waitForExistence(timeout: 15))
        XCTAssertFalse(
            pickerChoiceExists(),
            "An attachment choice was already visible before tapping Attach image"
        )
        attach.tap()

        XCTAssertTrue(
            waitForPickerChoice(timeout: 8),
            "Attach image did not present a native attachment choice"
        )
    }

    func testTargetBlankLinkOpensBrowserAndPreservesChat() {
        app.buttons["harness.attachment"].tap()
        XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: 20))
        XCTAssertTrue(app.staticTexts["LOCAL FIXTURE READY"].waitForExistence(timeout: 5))

        let surveyLink = app.links["Open survey link"]
        XCTAssertTrue(surveyLink.waitForExistence(timeout: 5))
        surveyLink.tap()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        XCTAssertTrue(
            safari.wait(for: .runningForeground, timeout: 10),
            "The target=_blank HTTPS link did not open the system browser"
        )

        app.activate()
        XCTAssertTrue(
            app.staticTexts["LOCAL FIXTURE READY"].waitForExistence(timeout: 5),
            "Returning from the browser replaced or reset the chat WebView"
        )
        XCTAssertTrue(
            app.links["Open survey link"].isHittable,
            "The original chat was not interactive after returning from the browser"
        )
    }

    func testShowLauncherMakesLauncherInteractive() {
        app.buttons["harness.launcher"].tap()

        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 20))

        let launcher = webView.buttons.firstMatch
        XCTAssertTrue(launcher.waitForExistence(timeout: 15))
        XCTAssertTrue(launcher.isHittable, "showLauncher() did not expose an interactive launcher")
        launcher.tap()

        XCTAssertTrue(
            app.buttons["Attach image"].waitForExistence(timeout: 10),
            "Tapping the launcher did not open chat"
        )
    }

    func testInitializeOnlyPreservesHostAppearance() {
        app.buttons["harness.initializeOnly"].tap()

        let host = app.staticTexts["harness.initializeHost"]
        XCTAssertTrue(host.waitForExistence(timeout: 5))
        XCTAssertTrue(host.isHittable, "initialize() covered the host before open()")
        XCTAssertTrue(
            app.staticTexts["APPEARANCE PASS"].waitForExistence(timeout: 10),
            "initialize() changed the host status bar style"
        )
    }

    func testHostAlertAppearsAboveOpenChat() {
        app.buttons["harness.alert"].tap()

        let alert = app.alerts["HOST ALERT — MUST BE VISIBLE"]
        XCTAssertTrue(alert.waitForExistence(timeout: 15))
        alert.buttons["Reachable"].tap()
    }

    func testHostReplacementReattachesChatAndKeepsKeyboardWorking() {
        app.buttons["harness.keyboard"].tap()

        XCTAssertTrue(app.staticTexts["KEY WINDOW PASS"].waitForExistence(timeout: 15))
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["CHAT REATTACH PASS"].waitForExistence(timeout: 5),
            "The visible chat WebView was not attached to the replacement host window"
        )
        let field = app.textFields["harness.keyboardField"]
        XCTAssertTrue(
            waitForHittable(field, timeout: 5),
            "Closing reattached chat did not return interaction to the replacement host"
        )
        field.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3))
    }

    func testPortraitHostDoesNotRotateWithChatOpen() {
        app.buttons["harness.orientation"].tap()
        XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: 20))

        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(2)

        let frame = app.windows.firstMatch.frame
        XCTAssertLessThan(frame.width, frame.height)
    }

    private func waitForPickerChoice(timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if pickerChoiceExists() {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.25))
        }
        return false
    }

    private func pickerChoiceExists() -> Bool {
        pickerChoices.contains(where: {
            let elements = [app.buttons[$0], app.staticTexts[$0], app.navigationBars[$0]]
            return elements.contains(where: { $0.exists && $0.isHittable })
        })
    }

    private func waitForHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isHittable == true"),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }
}
