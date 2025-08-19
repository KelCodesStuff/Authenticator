//
//  AuthenticatorAuthTests.swift
//  Authenticator
//
//  Created by Kel Reid on 3/20/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest

final class AuthenticatorAuthTests: XCTestCase {
    
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
    
    // MARK: - Authentication Flow Tests
    func testPasscodeEntry() throws {
        try unlockApp()
    }
    
    func testBiometricAuthentication() throws {
        // Check if biometric button exists (only if biometrics are available)
        let biometricButton = app.buttons["Use Face ID"] // or "Use Touch ID" depending on device
        if biometricButton.exists {
            biometricButton.tap()
            // Note: Actual biometric authentication cannot be tested in UI tests as it requires a real device
        } else {
            // If biometrics not available, enter passcode and unlock
            try unlockApp()
        }
    }
    
    func testInvalidPasscode() throws {
        // Enter invalid passcode
        let passcodeField = app.secureTextFields["Passcode"]
        passcodeField.tap()
        passcodeField.typeText("00000000")
        
        // Submit
        let unlockButton = app.buttons["Unlock"]
        unlockButton.tap()
        
        // Wait for the error alert to appear
        let errorAlert = app.alerts["Error"]
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: errorAlert)
        let result = XCTWaiter.wait(for: [expectation], timeout: 15.0)
        
        XCTAssertEqual(result, .completed, "Error alert did not appear in time")
        
        // Dismiss alert
        errorAlert.buttons["OK"].tap()
    }
}
