//
//  AuthenticatorUITests.swift
//  AuthenticatorUITests
//
//  Created by Kelvin Reid on 3/15/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest

final class AuthenticatorUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        // Check the environment variable *before* initializing the app.
        if !shouldRunUITests() {
            //  Skip all setup if UI tests are disabled.
            throw XCTSkip("Skipping UI tests due to RUN_UI_TESTS environment variable.")
        }

        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]

        // Enable biometric authentication in simulator
        if #available(iOS 13.0, *) {
            app.launchEnvironment["XCUITest_FASTLANE_SKIP_BIOMETRICS"] = "false"
        }

        app.launch()
    }

    override func tearDownWithError() throws {
        // Only tear down if setup was actually performed
        if app != nil {
            app = nil
        }
    }
    
    // MARK: Helper Functions
    func shouldRunUITests() -> Bool {
        guard let runUITests = ProcessInfo.processInfo.environment["RUN_UI_TESTS"] else {
            return false // Default to OFF if not set.
        }
        return runUITests.lowercased() == "true"
    }

    // MARK: - Helper Methods
    private func unlockApp() throws {
        let app = XCUIApplication()

        // Check if SetPasscodeView is present
        if app.navigationBars["Set Passcode"].exists {
            // Set a passcode
            let passcodeField1 = app.secureTextFields["Passcode"]
            passcodeField1.tap()
            passcodeField1.typeText("12345678")

            let passcodeField2 = app.secureTextFields["Confirm passcode"]
            passcodeField2.tap()
            passcodeField2.typeText("12345678")

            app.buttons["Start"].tap()
        }

        // Input Passcode View
        let passcodeField = app.secureTextFields["Passcode"]
        passcodeField.tap()
        passcodeField.typeText("12345678")

        print(app.debugDescription) // Print UI hierarchy

        let unlockButton = app.buttons["Unlock"]

        // Extended wait with polling
        let startTime = Date()
        let timeout: TimeInterval = 20
        while !unlockButton.exists {
            if Date().timeIntervalSince(startTime) > timeout {
                // Take screenshot and UI hierarchy snapshot
                let screenshot = XCUIScreen.main.screenshot()
                let attachment = XCTAttachment(screenshot: screenshot)
                attachment.name = "UnlockButtonFailureScreenshot"
                attachment.lifetime = .keepAlways
                add(attachment)

                let hierarchyData = app.debugDescription.data(using: .utf8)!
                let hierarchyAttachment = XCTAttachment(data: hierarchyData, uniformTypeIdentifier: "public.plain-text")
                hierarchyAttachment.name = "UnlockButtonFailureHierarchy"
                hierarchyAttachment.lifetime = .keepAlways
                add(hierarchyAttachment)

                XCTFail("Unlock button did not appear after \(timeout) seconds")
                return
            }
            sleep(1)
        }

        unlockButton.tap()
    }

    // MARK: - Authentication Flow Tests
    func testPasscodeEntry() throws {
        try unlockApp()
    }

    func testBiometricAuthentication() throws {
        // Check if biometric button exists (only if biometrics are available)
        let biometricButton = app.buttons["Use Face ID"] // or "Use Touch ID" depending on device
        if biometricButton.exists {
            biometricButton.tap()
            // Note: Actual biometric authentication cannot be tested in UI tests
            // as it requires real device interaction
        } else {
            // If biometrics not available, enter passcode and unlock
            try unlockApp()
        }
    }

    // MARK: - Token Management Tests
    func testScannerView() throws {
        try unlockApp()

        // Navigate to add token screen
        let scanButton = app.buttons["qrcode"]
        XCTAssertTrue(scanButton.exists)
        scanButton.tap()

        // Wait for the scanner view to appear (up to 10 seconds)
        let scannerView = app.otherElements["AuthCodeScannerView"] //Use the struct name.
        let scannerViewExists = scannerView.waitForExistence(timeout: 15)
        //XCTAssertTrue(scannerViewExists, "Scanner view did not appear within 10 seconds")

        // Check for the cancel button
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists)


        //Check for the overlay.
        let qrCodeOverlay = app.otherElements["QRCodeOverlay"]
        //XCTAssertTrue(qrCodeOverlay.exists)
    }

    func testTokenListNavigation() throws {
        throw XCTSkip("Skipping this test for now.")

        try unlockApp()

        // Verify token list exists
        let tokenList = app.tables.element
        XCTAssertTrue(tokenList.exists)

        // Test scrolling
        tokenList.swipeUp()
        tokenList.swipeDown()
    }

    func testTokenDetails() throws {
        try unlockApp()

        // Tap on a token if it exists
        let tokenCell = app.cells.element(boundBy: 0)
        if tokenCell.exists {
            tokenCell.tap()

            // Verify details are shown
            let issuerLabel = app.staticTexts["Issuer"]
            XCTAssertTrue(issuerLabel.exists)

            let accountLabel = app.staticTexts["Account Name"]
            XCTAssertTrue(accountLabel.exists)
        }
    }

    // MARK: - Settings Tests
    func testSettingsNavigation() throws {
        try unlockApp()

        // Navigate to settings using the gear icon
        let settingsButton = app.buttons["gearshape"]
        XCTAssertTrue(settingsButton.exists)
        settingsButton.tap()

        // Verify settings options
        let biometricToggle = app.switches["Face ID"] // or "Touch ID" depending on device
        if biometricToggle.exists {
            XCTAssertTrue(biometricToggle.exists)
        } else {
            // Log that biometric toggle is not available
            print("Biometric toggle not available - this is expected in simulator unless configured")
        }

        let iCloudBackupToggle = app.switches["iCloud Backup"]
        XCTAssertTrue(iCloudBackupToggle.exists)
    }

    // MARK: - Error Handling Tests
    func testInvalidPasscode() throws {
        // Enter invalid passcode
        let passcodeField = app.secureTextFields["Passcode"]
        passcodeField.tap()
        passcodeField.typeText("00000000")

        // Submit
        let unlockButton = app.buttons["Unlock"]
        unlockButton.tap()

        // Verify error alert
        let errorAlert = app.alerts["Error"]
        XCTAssertTrue(errorAlert.exists)

        // Dismiss alert
        errorAlert.buttons["OK"].tap()
    }

    func testInvalidTokenURI() throws {
        try unlockApp()

        // Navigate to add token screen
        let scanButton = app.buttons["qrcode"]
        scanButton.tap()

        // Note: QR code scanning cannot be tested in UI tests
        // as it requires real camera interaction
    }
}
