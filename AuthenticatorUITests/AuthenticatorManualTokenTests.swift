//
//  AuthenticatorManualTokenTests.swift
//  AuthenticatorUITests
//
//  Created by Kelvin Reid on 3/20/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest

final class AuthenticatorManualTokenTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        
        // Enable biometric authentication in simulator
        if #available(iOS 13.0, *) {
            app.launchEnvironment["XCUITest_FASTLANE_SKIP_BIOMETRICS"] = "false"
        }
        
        // Add test token before launching the app
        let secret = "JBSWY3DPEHPK3PXP"
        let uri = "otpauth://totp/Test%20Service:test@example.com?secret=\(secret)&issuer=Test%20Service"
        app.launchEnvironment["TEST_TOKEN_URI"] = uri
        
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
        
        let unlockButton = app.buttons["Unlock"]
        
        // Wait for unlock button to be enabled
        let startTime = Date()
        let timeout: TimeInterval = 20
        while !unlockButton.exists {
            if Date().timeIntervalSince(startTime) > timeout {
                XCTFail("Unlock button did not appear after \(timeout) seconds")
                return
            }
            sleep(1)
        }
        
        unlockButton.tap()
        
        // Wait for main view to appear
        let navBarTitle = app.staticTexts["Authenticator"]
        let navBarTitleLoaded = navBarTitle.waitForExistence(timeout: 15)
        XCTAssertTrue(navBarTitleLoaded, "Navigation bar title did not load in time")
    }
    
    // MARK: - Manual Entry Tests
    func testValidTokenEntry() throws {
        try unlockApp()
        
        // Wait for the manual entry button to be available and tap it
        let manualEntryButton = app.buttons["manualEntryButton"]
        let manualEntryExists = manualEntryButton.waitForExistence(timeout: 5)
        XCTAssertTrue(manualEntryExists, "Manual Entry button should exist")
        manualEntryButton.tap()
        
        // Verify manual entry view is shown
        XCTAssertTrue(app.navigationBars["Manual Entry"].exists)
        
        // Fill in valid data
        let issuerTextField = app.textFields["Issuer"]
        let accountTextField = app.textFields["Account Name"]
        let secretTextField = app.secureTextFields["Secret Key"]
        
        issuerTextField.tap()
        issuerTextField.typeText("Test Issuer")
        
        accountTextField.tap()
        accountTextField.typeText("Test Account")
        
        // Enter valid secret
        secretTextField.tap()
        secretTextField.typeText("JBSWY3DPEHPK3PXP")
        
        // Add valid token
        app.buttons["Add"].tap()
        
        // Verify token was added
        XCTAssertTrue(app.staticTexts["Test Issuer"].exists)
        XCTAssertTrue(app.staticTexts["Test Account"].exists)
    }
    
    func testInvalidTokenEntry() throws {
        try unlockApp()
        
        // Wait for the manual entry button to be available and tap it
        let manualEntryButton = app.buttons["manualEntryButton"]
        let manualEntryExists = manualEntryButton.waitForExistence(timeout: 5)
        XCTAssertTrue(manualEntryExists, "Manual Entry button should exist")
        manualEntryButton.tap()
        
        // Verify manual entry view is shown
        XCTAssertTrue(app.navigationBars["Manual Entry"].exists)
        
        // Fill in valid data
        let issuerTextField = app.textFields["Issuer"]
        let accountTextField = app.textFields["Account Name"]
        let secretTextField = app.secureTextFields["Secret Key"]
        
        issuerTextField.tap()
        issuerTextField.typeText("Invalid Issuer")
        
        accountTextField.tap()
        accountTextField.typeText("Invalid Account")
        
        // Enter invalid secret
        secretTextField.tap()
        secretTextField.typeText("111111111111")
        
        // Try to add invalid token
        app.buttons["Add"].tap()
        
        // Verify error alert is shown
        let errorAlert = app.alerts["Error"]
        XCTAssertTrue(errorAlert.exists, "Error alert should be shown for invalid secret")
        
        // Dismiss the error alert
        app.alerts["Error"].buttons["OK"].tap()
        
        // Close the manual entry sheet
        app.buttons["Cancel"].tap()
        
        // Verify we're back on the main view
        XCTAssertTrue(app.navigationBars["Authenticator"].exists)
        
        // Verify token was not added by checking it's not in the main list
        XCTAssertFalse(app.staticTexts["Invalid Issuer"].exists, "Token should not be added with invalid secret")
        XCTAssertFalse(app.staticTexts["Invalid Account"].exists, "Token should not be added with invalid secret")
    }
    
}
