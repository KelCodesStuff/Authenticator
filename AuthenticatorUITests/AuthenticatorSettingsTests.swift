//
//  AuthenticatorUISettingsTest.swift
//  Authenticator
//
//  Created by Kelvin Reid on 3/20/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest

final class AuthenticatorSettingsTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
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

    // MARK: - Settings Tests
    func testSettingsOptions() throws {
        try unlockApp()
        
        // Wait for the settings button to be available and tap it
        let settingsButton = app.buttons["settingsButton"]
        let settingsExists = settingsButton.waitForExistence(timeout: 5)
        XCTAssertTrue(settingsExists, "Settings button should exist")
        settingsButton.tap()
        
        // Verify settings view is shown
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        
        // Wait for and verify biometric toggle if available
        let biometricToggle = app.switches["Face ID"]
        if biometricToggle.waitForExistence(timeout: 3) {
            XCTAssertTrue(biometricToggle.exists, "Biometric toggle should exist")
        } else {
            print("Biometric toggle not available - this is expected in simulator unless configured")
        }
        
        // Wait for and verify iCloud backup toggle
        let iCloudBackupToggle = app.switches["iCloud Backup"]
        let backupToggleExists = iCloudBackupToggle.waitForExistence(timeout: 3)
        XCTAssertTrue(backupToggleExists, "iCloud Backup toggle should exist")
        
        // Close settings
        app.buttons["Done"].tap()
        
        // Verify we're back on the main view
        XCTAssertTrue(app.navigationBars["Authenticator"].exists)
    }

}
